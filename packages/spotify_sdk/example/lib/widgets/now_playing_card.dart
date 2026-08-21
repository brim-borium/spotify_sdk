import 'dart:async';

import 'package:flutter/material.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:spotify_sdk_example/controllers/spotify_controller.dart';
import 'package:spotify_sdk_example/theme/spotify_theme.dart';

/// A card displaying current playing track information and album artwork.
class NowPlayingCard extends StatelessWidget {
  /// Creates a [NowPlayingCard].
  const NowPlayingCard({
    required this.controller,
    super.key,
  });

  /// Spotify controller reference.
  final SpotifyController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return StreamBuilder<PlayerState>(
          stream: controller.playerStateStream,
          initialData: controller.lastPlayerState,
          builder: (context, snapshot) {
            final playerState = controller.lastPlayerState ?? snapshot.data;
            final track = playerState?.track;

            if (!controller.isConnected ||
                playerState == null ||
                track == null) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: SpotifyTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: SpotifyTheme.borderLight),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: SpotifyTheme.pastelLavender.withValues(
                          alpha: 0.2,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.music_off_rounded,
                        size: 40,
                        color: SpotifyTheme.pastelLavender,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No Track Playing',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: SpotifyTheme.textDarkPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      controller.isConnected
                          ? 'Start playback on Spotify app or select '
                                'a preset URI.'
                          : 'Connect to Spotify Remote to inspect '
                                'active playback.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: SpotifyTheme.textDarkSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }

            final duration = track.duration;
            final position = playerState.playbackPosition;
            final progress = (duration > 0)
                ? (position / duration).clamp(0.0, 1.0)
                : 0.0;

            return Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: SpotifyTheme.surfaceWhite,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: SpotifyTheme.borderLight),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Accent Banner
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: const BoxDecoration(
                      gradient: SpotifyTheme.heroGradient,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.graphic_eq,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              playerState.isPaused ? 'PAUSED' : 'NOW PLAYING',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                        if (track.isPodcast)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'PODCAST',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Artwork with SpotifySdk.getImage loader
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                width: 90,
                                height: 90,
                                color: SpotifyTheme.backgroundLight,
                                child: FutureBuilder(
                                  future: SpotifySdk.getImage(
                                    imageUri: track.imageUri,
                                  ),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData &&
                                        snapshot.data != null) {
                                      return Image.memory(
                                        snapshot.data!,
                                        fit: BoxFit.cover,
                                      );
                                    }
                                    if (snapshot.hasError) {
                                      return const Center(
                                        child: Icon(
                                          Icons.broken_image,
                                          color: SpotifyTheme.textDarkSecondary,
                                        ),
                                      );
                                    }
                                    return const Center(
                                      child: SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: SpotifyTheme.pastelMint,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    track.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: SpotifyTheme.textDarkPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    track.artist.name ?? 'Unknown Artist',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: SpotifyTheme.pastelMint,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    track.album.name ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: SpotifyTheme.textDarkSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Live Position Progress Bar
                        Column(
                          children: [
                            LinearProgressIndicator(
                              value: progress,
                              backgroundColor: SpotifyTheme.backgroundLight,
                              color: SpotifyTheme.pastelMint,
                              minHeight: 6,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDuration(position),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: SpotifyTheme.textDarkSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  _formatDuration(duration),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: SpotifyTheme.textDarkSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Quick Playback Controls
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              onPressed: () =>
                                  unawaited(controller.skipPrevious()),
                              icon: const Icon(Icons.skip_previous_rounded),
                              iconSize: 32,
                              color: SpotifyTheme.textDarkPrimary,
                            ),
                            IconButton(
                              onPressed: () {
                                if (playerState.isPaused) {
                                  unawaited(controller.resume());
                                } else {
                                  unawaited(controller.pause());
                                }
                              },
                              icon: Icon(
                                playerState.isPaused
                                    ? Icons.play_circle_filled_rounded
                                    : Icons.pause_circle_filled_rounded,
                              ),
                              iconSize: 52,
                              color: SpotifyTheme.pastelMint,
                            ),
                            IconButton(
                              onPressed: () => unawaited(controller.skipNext()),
                              icon: const Icon(Icons.skip_next_rounded),
                              iconSize: 32,
                              color: SpotifyTheme.textDarkPrimary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _formatDuration(int ms) {
    final duration = Duration(milliseconds: ms);
    final minutes = duration.inMinutes;
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
