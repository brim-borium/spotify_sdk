import 'dart:io';

import 'android_setup.dart';

/// Removes all changes made by the [android_setup] script.
Future<void> main(List<String> args) async {
  logger.i('running android_cleanup script');

  // remove the module directory if it exists
  final moduleDir = Directory('android/$moduleName');
  if (moduleDir.existsSync()) {
    await moduleDir.delete(recursive: true);
    logger.t('deleted directory ${moduleDir.path}');
  }

  // remove the include statement from settings.gradle
  final settingsFile = await File('android/settings.gradle').readAsString();
  const includeStatements = [
    "include ':$moduleName'",
    'include ":$moduleName"'
  ];
  if (includeStatements.any((element) => settingsFile.contains(element))) {
    final newSettingsFile = includeStatements.fold(settingsFile,
        (previousValue, element) => previousValue.replaceAll(element, ''));
    await File('android/settings.gradle').writeAsString(newSettingsFile);
    logger.t('removed include statement from settings.gradle');
  }

  // remove the manifestPlaceholder from app/build.gradle
  final appBuildFile = await File('android/app/build.gradle').readAsString();
  if (appBuildFile.contains('manifestPlaceholders')) {
    final newAppBuildFile = appBuildFile
        .split('\n')
        .where((element) => !element.contains('manifestPlaceholders'))
        .join('\n');
    await File('android/app/build.gradle').writeAsString(newAppBuildFile);
    logger.t('removed manifestPlaceholders from app/build.gradle');
  }
}
