import 'dart:io';

import 'android_setup.dart';

/// Checks if all preconditions are met to execute the script.
/// Returns true if all preconditions are met, false otherwise.
class PreconditionChecker {
  static bool setupConditionsMet() {
    // check if the script is executed on a supported platform
    if (!Platform.isMacOS && !Platform.isLinux) {
      logger.w(
        'Warning: This script has not been tested on your platform '
        '(${Platform.operatingSystem}).',
      );
    }

    // check if flutter is installed
    if (!(Platform.environment['PATH']?.contains('flutter') ?? false) &&
        Platform.environment['FLUTTER_ROOT'] == null) {
      logger.e('Error: Flutter is not installed or not in your PATH.');
      return false;
    }

    // check if the script is executed from inside a flutter project
    if (!File('pubspec.yaml').existsSync()) {
      logger.e(
        'Error: The script must be executed from inside a flutter project.',
      );
      return false;
    }

    // check if the necessary android files exist
    final hasAppGradle = File('android/app/build.gradle').existsSync() ||
        File('android/app/build.gradle.kts').existsSync();
    if (!hasAppGradle) {
      logger.e(
        'Error: Neither "android/app/build.gradle" nor "build.gradle.kts" exists.',
      );
      return false;
    }

    // check if the setup may have already been executed and recommend to run
    // the cleanup script
    var prevRun = Directory('android/$moduleName').existsSync() ||
        File('android/$moduleName/build.gradle').existsSync() ||
        File('android/$moduleName/build.gradle.kts').existsSync();

    final settingsFile = File('android/settings.gradle.kts').existsSync()
        ? File('android/settings.gradle.kts')
        : File('android/settings.gradle');
    if (!prevRun && settingsFile.existsSync()) {
      final content = settingsFile.readAsStringSync();
      prevRun |= content.contains("include ':$moduleName'");
      prevRun |= content.contains('include ":$moduleName"');
      prevRun |= content.contains('include(":$moduleName")');
      prevRun |= content.contains("include(':$moduleName')");
    }

    if (prevRun) {
      logger.w(
        'Warning: The setup may have already been executed. Please run dart '
        'run spotify_sdk:android_setup --cleanup before running this script '
        'again.',
      );
      return false;
    }

    return true;
  }
}
