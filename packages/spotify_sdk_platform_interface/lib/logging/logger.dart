import 'dart:developer' as developer;

/// A lightweight, WASM-compatible logging utility that replaces the heavy
/// external `logger` package to avoid `dart:io` transitive imports.
class Logger {
  final dynamic printer;

  Logger({this.printer});

  void e(String message) {
    developer.log(
      message,
      name: 'spotify_sdk',
      level: 1000, // Error level
    );
  }

  void i(String message) {
    developer.log(
      message,
      name: 'spotify_sdk',
      level: 800, // Info level
    );
  }
}
