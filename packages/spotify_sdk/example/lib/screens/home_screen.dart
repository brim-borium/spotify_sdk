import 'dart:async';

import 'package:flutter/material.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:spotify_sdk_example/controllers/spotify_controller.dart';
import 'package:spotify_sdk_example/screens/player_tab.dart';
import 'package:spotify_sdk_example/theme/spotify_theme.dart';
import 'package:spotify_sdk_example/widgets/log_console_sheet.dart';

/// Main home screen displaying the unified Spotify SDK Showcase dashboard.
class HomeScreen extends StatelessWidget {
  /// Creates a [HomeScreen].
  const HomeScreen({
    required this.controller,
    super.key,
  });

  /// Spotify controller reference.
  final SpotifyController controller;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ConnectionStatus>(
      stream: controller.connectionStatusStream,
      builder: (context, snapshot) {
        final isConnected = snapshot.data?.connected ?? controller.isConnected;

        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: SpotifyTheme.pastelMint.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.graphic_eq_rounded,
                    color: SpotifyTheme.pastelMint,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                const Text('Spotify SDK Showcase'),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.terminal_rounded),
                tooltip: 'SDK Console Logs',
                onPressed: () => _showLogConsole(context),
              ),
              if (isConnected)
                IconButton(
                  icon: const Icon(
                    Icons.power_settings_new_rounded,
                    color: SpotifyTheme.errorPastel,
                  ),
                  tooltip: 'Disconnect Remote',
                  onPressed: () => unawaited(controller.disconnect()),
                )
              else
                IconButton(
                  icon: const Icon(
                    Icons.cast_connected_rounded,
                    color: SpotifyTheme.pastelMint,
                  ),
                  tooltip: 'Connect Remote',
                  onPressed: () => unawaited(
                    controller.connectToSpotifyRemote(),
                  ),
                ),
              const SizedBox(width: 8),
            ],
          ),
          body: PlayerTab(controller: controller),
        );
      },
    );
  }

  void _showLogConsole(BuildContext context) {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => LogConsoleSheet(controller: controller),
      ),
    );
  }
}
