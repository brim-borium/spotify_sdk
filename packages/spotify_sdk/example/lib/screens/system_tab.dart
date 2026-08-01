import 'package:flutter/material.dart';
import 'package:spotify_sdk_example/controllers/spotify_controller.dart';
import 'package:spotify_sdk_example/widgets/connection_status_card.dart';
import 'package:spotify_sdk_example/widgets/system_crossfade_card.dart';

/// Tab for authentication, connections, device switching, and crossfade.
class SystemTab extends StatelessWidget {
  /// Creates a [SystemTab].
  const SystemTab({
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
        SystemCrossfadeCard(controller: controller),
      ],
    );
  }
}
