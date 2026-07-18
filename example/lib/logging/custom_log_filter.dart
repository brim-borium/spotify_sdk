import 'package:logger/logger.dart';

/// A custom log filter for the Spotify SDK example app.
class CustomLogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    return true;
  }
}
