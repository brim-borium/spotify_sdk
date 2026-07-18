import 'dart:io';

import 'android_setup.dart';

/// Removes all changes made by the android_setup script.
Future<void> main(List<String> args) async {
  logger.i('running android_cleanup script');

  // remove the module directory if it exists
  final moduleDir = Directory('android/$moduleName');
  if (moduleDir.existsSync()) {
    await moduleDir.delete(recursive: true);
    logger.t('deleted directory ${moduleDir.path}');
  }

  // remove the include statement from settings.gradle or settings.gradle.kts
  final settingsFile = File('android/settings.gradle.kts').existsSync()
      ? File('android/settings.gradle.kts')
      : File('android/settings.gradle');

  if (settingsFile.existsSync()) {
    final settingsFileContent = await settingsFile.readAsString();
    final includeStatements = [
      "include ':$moduleName'",
      'include ":$moduleName"',
      'include(":$moduleName")',
      "include(':$moduleName')",
    ];
    if (includeStatements.any(settingsFileContent.contains)) {
      final newSettingsFileContent = includeStatements.fold(
        settingsFileContent,
        (previousValue, element) => previousValue.replaceAll(element, ''),
      );
      await settingsFile.writeAsString(newSettingsFileContent);
      logger.t('removed include statement from ${settingsFile.path}');
    }
  }

  // remove the RedirectUriReceiverActivity from AndroidManifest.xml
  final manifestFile = File('android/app/src/main/AndroidManifest.xml');
  if (manifestFile.existsSync()) {
    final content = await manifestFile.readAsString();
    const activityName =
        'com.spotify.sdk.android.auth.RedirectUriReceiverActivity';
    if (content.contains(activityName)) {
      final activityPattern = RegExp(
        r'\s*<!-- Added by spotify_sdk setup -->\s*<activity\s+'
        r'android:name="com\.spotify\.sdk\.android\.auth\.'
        r'RedirectUriReceiverActivity"[\s\S]*?</activity>',
      );
      final activityPatternSimple = RegExp(
        r'\s*<activity\s+android:name="com\.spotify\.sdk\.android\.auth\.'
        r'RedirectUriReceiverActivity"[\s\S]*?</activity>',
      );
      final newContent = content
          .replaceAll(activityPattern, '')
          .replaceAll(activityPatternSimple, '');
      await manifestFile.writeAsString(newContent);
      logger.t('removed RedirectUriReceiverActivity from AndroidManifest.xml');
    }
  }
}
