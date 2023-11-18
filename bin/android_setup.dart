import 'dart:io';

import 'package:logger/logger.dart';

import 'android_module_creator.dart';
import 'github_api.dart';
import 'precondition_checker.dart';

const String scriptName = 'android_setup';
const String moduleName = 'spotify-app-remote';

final logger = Logger(filter: ScriptLogFilter(), printer: SimplePrinter());

void main(List<String> args) async {
  Logger.level = Level.info;

  if (args.contains('--help')) {
    logger.i('''
    Usage: $scriptName [options]
    Options:
      --help: show this help message
      --verbose: show all logs
    ''');
// TODO: --cleanup: runs the cleanup script before executing the setup script to remove all previously created changes
// TODO: --sdk-version: the version of the Spotify Android SDK, default is the latest release on GitHub
    return;
  } else if (args.contains('--verbose')) {
    Logger.level = Level.trace;
    logger.t('verbose logging enabled');
  }

  if (!PreconditionChecker.setupConditionsMet()) {
    logger.e('$scriptName can not be executed, '
        'please make sure to meet all requirements and try again.');
  } else {
    logger.t('$scriptName started');
    _runSetup();
  }
}

/// Runs the setup process.
void _runSetup() async {
  Uri url;
  String name;
  (name, url) = await GitHubApi.fetchLatestAppRemoteReleaseAssetDownloadUrl();

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
  bool shouldLog(LogEvent event) => true;
}
