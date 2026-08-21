import 'dart:async';

import 'package:flutter/material.dart';
import 'package:spotify_sdk_example/controllers/spotify_controller.dart';
import 'package:spotify_sdk_example/theme/spotify_theme.dart';

/// Card for device management and crossfade state inspection.
class SystemCrossfadeCard extends StatelessWidget {
  /// Creates a [SystemCrossfadeCard].
  const SystemCrossfadeCard({
    required this.controller,
    super.key,
  });

  /// Spotify controller reference.
  final SpotifyController controller;

  @override
  Widget build(BuildContext context) {
    final crossfade = controller.crossfadeState;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SpotifyTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SpotifyTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.devices_rounded,
                color: SpotifyTheme.pastelBlue,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Device & Crossfade Settings',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: SpotifyTheme.textDarkPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: controller.isConnected
                      ? () => unawaited(controller.switchToLocalDevice())
                      : null,
                  icon: const Icon(Icons.phonelink_setup_rounded),
                  label: const Text('Switch to Local Device'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SpotifyTheme.pastelBlue,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: controller.isConnected
                      ? () => unawaited(controller.getCrossfadeState())
                      : null,
                  icon: const Icon(
                    Icons.tune_rounded,
                    color: SpotifyTheme.pastelLavender,
                  ),
                  label: const Text('Fetch Crossfade'),
                ),
              ),
            ],
          ),

          if (crossfade != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: SpotifyTheme.backgroundLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Crossfade Status',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: SpotifyTheme.textDarkSecondary,
                        ),
                      ),
                      Text(
                        crossfade.isEnabled ? 'Enabled' : 'Disabled',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: crossfade.isEnabled
                              ? SpotifyTheme.successPastel
                              : SpotifyTheme.textDarkPrimary,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Duration',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: SpotifyTheme.textDarkSecondary,
                        ),
                      ),
                      Text(
                        '${crossfade.duration}ms',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: SpotifyTheme.textDarkPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
