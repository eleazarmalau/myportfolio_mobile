import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/screens/login_screen.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/services/api_client.dart';

import 'test_helpers.dart';

Future<void> openApp(WidgetTester tester) async {
  final apiClient = ApiClient(
    client: MockClient((request) async {
      expect(request.method, 'POST');
      expect(request.url.path, '/api/v1/auth/token/');
      return http.Response('{"token":"test-token"}', 200);
    }),
  );
  await tester.pumpWidget(MyApp(apiClient: apiClient));
}

Future<void> completeLogin(WidgetTester tester) async {
  expect(find.byType(LoginScreen), findsOneWidget);
  expect(find.byType(ProjectFormPage), findsNothing);
  await tester.enterText(find.byType(TextFormField).at(0), 'user');
  await tester.enterText(find.byType(TextFormField).at(1), 'password');
  await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(loadAppFonts);

  testWidgets('Home Add Project requires login and supports back navigation', (
    WidgetTester tester,
  ) async {
    await openApp(tester);

    await tester.tap(find.text('Add Project'));
    await tester.pumpAndSettle();
    await completeLogin(tester);

    expect(find.byType(ProjectFormPage), findsOneWidget);
    expect(find.text('Add Project Form'), findsOneWidget);

    Navigator.of(tester.element(find.byType(ProjectFormPage))).pop();
    await tester.pumpAndSettle();

    expect(find.byType(MyHomePage), findsOneWidget);
    expect(find.byType(ProjectFormPage), findsNothing);
  });

  testWidgets('Drawer Add Project requires login and Home returns to menu', (
    WidgetTester tester,
  ) async {
    await openApp(tester);

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'Add Project'));
    await tester.pumpAndSettle();
    await completeLogin(tester);

    expect(find.byType(ProjectFormPage), findsOneWidget);

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(ListTile, 'Logout'), findsOneWidget);
    expect(find.widgetWithText(ListTile, 'Login'), findsNothing);
    await tester.tap(find.widgetWithText(ListTile, 'Home'));
    await tester.pumpAndSettle();

    expect(find.byType(MyHomePage), findsOneWidget);
    expect(find.byType(ProjectFormPage), findsNothing);
    expect(
      tester.state<ScaffoldState>(find.byType(Scaffold)).isDrawerOpen,
      isFalse,
    );
  });
}
