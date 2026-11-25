import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/education_form.dart';
import 'package:myportofolio_mobile/screens/menu.dart';

import 'test_helpers.dart';

Finder field(String name) => find.byKey(ValueKey('education-$name'));

Future<void> openForm(WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(home: EducationFormPage()));
}

Future<void> fillValidForm(WidgetTester tester) async {
  for (final entry in {
    'title': ' Bachelor of Information Systems ',
    'institution': ' Universitas Indonesia ',
    'major': ' Information Systems ',
    'description': ' Studying application development. ',
    'thumbnail': ' https://example.com/institution.png ',
    'start-year': '2025',
    'end-year': '2029',
  }.entries) {
    await tester.enterText(field(entry.key), entry.value);
  }
}

Future<void> pressSave(WidgetTester tester) async {
  await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Save'));
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
  await tester.pumpAndSettle();
}

void usePhoneScreen(WidgetTester tester) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(360, 640);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadAppFonts);

  testWidgets(
    'Education action card opens form and Back returns home on phone',
    (tester) async {
      usePhoneScreen(tester);
      await tester.pumpWidget(const MyApp());
      await tester.ensureVisible(find.text('Add Education'));
      await tester.tap(find.text('Add Education'));
      await tester.pumpAndSettle();

      expect(find.byType(EducationFormPage), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(MyHomePage), findsOneWidget);
      expect(find.byType(EducationFormPage), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Drawer retains tutorial options and Education can return Home', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(ListTile, 'Home'), findsOneWidget);
    expect(find.widgetWithText(ListTile, 'Add Project'), findsOneWidget);
    await tester.tap(find.widgetWithText(ListTile, 'Add Education'));
    await tester.pumpAndSettle();
    expect(find.byType(EducationFormPage), findsOneWidget);

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'Home'));
    await tester.pumpAndSettle();
    expect(find.byType(MyHomePage), findsOneWidget);
    expect(find.byType(EducationFormPage), findsNothing);
  });

  testWidgets('Required fields reject empty and whitespace-only input', (
    tester,
  ) async {
    await openForm(tester);
    for (final value in ['', '   ']) {
      for (final name in [
        'title',
        'institution',
        'major',
        'description',
        'start-year',
      ]) {
        await tester.enterText(field(name), value);
      }
      await pressSave(tester);
      for (final message in [
        'Enter an education title.',
        'Enter an institution.',
        'Enter a major.',
        'Enter a description.',
        'Enter a start year.',
      ]) {
        expect(find.text(message), findsOneWidget);
      }
      expect(find.byType(AlertDialog), findsNothing);
    }
  });

  testWidgets('Text and thumbnail respect model length limits', (tester) async {
    await openForm(tester);
    await fillValidForm(tester);
    for (final name in ['title', 'institution', 'major']) {
      await tester.enterText(field(name), 'a' * 256);
    }
    await tester.enterText(
      field('thumbnail'),
      'https://example.com/${'a' * 481}',
    );
    await pressSave(tester);
    expect(find.text('Use at most 255 characters.'), findsNWidgets(3));
    expect(find.text('Use at most 500 characters.'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('Thumbnail rejects invalid URL schemes and malformed hosts', (
    tester,
  ) async {
    await openForm(tester);
    await fillValidForm(tester);
    for (final url in [
      'not a URL',
      'ftp://example.com/image.png',
      'https://',
      'https://example..com/image.png',
      'https://-invalid.example/image.png',
    ]) {
      await tester.enterText(field('thumbnail'), url);
      await pressSave(tester);
      expect(find.text('Enter a valid HTTP or HTTPS URL.'), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
    }
  });

  testWidgets('Years reject non-integers and values outside the model range', (
    tester,
  ) async {
    await openForm(tester);
    await fillValidForm(tester);
    for (final name in ['start-year', 'end-year']) {
      for (final value in ['abc', '2025.5', '-1', '32768']) {
        await tester.enterText(field(name), value);
        await pressSave(tester);
        expect(
          find.text('Enter a whole year from 0 to 32767.'),
          findsOneWidget,
        );
        expect(find.byType(AlertDialog), findsNothing);
      }
      await tester.enterText(
        field(name),
        name == 'start-year' ? '2025' : '2029',
      );
    }
  });

  testWidgets(
    'End year cannot precede start year and equal years are accepted',
    (tester) async {
      await openForm(tester);
      await fillValidForm(tester);
      await tester.enterText(field('end-year'), '2024');
      await pressSave(tester);
      expect(
        find.text('End year must not be before start year.'),
        findsOneWidget,
      );
      expect(find.byType(AlertDialog), findsNothing);

      await tester.enterText(field('end-year'), '2025');
      await pressSave(tester);
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('End Year: 2025'), findsOneWidget);
    },
  );

  testWidgets('Valid entries display every value and OK keeps the form input', (
    tester,
  ) async {
    await openForm(tester);
    await fillValidForm(tester);
    await pressSave(tester);
    for (final summary in [
      'Education Title: Bachelor of Information Systems',
      'Institution: Universitas Indonesia',
      'Major: Information Systems',
      'Description: Studying application development.',
      'Thumbnail URL: https://example.com/institution.png',
      'Start Year: 2025',
      'End Year: 2029',
    ]) {
      expect(find.text(summary), findsOneWidget);
    }
    await tester.tap(find.widgetWithText(TextButton, 'OK'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byType(EducationFormPage), findsOneWidget);
    expect(
      tester.widget<TextFormField>(field('institution')).controller!.text,
      ' Universitas Indonesia ',
    );
  });

  testWidgets(
    'Optional values may be blank and model boundary values are valid',
    (tester) async {
      await openForm(tester);
      await fillValidForm(tester);
      await tester.enterText(field('thumbnail'), '   ');
      await tester.enterText(field('end-year'), '   ');
      await tester.enterText(field('start-year'), '0');
      for (final name in ['title', 'institution', 'major']) {
        await tester.enterText(field(name), 'a' * 255);
      }
      await pressSave(tester);
      expect(find.text('Thumbnail URL: Not provided'), findsOneWidget);
      expect(find.text('End Year: Ongoing'), findsOneWidget);
      expect(find.text('Start Year: 0'), findsOneWidget);
    },
  );

  testWidgets('Save remains reachable on phone with the keyboard open', (
    tester,
  ) async {
    usePhoneScreen(tester);
    await openForm(tester);
    await fillValidForm(tester);
    tester.view.viewInsets = const FakeViewPadding(bottom: 260);
    addTearDown(tester.view.resetViewInsets);
    await tester.showKeyboard(field('end-year'));
    await tester.pumpAndSettle();
    await pressSave(tester);
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
