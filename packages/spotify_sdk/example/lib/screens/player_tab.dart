import 'package:flutter/material.dart';
import 'package:spotify_sdk_example/controllers/spotify_controller.dart';
import 'package:spotify_sdk_example/widgets/advanced_playback_card.dart';
import 'package:spotify_sdk_example/widgets/connection_status_card.dart';
import 'package:spotify_sdk_example/widgets/custom_playback_card.dart';
import 'package:spotify_sdk_example/widgets/diagnostics_card.dart';
import 'package:spotify_sdk_example/widgets/library_card.dart';
import 'package:spotify_sdk_example/widgets/now_playing_card.dart';
import 'package:spotify_sdk_example/widgets/player_controls_bar.dart';

/// Main Player Tab featuring connection status, player controls, and SDK tools.
class PlayerTab extends StatelessWidget {
  /// Creates a [PlayerTab].
  const PlayerTab({
    required this.controller,
    super.key,
  });

  /// Spotify controller reference.
  final SpotifyController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ConnectionStatusCard(controller: controller),
        const SizedBox(height: 16),
        NowPlayingCard(controller: controller),
        const SizedBox(height: 16),
        PlayerControlsBar(controller: controller),
        const SizedBox(height: 16),
        CustomPlaybackCard(controller: controller),
        const SizedBox(height: 16),
        LibraryCard(controller: controller),
        const SizedBox(height: 16),
        AdvancedPlaybackCard(controller: controller),
        const SizedBox(height: 16),
        DiagnosticsCard(controller: controller),
      ],
    );
  }
}
