import 'dart:async';

import 'package:flutter/material.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:spotify_sdk_example/controllers/spotify_controller.dart';
import 'package:spotify_sdk_example/theme/spotify_theme.dart';

/// Card for testing advanced playback features.
class AdvancedPlaybackCard extends StatefulWidget {
  /// Creates an [AdvancedPlaybackCard].
  const AdvancedPlaybackCard({
    required this.controller,
    super.key,
  });

  /// Reference to [SpotifyController].
  final SpotifyController controller;

  @override
  State<AdvancedPlaybackCard> createState() => _AdvancedPlaybackCardState();
}

class _AdvancedPlaybackCardState extends State<AdvancedPlaybackCard> {
  final TextEditingController _indexController = TextEditingController(
    text: '0',
  );
  final TextEditingController _contextUriController = TextEditingController(
    text: 'spotify:playlist:37i9dQZF1DXcBWIGoYBM5M',
  );

  @override
  void dispose() {
    _indexController.dispose();
    _contextUriController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                color: SpotifyTheme.pastelLavender,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Advanced Playback Controls',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: SpotifyTheme.textDarkPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 1. Relative Seek (-15s / +15s)
          const Text(
            'Relative Seek',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: SpotifyTheme.textDarkSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: widget.controller.isConnected
                      ? () {
                          unawaited(widget.controller.seekToRelative(-15000));
                        }
                      : null,
                  icon: const Icon(Icons.fast_rewind_rounded),
                  label: const Text('-15 sec'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: widget.controller.isConnected
                      ? () {
                          unawaited(widget.controller.seekToRelative(15000));
                        }
                      : null,
                  icon: const Icon(Icons.fast_forward_rounded),
                  label: const Text('+15 sec'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 2. Skip to Track Index
          const Text(
            'Skip to Index in Playlist/Album',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: SpotifyTheme.textDarkSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _contextUriController,
                  decoration: InputDecoration(
                    labelText: 'Context URI',
                    isDense: true,
                    filled: true,
                    fillColor: SpotifyTheme.backgroundLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _indexController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Index',
                    isDense: true,
                    filled: true,
                    fillColor: SpotifyTheme.backgroundLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  backgroundColor: SpotifyTheme.pastelLavender,
                ),
                onPressed: widget.controller.isConnected
                    ? () {
                        final uri = _contextUriController.text.trim();
                        final index = int.tryParse(_indexController.text) ?? 0;
                        if (uri.isNotEmpty) {
                          unawaited(
                            widget.controller.skipToIndex(
                              spotifyUri: uri,
                              index: index,
                            ),
                          );
                        }
                      }
                    : null,
                child: const Text('Go'),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 3. Podcast Speed
          const Text(
            'Podcast Playback Speed',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: SpotifyTheme.textDarkSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            children: [
              _buildSpeedChip('1.0x', PodcastPlaybackSpeed.playbackSpeed_100),
              _buildSpeedChip('1.2x', PodcastPlaybackSpeed.playbackSpeed_120),
              _buildSpeedChip('1.5x', PodcastPlaybackSpeed.playbackSpeed_150),
              _buildSpeedChip('2.0x', PodcastPlaybackSpeed.playbackSpeed_200),
            ],
          ),

          const SizedBox(height: 16),

          // 4. Switch to Local Device
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: widget.controller.isConnected
                  ? () {
                      unawaited(widget.controller.switchToLocalDevice());
                    }
                  : null,
              icon: const Icon(Icons.phonelink_rounded),
              label: const Text('Switch Playback to Local Device'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedChip(String label, PodcastPlaybackSpeed speed) {
    return ActionChip(
      label: Text(label),
      backgroundColor: SpotifyTheme.backgroundLight,
      onPressed: widget.controller.isConnected
          ? () {
              unawaited(
                widget.controller.setPodcastPlaybackSpeed(speed),
              );
            }
          : null,
    );
  }
}
