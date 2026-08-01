import 'dart:async';

import 'package:flutter/material.dart';
import 'package:spotify_sdk_example/controllers/spotify_controller.dart';
import 'package:spotify_sdk_example/theme/spotify_theme.dart';

/// Card for inspecting system diagnostics (getCrossfadeState, getCapabilities).
class DiagnosticsCard extends StatelessWidget {
  /// Creates a [DiagnosticsCard].
  const DiagnosticsCard({
    required this.controller,
    super.key,
  });

  /// Reference to [SpotifyController].
  final SpotifyController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final crossfade = controller.crossfadeState;
        final capabilities = controller.userCapabilities;

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
                    Icons.assessment_rounded,
                    color: SpotifyTheme.pastelBlue,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Diagnostics & Capabilities',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: SpotifyTheme.textDarkPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Action Buttons
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: controller.isConnected
                        ? () {
                            unawaited(controller.getCrossfadeState());
                          }
                        : null,
                    icon: const Icon(Icons.graphic_eq_rounded),
                    label: const Text('Get Crossfade State'),
                  ),
                  OutlinedButton.icon(
                    onPressed: controller.isConnected
                        ? () {
                            unawaited(
                              controller.getCapabilities(
                                spotifyUri:
                                    'spotify:track:65xvfgI2nNrOYHhGUzw9XP',
                              ),
                            );
                          }
                        : null,
                    icon: const Icon(Icons.verified_user_rounded),
                    label: const Text('Get Capabilities'),
                  ),
                ],
              ),

              if (crossfade != null || capabilities != null) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: SpotifyTheme.backgroundLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (crossfade != null) ...[
                        Text(
                          'Crossfade: '
                          '${crossfade.isEnabled ? "Enabled" : "Disabled"}'
                          ' (${crossfade.duration}ms)',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: SpotifyTheme.textDarkPrimary,
                          ),
                        ),
                        if (capabilities != null) const SizedBox(height: 6),
                      ],
                      if (capabilities != null) ...[
                        Text(
                          'Capabilities: '
                          '${capabilities.canPlayOnDemand ? "On-Demand" : """
Restricted"""}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: SpotifyTheme.textDarkPrimary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
