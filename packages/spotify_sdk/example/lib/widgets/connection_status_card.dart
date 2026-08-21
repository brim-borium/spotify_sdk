import 'dart:async';

import 'package:flutter/material.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:spotify_sdk_example/controllers/spotify_controller.dart';
import 'package:spotify_sdk_example/theme/spotify_theme.dart';

/// Card managing Spotify Remote Connection and Auth Token acquisition.
class ConnectionStatusCard extends StatelessWidget {
  /// Creates a [ConnectionStatusCard].
  const ConnectionStatusCard({
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
        final status = snapshot.data ?? controller.lastConnectionStatus;
        final token = controller.accessToken;

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.settings_remote_rounded,
                        color: SpotifyTheme.pastelBlue,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Remote Connection & Auth',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: SpotifyTheme.textDarkPrimary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isConnected
                          ? SpotifyTheme.successPastel.withValues(alpha: 0.15)
                          : SpotifyTheme.errorPastel.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isConnected
                            ? SpotifyTheme.successPastel
                            : SpotifyTheme.errorPastel,
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 4,
                          backgroundColor: isConnected
                              ? SpotifyTheme.successPastel
                              : SpotifyTheme.errorPastel,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isConnected ? 'CONNECTED' : 'DISCONNECTED',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: isConnected
                                ? SpotifyTheme.successPastel
                                : SpotifyTheme.errorPastel,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Connect / Disconnect Buttons
              Row(
                children: [
                  if (!isConnected)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: controller.isLoading
                            ? null
                            : () => unawaited(
                                controller.connectToSpotifyRemote(),
                              ),
                        icon: const Icon(Icons.cast_connected_rounded),
                        label: const Text('Connect Remote'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SpotifyTheme.pastelMint,
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: controller.isLoading
                            ? null
                            : () => unawaited(controller.disconnect()),
                        icon: const Icon(
                          Icons.power_settings_new_rounded,
                          color: SpotifyTheme.errorPastel,
                        ),
                        label: const Text('Disconnect'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: SpotifyTheme.errorPastel,
                          side: const BorderSide(
                            color: SpotifyTheme.errorPastel,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: controller.isLoading
                          ? null
                          : () => unawaited(controller.getAccessToken()),
                      icon: const Icon(
                        Icons.key_rounded,
                        color: SpotifyTheme.pastelLavender,
                      ),
                      label: const Text('Get Auth Token'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: controller.isLoading
                          ? null
                          : () => unawaited(controller.getSwapToken()),
                      icon: const Icon(
                        Icons.swap_horiz_rounded,
                        color: SpotifyTheme.pastelBlue,
                      ),
                      label: const Text('Get Swap Token'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: controller.isLoading
                          ? null
                          : () =>
                                unawaited(controller.checkIsSpotifyInstalled()),
                      icon: const Icon(
                        Icons.phone_android_rounded,
                        color: SpotifyTheme.pastelMint,
                      ),
                      label: const Text('Check Installed'),
                    ),
                  ),
                ],
              ),

              if (!isConnected && status != null && status.message != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: SpotifyTheme.pastelYellow.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: SpotifyTheme.pastelYellow,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            size: 16,
                            color: SpotifyTheme.textDarkPrimary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            status.errorCode ?? 'Connection Status',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: SpotifyTheme.textDarkPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        status.message!,
                        style: const TextStyle(
                          fontSize: 11,
                          color: SpotifyTheme.textDarkSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              if (token != null && token.isNotEmpty) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: SpotifyTheme.backgroundLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: SpotifyTheme.borderLight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.lock_open_rounded,
                            size: 14,
                            color: SpotifyTheme.pastelMint,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Active Access Token:',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: SpotifyTheme.textDarkSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        token,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontFamily: 'monospace',
                          color: SpotifyTheme.textDarkPrimary,
                        ),
                      ),
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
