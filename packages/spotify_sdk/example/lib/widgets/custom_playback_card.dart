import 'dart:async';

import 'package:flutter/material.dart';
import 'package:spotify_sdk_example/controllers/spotify_controller.dart';
import 'package:spotify_sdk_example/theme/spotify_theme.dart';

/// Card for testing custom URI play & queue requests with preset track buttons.
class CustomPlaybackCard extends StatefulWidget {
  /// Creates a [CustomPlaybackCard].
  const CustomPlaybackCard({
    required this.controller,
    super.key,
  });

  /// Spotify controller reference.
  final SpotifyController controller;

  @override
  State<CustomPlaybackCard> createState() => _CustomPlaybackCardState();
}

class _CustomPlaybackCardState extends State<CustomPlaybackCard> {
  final TextEditingController _uriTextController = TextEditingController(
    text: 'spotify:track:65xvfgI2nNrOYHhGUzw9XP',
  );

  final List<Map<String, String>> _presets = [
    {
      'label': 'Track 1 (Glass Animals - Heat Waves)',
      'uri': 'spotify:track:65xvfgI2nNrOYHhGUzw9XP',
    },
    {
      'label': 'Track 2 (The Killers - Mr. Brightside)',
      'uri': 'spotify:track:3n3Ppam7vgaVa1iaRUc9Lp',
    },
    {
      'label': "Playlist (Today's Top Hits)",
      'uri': 'spotify:playlist:37i9dQZF1DXcBWIGoYBM5M',
    },
  ];

  @override
  void dispose() {
    _uriTextController.dispose();
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
                Icons.play_circle_outline_rounded,
                color: SpotifyTheme.pastelMint,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Play & Queue Custom Spotify URIs',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: SpotifyTheme.textDarkPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Presets
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _presets.map((preset) {
              return ActionChip(
                avatar: const Icon(
                  Icons.music_note,
                  size: 14,
                  color: SpotifyTheme.pastelMint,
                ),
                label: Text(preset['label']!),
                backgroundColor: SpotifyTheme.backgroundLight,
                onPressed: () {
                  setState(() {
                    _uriTextController.text = preset['uri']!;
                  });
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 14),

          // TextField for Spotify URI
          TextField(
            controller: _uriTextController,
            decoration: InputDecoration(
              labelText: 'Spotify URI (track / album / playlist)',
              hintText: 'spotify:track:...',
              filled: true,
              fillColor: SpotifyTheme.backgroundLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: SpotifyTheme.borderLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: SpotifyTheme.pastelMint),
              ),
              prefixIcon: const Icon(
                Icons.link,
                color: SpotifyTheme.textDarkSecondary,
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Action Buttons: Play & Queue
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: widget.controller.isConnected
                      ? () {
                          final uri = _uriTextController.text.trim();
                          if (uri.isNotEmpty) {
                            unawaited(
                              widget.controller.play(spotifyUri: uri),
                            );
                          }
                        }
                      : null,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Play URI'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SpotifyTheme.pastelMint,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: widget.controller.isConnected
                      ? () {
                          final uri = _uriTextController.text.trim();
                          if (uri.isNotEmpty) {
                            unawaited(
                              widget.controller.queue(spotifyUri: uri),
                            );
                          }
                        }
                      : null,
                  icon: const Icon(
                    Icons.queue_music_rounded,
                    color: SpotifyTheme.pastelLavender,
                  ),
                  label: const Text('Add to Queue'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
