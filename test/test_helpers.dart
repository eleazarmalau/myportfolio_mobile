import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

Future<void> loadAppFonts() async {
  // The default Ahem test font is wider than the Roboto used by the app.
  final configFile = File('.dart_tool/package_config.json');
  final config = jsonDecode(await configFile.readAsString()) as Map;
  final flutter = (config['packages'] as List).cast<Map>().singleWhere(
    (package) => package['name'] == 'flutter',
  );
  final flutterRoot = configFile.uri.resolve('${flutter['rootUri']}/');
  final loader = FontLoader('Roboto');
  for (final name in ['Roboto-Regular.ttf', 'Roboto-Bold.ttf']) {
    final font = File.fromUri(
      flutterRoot.resolve('../../bin/cache/artifacts/material_fonts/$name'),
    );
    loader.addFont(font.readAsBytes().then(ByteData.sublistView));
  }
  await loader.load();
}
