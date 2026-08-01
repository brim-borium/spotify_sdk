import 'dart:async';
import 'package:flutter/material.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:spotify_sdk_example/controllers/spotify_controller.dart';
import 'package:spotify_sdk_example/theme/spotify_theme.dart';

/// Interactive playback options control card.
class PlayerControlsBar extends StatefulWidget {
  /// Creates a [PlayerControlsBar].
  const PlayerControlsBar({
    required this.controller,
    super.key,
  });

  /// Spotify controller reference.
  final SpotifyController controller;

  @override
  State<PlayerControlsBar> createState() => _PlayerControlsBarState();
}

class _PlayerControlsBarState extends State<PlayerControlsBar> {
  double _draggedPosition = 0;
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        return StreamBuilder<PlayerState>(
          stream: widget.controller.playerStateStream,
          initialData: widget.controller.lastPlayerState,
          builder: (context, snapshot) {
            final playerState =
                widget.controller.lastPlayerState ?? snapshot.data;
            final track = playerState?.track;
            final options = playerState?.playbackOptions;

            final isShuffling = options?.isShuffling ?? false;
            final repeatMode = options?.repeatMode ?? SpotifyRepeatMode.off;
            final duration = (track?.duration ?? 0).toDouble();
            final currentPos = (playerState?.playbackPosition ?? 0).toDouble();

            final sliderValue = _isDragging
                ? _draggedPosition.clamp(0.0, duration > 0 ? duration : 1.0)
                : currentPos.clamp(0.0, duration > 0 ? duration : 1.0);

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
                        Icons.tune_rounded,
                        color: SpotifyTheme.pastelMint,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Playback Controls & Options',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: SpotifyTheme.textDarkPrimary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Shuffle & Repeat Row
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: widget.controller.isConnected
                              ? () => unawaited(
                                  widget.controller.toggleShuffle(),
                                )
                              : null,
                          icon: Icon(
                            Icons.shuffle_rounded,
                            color: isShuffling
                                ? SpotifyTheme.pastelMint
                                : SpotifyTheme.textDarkSecondary,
                          ),
                          label: Text(
                            isShuffling ? 'Shuffle: ON' : 'Shuffle: OFF',
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: isShuffling
                                  ? SpotifyTheme.pastelMint
                                  : SpotifyTheme.borderLight,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: widget.controller.isConnected
                              ? () =>
                                    unawaited(widget.controller.toggleRepeat())
                              : null,
                          icon: Icon(
                            repeatMode == SpotifyRepeatMode.off
                                ? Icons.repeat_rounded
                                : (repeatMode == SpotifyRepeatMode.track
                                      ? Icons.repeat_one_rounded
                                      : Icons.repeat_on_rounded),
                            color: repeatMode != SpotifyRepeatMode.off
                                ? SpotifyTheme.pastelLavender
                                : SpotifyTheme.textDarkSecondary,
                          ),
                          label: Text(
                            'Repeat: ${repeatMode.name.toUpperCase()}',
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: repeatMode != SpotifyRepeatMode.off
                                  ? SpotifyTheme.pastelLavender
                                  : SpotifyTheme.borderLight,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Position Seek Slider
                  const Text(
                    'Position Seek',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: SpotifyTheme.textDarkSecondary,
                    ),
                  ),
                  Slider(
                    value: sliderValue,
                    max: duration > 0 ? duration : 1.0,
                    activeColor: SpotifyTheme.pastelMint,
                    inactiveColor: SpotifyTheme.backgroundLight,
                    onChangeStart: (val) {
                      setState(() {
                        _isDragging = true;
                        _draggedPosition = val;
                      });
                    },
                    onChanged: (val) {
                      setState(() {
                        _draggedPosition = val;
                      });
                    },
                    onChangeEnd: (val) {
                      if (widget.controller.isConnected) {
                        unawaited(
                          widget.controller.seekTo(val.toInt()).then((_) {
                            if (mounted) {
                              setState(() {
                                _isDragging = false;
                              });
                            }
                          }),
                        );
                      } else {
                        setState(() {
                          _isDragging = false;
                        });
                      }
                    },
                  ),

                  // Relative Seek Buttons (+/- 15 seconds)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OutlinedButton.icon(
                        onPressed: widget.controller.isConnected
                            ? () => unawaited(
                                widget.controller.seekToRelative(-15000),
                              )
                            : null,
                        icon: const Icon(Icons.replay_10_rounded),
                        label: const Text('-15s'),
                      ),
                      OutlinedButton.icon(
                        onPressed: widget.controller.isConnected
                            ? () => unawaited(
                                widget.controller.seekToRelative(15000),
                              )
                            : null,
                        icon: const Icon(Icons.forward_10_rounded),
                        label: const Text('+15s'),
                      ),
                    ],
                  ),

                  if (track?.isPodcast ?? false) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Podcast Playback Speed',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: SpotifyTheme.textDarkSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildSpeedChip(
                          '0.5x',
                          PodcastPlaybackSpeed.playbackSpeed_50,
                          playerState,
                        ),
                        _buildSpeedChip(
                          '1.0x',
                          PodcastPlaybackSpeed.playbackSpeed_100,
                          playerState,
                        ),
                        _buildSpeedChip(
                          '1.2x',
                          PodcastPlaybackSpeed.playbackSpeed_120,
                          playerState,
                        ),
                        _buildSpeedChip(
                          '1.5x',
                          PodcastPlaybackSpeed.playbackSpeed_150,
                          playerState,
                        ),
                        _buildSpeedChip(
                          '2.0x',
                          PodcastPlaybackSpeed.playbackSpeed_200,
                          playerState,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSpeedChip(
    String label,
    PodcastPlaybackSpeed speed,
    PlayerState? playerState,
  ) {
    return ChoiceChip(
      label: Text(label),
      selected: playerState?.playbackSpeed == speed.value,
      onSelected: widget.controller.isConnected
          ? (_) => unawaited(
              widget.controller.setPodcastPlaybackSpeed(speed),
            )
          : null,
      selectedColor: SpotifyTheme.pastelLavender.withValues(alpha: 0.3),
      backgroundColor: SpotifyTheme.backgroundLight,
    );
  }
}
