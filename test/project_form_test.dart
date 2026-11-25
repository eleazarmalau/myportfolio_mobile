import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/screens/login_screen.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:provider/provider.dart';

Finder field(String name) => find.byKey(ValueKey('project-$name'));

Future<AuthState> openForm(
  WidgetTester tester,
  Future<http.Response> Function(http.Request) handler, {
  String? token = 'test-token',
}) async {
  final client = ApiClient(client: MockClient(handler));
  final auth = AuthState(client, initialToken: token);
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider.value(value: client),
        ChangeNotifierProvider.value(value: auth),
      ],
      child: const MaterialApp(home: ProjectFormPage()),
    ),
  );
  return auth;
}

Future<void> fillForm(WidgetTester tester) async {
  for (final entry in {
    'title': ' Portfolio ',
    'description': ' My Flutter project. ',
    'tech-stack': ' Flutter, Django ',
    'url': ' https://example.com/project ',
  }.entries) {
    await tester.enterText(field(entry.key), entry.value);
  }
}

Future<void> pressSave(WidgetTester tester, {bool settle = true}) async {
  final save = find.byType(ElevatedButton);
  await tester.ensureVisible(save);
  await tester.pumpAndSettle();
  await tester.tap(save);
  if (settle) await tester.pumpAndSettle();
}

void main() {
  testWidgets('Empty and whitespace fields never submit or open login', (
    tester,
  ) async {
    var calls = 0;
    await openForm(tester, (_) async {
      calls++;
      return http.Response('{}', 500);
    }, token: null);
    for (final value in ['', '   ']) {
      for (final name in ['title', 'description', 'tech-stack', 'url']) {
        await tester.enterText(field(name), value);
      }
      await pressSave(tester);
      for (final error in [
        'Enter a title.',
        'Enter a description.',
        'Enter a tech stack.',
        'Enter a project URL.',
      ]) {
        expect(find.text(error), findsOneWidget);
      }
    }
    expect(calls, 0);
    expect(find.byType(LoginScreen), findsNothing);
  });

  testWidgets('Invalid project and image URLs never submit', (tester) async {
    var calls = 0;
    await openForm(tester, (_) async {
      calls++;
      return http.Response('{}', 500);
    });
    await fillForm(tester);
    for (final name in ['url', 'image-url']) {
      for (final url in [
        'not a URL',
        'ftp://example.com/file',
        'https://',
        'https://example..com',
        'https://-invalid.example',
        'https://example.com:99999',
      ]) {
        await tester.enterText(field(name), url);
        await pressSave(tester);
        expect(find.text('Enter a valid HTTP or HTTPS URL.'), findsOneWidget);
      }
      await tester.enterText(field(name), 'https://example.com/project');
    }
    expect(calls, 0);
  });

  testWidgets(
    '201 sends serializer fields and token then confirms and resets',
    (tester) async {
      final requests = <http.Request>[];
      await openForm(tester, (request) async {
        requests.add(request);
        return http.Response(request.body, 201);
      });
      await fillForm(tester);
      await tester.enterText(
        field('image-url'),
        ' https://example.com/image.png ',
      );
      await pressSave(tester);

      final request = requests.single;
      expect(request.method, 'POST');
      expect(request.url.path, '/api/v1/projects/');
      expect(request.headers['Authorization'], 'Token test-token');
      expect(jsonDecode(request.body), {
        'title': 'Portfolio',
        'description': 'My Flutter project.',
        'tech_stack': 'Flutter, Django',
        'project_url': 'https://example.com/project',
        'project_image_url': 'https://example.com/image.png',
      });
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Title: Portfolio'), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      final titleInput = find.descendant(
        of: field('title'),
        matching: find.byType(EditableText),
      );
      expect(tester.widget<EditableText>(titleInput).controller.text, '');
    },
  );

  testWidgets('Guest must finish login before the project POST', (
    tester,
  ) async {
    final paths = <String>[];
    final auth = await openForm(tester, (request) async {
      paths.add(request.url.path);
      if (request.url.path.endsWith('/token/')) {
        return http.Response('{"token":"new-token"}', 200);
      }
      expect(request.headers['Authorization'], 'Token new-token');
      expect(jsonDecode(request.body)['project_image_url'], '');
      return http.Response(request.body, 201);
    }, token: null);
    await fillForm(tester);
    await pressSave(tester);
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(paths, isEmpty);
    await tester.enterText(find.byType(TextFormField).at(0), 'user');
    await tester.enterText(find.byType(TextFormField).at(1), 'password');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();
    expect(auth.token, 'new-token');
    expect(paths, ['/api/v1/auth/token/', '/api/v1/projects/']);
    expect(find.byType(AlertDialog), findsOneWidget);
  });

  testWidgets('Cancelling login preserves input without sending a project', (
    tester,
  ) async {
    var calls = 0;
    await openForm(tester, (_) async {
      calls++;
      return http.Response('{}', 500);
    }, token: null);
    await fillForm(tester);
    await pressSave(tester);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(ProjectFormPage), findsOneWidget);
    expect(find.text(' Portfolio '), findsOneWidget);
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
      isNotNull,
    );
    expect(calls, 0);
  });

  testWidgets('401 logs out and asks for login without retrying the POST', (
    tester,
  ) async {
    final paths = <String>[];
    final auth = await openForm(tester, (request) async {
      paths.add(request.url.path);
      if (request.url.path.endsWith('/logout/')) {
        throw http.ClientException('Network unavailable');
      }
      return http.Response('{"detail":"Invalid token"}', 401);
    });
    await fillForm(tester);
    await pressSave(tester);
    expect(auth.isLoggedIn, isFalse);
    expect(paths, ['/api/v1/projects/', '/api/v1/auth/logout/']);
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text(' Portfolio '), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final status in [400, 500, 200]) {
    testWidgets(
      '$status shows an error and preserves input without confirming',
      (tester) async {
        final auth = await openForm(tester, (_) async {
          return http.Response('{"detail":"Rejected"}', status);
        });
        await fillForm(tester);
        await pressSave(tester);
        expect(find.byType(AlertDialog), findsNothing);
        expect(find.byType(SnackBar), findsOneWidget);
        expect(
          find.textContaining('Failed to save project ($status)'),
          findsOneWidget,
        );
        expect(find.text(' Portfolio '), findsOneWidget);
        expect(auth.isLoggedIn, isTrue);
      },
    );
  }

  testWidgets('Pending submission disables Save and prevents duplicate POSTs', (
    tester,
  ) async {
    final response = Completer<http.Response>();
    var calls = 0;
    await openForm(tester, (request) async {
      calls++;
      return response.future;
    });
    await fillForm(tester);
    await pressSave(tester, settle: false);
    await tester.pump();
    expect(calls, 1);
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
      isNull,
    );
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    expect(calls, 1);
    response.complete(http.Response('{}', 500));
    await tester.pumpAndSettle();
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
      isNotNull,
    );
  });
}
