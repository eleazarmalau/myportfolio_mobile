import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/project_detail_screen.dart';
import 'package:myportofolio_mobile/screens/projects_list_screen.dart';
import 'package:myportofolio_mobile/services/api_client.dart';

import 'test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadAppFonts);

  testWidgets('Home opens the project list and details, then returns to list', (
    tester,
  ) async {
    var requests = 0;
    final client = ApiClient(
      client: MockClient((request) async {
        requests++;
        expect(request.method, 'GET');
        expect(request.url.path, '/api/v1/projects/');
        return http.Response(
          jsonEncode([
            {
              'id': 'project-1',
              'title': 'Portfolio App',
              'description': 'A mobile portfolio.',
              'tech_stack': 'Flutter, Django',
              'project_url': 'https://example.com/project',
              'project_image_url': '',
            },
          ]),
          200,
        );
      }),
    );
    await tester.pumpWidget(MyApp(apiClient: client));
    await tester.tap(find.text('View Projects'));
    await tester.pumpAndSettle();
    expect(find.byType(ProjectListScreen), findsOneWidget);

    await tester.tap(find.text('Portfolio App'));
    await tester.pumpAndSettle();
    expect(find.byType(ProjectDetailScreen), findsOneWidget);
    expect(find.text('Portfolio App'), findsOneWidget);
    expect(find.text('A mobile portfolio.'), findsOneWidget);
    expect(find.text('Flutter, Django'), findsOneWidget);
    expect(find.text('https://example.com/project'), findsOneWidget);
    expect(find.byType(Image), findsNothing);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(ProjectListScreen), findsOneWidget);
    expect(requests, 1);
    expect(tester.takeException(), isNull);
  });
}
