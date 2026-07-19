// Ignore lints because this is a local developer CLI script, not package code.
// ignore_for_file: avoid_print, lines_longer_than_80_chars
import 'dart:io';

void main() {
  final file = File('packages/spotify_sdk/pubspec.yaml');
  if (!file.existsSync()) {
    print('Error: packages/spotify_sdk/pubspec.yaml not found.');
    exit(1);
  }
  final lines = file.readAsLinesSync();
  String? version;
  for (final line in lines) {
    if (line.trim().startsWith('version:')) {
      version = line.split(':')[1].trim();
      break;
    }
  }
  if (version == null) {
    print('Error: version not found in pubspec.yaml.');
    exit(1);
  }
  print('Found version: $version');

  // Check if tag already exists
  final checkResult = Process.runSync('git', ['tag', '-l', version]);
  if (checkResult.stdout.toString().trim() == version) {
    print('Git tag $version already exists. Skipping creation.');
    return;
  }

  // Create git tag
  final result = Process.runSync('git', ['tag', version, '-m', 'release: $version']);
  if (result.exitCode != 0) {
    print('Error creating git tag: ${result.stderr}');
    exit(result.exitCode);
  }
  print('Successfully created git tag: $version');
}
