import 'dart:io';

import 'package:logger/logger.dart';

import 'android_module_creator.dart';
import 'github_api.dart';
import 'precondition_checker.dart';

import 'android_cleanup.dart' as cleanup;

const String scriptName = 'android_setup';
const String moduleName = 'spotify-app-remote';

final logger = Logger(filter: ScriptLogFilter(), printer: SimplePrinter());
Level loglevel = Level.info;

Future<void> main(List<String> args) async {
  if (args.contains('--help')) {
    logger.i('''
    Usage: $scriptName [options]
    Options:
      --help: show this help message
      --verbose: show all logs
      --cleanup: runs the cleanup script before executing the setup script to remove all previously created changes
      --sdk-version: the version of the Spotify Android SDK, default is the latest release on GitHub (eg. --sdk-version=0.8.0)
    ''');
    return;
  }

  if (args.contains('--verbose')) {
    loglevel = Level.trace;
    logger.t('verbose logging enabled');
  }

  if (args.contains('--cleanup')) {
    logger.t('running cleanup script');
    await cleanup.main(args);
  }

  if (!PreconditionChecker.setupConditionsMet()) {
    logger.e('$scriptName can not be executed, '
        'please make sure to meet all requirements and try again.');
  } else {
    logger.i('running $scriptName script');
    String? sdkVersion = args.cast<String?>().firstWhere(
        (element) => element?.startsWith('--sdk-version=') ?? false,
        orElse: () => null);
    _runSetup(sdkVersion: sdkVersion);
  }
}

/// Runs the setup process.
void _runSetup({String? sdkVersion}) async {
  Uri url;
  String name;
  try {
    if (sdkVersion == null) {
      (name, url) =
          await GitHubApi.fetchLatestAppRemoteReleaseAssetDownloadUrl();
    } else {
      (name, url) =
          await GitHubApi.fetchVersionedAppRemoteReleaseAssetDownloadUrl(
              sdkVersion);
    }
  } catch (e) {
    logger.e('Failed to fetch the Spotify Android SDK asset, terminating.');
    return;
  }

  // create the new module directory
  final destination = File('android/$moduleName/$name')
    ..createSync(recursive: true);
  logger.t('created new file ${destination.path}');

  // download the aar file to the new destination module
  final client = HttpClient();
  final request = await client.getUrl(url);
  final response = await request.close();
  await response.pipe(destination.openWrite());
  client.close();
  logger.t('downloaded $name to ${destination.path}');

  // create the new module
  await AndroidModuleCreator(moduleName, name).createModuleDirectory();
}

/// Log filter to show all logs when running the script in release mode.
class ScriptLogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) => event.level.index >= loglevel.index;
}
