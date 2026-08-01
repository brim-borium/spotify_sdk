/// Severity level of a status log entry.
enum LogSeverity {
  /// Informational status
  info,

  /// Successful action
  success,

  /// Warning condition
  warning,

  /// Exception or error state
  error,
}

/// Represents a log entry captured during Spotify SDK interactions.
class StatusLogEntry {
  /// Creates a [StatusLogEntry].
  StatusLogEntry({
    required this.message,
    this.detail,
    this.severity = LogSeverity.info,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Primary summary message.
  final String message;

  /// Optional detail string or traceback message.
  final String? detail;

  /// Log severity level.
  final LogSeverity severity;

  /// Time when log was generated.
  final DateTime timestamp;
}
