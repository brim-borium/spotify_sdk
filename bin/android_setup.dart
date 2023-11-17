// ignore_for_file: avoid_print

import 'dart:io';

import 'android_module_creator.dart';
import 'github_api.dart';

const String scriptName = 'android_setup';

void main(List<String> args) async {
  if (args.contains('--help')) {
    print('''
    Usage: $scriptName [options]
    Options:
      --help: show this help message
    ''');
// TODO: add android_cleanup script
// TODO: --sdk-version: the version of the Spotify Android SDK, default is the latest release on GitHub
    return;
  }

  if (!_preconditionsAreMet()) {
    print('[$scriptName] can not be executed,'
        'please make sure to meet all requirements and try again.');
  } else {
    _runSetup();
  }
}

/// Checks if all preconditions are met to execute this script.
/// Returns true if all preconditions are met, false otherwise.
bool _preconditionsAreMet() {
  if (!Platform.isMacOS && !Platform.isLinux) {
    print(
        '[$scriptName] Warning: This script has not been tested on your platform (${Platform.operatingSystem}).');
  }

  // check if flutter is installed
  if (!(Platform.environment['PATH']?.contains("flutter") ?? false) &&
      Platform.environment['FLUTTER_ROOT'] == null) {
    print('[$scriptName] Error: Flutter is not installed or not in your PATH.');
    return false;
  }

  // check if the script is executed from inside a flutter project
  if (!File('pubspec.yaml').existsSync()) {
    print(
        '[$scriptName] Error: The script must be executed from inside a flutter project.');
    return false;
  }

  // check if the necessary android files exist
  if (!File('android/app/build.gradle').existsSync()) {
    print(
        '[$scriptName] Error: The file "android/app/build.gradle" does not exist.');
    return false;
  }

  return true;
}

/// Runs the setup process.
void _runSetup() async {
  Uri url;
  String name;
  (name, url) = await GitHubApi().fetchLatestAppRemoteReleaseAssetDownloadUrl();
  File destination = File('android/libs/$name');

  // download the aar file to the new destination module
  final client = HttpClient();
  final request = await client.getUrl(url);
  final response = await request.close();
  await response.pipe(destination.openWrite());
  client.close();

  // create the new module
  await AndroidModuleCreator('spotify-app-remote', name)
      .createModuleDirectory();
}
