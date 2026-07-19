import 'dart:developer' as developer;

/// A lightweight, WASM-compatible logging utility that replaces the heavy
/// external `logger` package to avoid `dart:io` transitive imports.
class Logger {
  /// Creates a new [Logger] instance.
  Logger({this.printer});

  /// Optional printer configuration (not used by this lightweight logger).
  final dynamic printer;

  /// Logs an error message.
  void e(String message) {
    developer.log(
      message,
      name: 'spotify_sdk',
      level: 1000, // Error level
    );
  }

  /// Logs an info message.
  void i(String message) {
    developer.log(
      message,
      name: 'spotify_sdk',
      level: 800, // Info level
    );
  }
}
