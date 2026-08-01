import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spotify_sdk_example/controllers/spotify_controller.dart';
import 'package:spotify_sdk_example/models/status_log_entry.dart';
import 'package:spotify_sdk_example/theme/spotify_theme.dart';

/// Expandable log console sheet to view live SDK updates and tracebacks.
class LogConsoleSheet extends StatelessWidget {
  /// Creates a [LogConsoleSheet].
  const LogConsoleSheet({
    required this.controller,
    super.key,
  });

  /// Spotify controller reference.
  final SpotifyController controller;

  @override
  Widget build(BuildContext context) {
    final logs = controller.logs;

    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: const BoxDecoration(
        color: SpotifyTheme.surfaceWhite,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: SpotifyTheme.borderLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),

          // Title & Actions Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.terminal_rounded,
                      color: SpotifyTheme.pastelMint,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Live SDK Log Console',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: SpotifyTheme.textDarkPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: SpotifyTheme.pastelMint.withValues(
                          alpha: 0.2,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${logs.length}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: SpotifyTheme.pastelMint,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, size: 20),
                      tooltip: 'Copy all logs',
                      onPressed: logs.isEmpty
                          ? null
                          : () {
                              final text = logs
                                  .map(
                                    (l) =>
                                        '[${l.timestamp.toIso8601String()}] '
                                        '${l.message} ${l.detail ?? ""}',
                                  )
                                  .join('\n');
                              unawaited(
                                Clipboard.setData(
                                  ClipboardData(text: text),
                                ),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Logs copied to clipboard'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        size: 20,
                      ),
                      tooltip: 'Clear logs',
                      onPressed: logs.isEmpty ? null : controller.clearLogs,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(color: SpotifyTheme.borderLight),

          // Log Entries List
          Expanded(
            child: logs.isEmpty
                ? const Center(
                    child: Text(
                      'No SDK logs recorded yet.',
                      style: TextStyle(
                        color: SpotifyTheme.textDarkSecondary,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: logs.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final entry = logs[index];
                      return _buildLogItem(entry);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogItem(StatusLogEntry entry) {
    Color badgeColor;
    IconData iconData;

    switch (entry.severity) {
      case LogSeverity.success:
        badgeColor = SpotifyTheme.successPastel;
        iconData = Icons.check_circle_outline_rounded;
      case LogSeverity.warning:
        badgeColor = SpotifyTheme.pastelYellow;
        iconData = Icons.warning_amber_rounded;
      case LogSeverity.error:
        badgeColor = SpotifyTheme.errorPastel;
        iconData = Icons.error_outline_rounded;
      case LogSeverity.info:
        badgeColor = SpotifyTheme.pastelBlue;
        iconData = Icons.info_outline_rounded;
    }

    final h = entry.timestamp.hour.toString().padLeft(2, '0');
    final m = entry.timestamp.minute.toString().padLeft(2, '0');
    final s = entry.timestamp.second.toString().padLeft(2, '0');
    final timeStr = '$h:$m:$s';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SpotifyTheme.backgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SpotifyTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(iconData, size: 16, color: badgeColor),
              const SizedBox(width: 8),
              Text(
                timeStr,
                style: const TextStyle(
                  fontSize: 11,
                  fontFamily: 'monospace',
                  color: SpotifyTheme.textDarkSecondary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  entry.message,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: SpotifyTheme.textDarkPrimary,
                  ),
                ),
              ),
            ],
          ),
          if (entry.detail != null && entry.detail!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 24),
              child: Text(
                entry.detail!,
                style: TextStyle(
                  fontSize: 11,
                  fontFamily: 'monospace',
                  color: entry.severity == LogSeverity.error
                      ? SpotifyTheme.errorPastel
                      : SpotifyTheme.textDarkSecondary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
