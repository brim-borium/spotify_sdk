import 'dart:async';

import 'package:flutter/material.dart';
import 'package:spotify_sdk_example/controllers/spotify_controller.dart';
import 'package:spotify_sdk_example/theme/spotify_theme.dart';

/// Card for interacting with Spotify User Library APIs.
class LibraryCard extends StatefulWidget {
  /// Creates a [LibraryCard].
  const LibraryCard({
    required this.controller,
    super.key,
  });

  /// Reference to [SpotifyController].
  final SpotifyController controller;

  @override
  State<LibraryCard> createState() => _LibraryCardState();
}

class _LibraryCardState extends State<LibraryCard> {
  final TextEditingController _uriController = TextEditingController(
    text: 'spotify:track:65xvfgI2nNrOYHhGUzw9XP',
  );

  @override
  void dispose() {
    _uriController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final currentTrackUri = widget.controller.lastPlayerState?.track?.uri;
        final libraryState = widget.controller.lastLibraryState;

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
                children: [
                  const Icon(
                    Icons.favorite_rounded,
                    color: Colors.redAccent,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'User Library & Saved Tracks',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: SpotifyTheme.textDarkPrimary,
                    ),
                  ),
                  const Spacer(),
                  if (currentTrackUri != null && currentTrackUri.isNotEmpty)
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      onPressed: () {
                        setState(() {
                          _uriController.text = currentTrackUri;
                        });
                      },
                      icon: const Icon(Icons.my_location, size: 14),
                      label: const Text('Use Playing'),
                    ),
                ],
              ),
              const SizedBox(height: 14),

              // URI TextField
              TextField(
                controller: _uriController,
                decoration: InputDecoration(
                  labelText: 'Spotify Track URI',
                  hintText: 'spotify:track:...',
                  filled: true,
                  fillColor: SpotifyTheme.backgroundLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: SpotifyTheme.borderLight,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: SpotifyTheme.pastelMint,
                    ),
                  ),
                  prefixIcon: const Icon(
                    Icons.music_note,
                    color: SpotifyTheme.textDarkSecondary,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Action Buttons: Add, Remove, Check
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton.icon(
                    onPressed: widget.controller.isConnected
                        ? () {
                            final uri = _uriController.text.trim();
                            if (uri.isNotEmpty) {
                              unawaited(
                                widget.controller.addToLibrary(
                                  spotifyUri: uri,
                                ),
                              );
                            }
                          }
                        : null,
                    icon: const Icon(Icons.favorite, color: Colors.redAccent),
                    label: const Text('Add to Library'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SpotifyTheme.backgroundLight,
                      foregroundColor: SpotifyTheme.textDarkPrimary,
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: widget.controller.isConnected
                        ? () {
                            final uri = _uriController.text.trim();
                            if (uri.isNotEmpty) {
                              unawaited(
                                widget.controller.removeFromLibrary(
                                  spotifyUri: uri,
                                ),
                              );
                            }
                          }
                        : null,
                    icon: const Icon(Icons.favorite_border),
                    label: const Text('Remove'),
                  ),
                  OutlinedButton.icon(
                    onPressed: widget.controller.isConnected
                        ? () {
                            final uri = _uriController.text.trim();
                            if (uri.isNotEmpty) {
                              unawaited(
                                widget.controller.getLibraryState(
                                  spotifyUri: uri,
                                ),
                              );
                            }
                          }
                        : null,
                    icon: const Icon(Icons.search_rounded),
                    label: const Text('Check Status'),
                  ),
                ],
              ),

              if (libraryState != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: SpotifyTheme.backgroundLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        libraryState.isSaved
                            ? Icons.check_circle_rounded
                            : Icons.info_outline_rounded,
                        color: libraryState.isSaved
                            ? SpotifyTheme.pastelMint
                            : SpotifyTheme.textDarkSecondary,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          libraryState.isSaved
                              ? 'Item is saved in User Library'
                              : 'Item is not saved in User Library',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: SpotifyTheme.textDarkPrimary,
                          ),
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
