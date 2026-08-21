import 'dart:async';

import 'package:flutter/material.dart';
import 'package:spotify_sdk_example/controllers/spotify_controller.dart';
import 'package:spotify_sdk_example/theme/spotify_theme.dart';

/// Card for testing Library API and Capabilities.
class LibraryCapabilitiesCard extends StatefulWidget {
  /// Creates a [LibraryCapabilitiesCard].
  const LibraryCapabilitiesCard({
    required this.controller,
    super.key,
  });

  /// Spotify controller reference.
  final SpotifyController controller;

  @override
  State<LibraryCapabilitiesCard> createState() =>
      _LibraryCapabilitiesCardState();
}

class _LibraryCapabilitiesCardState extends State<LibraryCapabilitiesCard> {
  final TextEditingController _targetUriController = TextEditingController(
    text: 'spotify:track:58kNJana4w5BIjlZE2wq5m',
  );

  @override
  void dispose() {
    _targetUriController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final libraryState = widget.controller.lastLibraryState;
    final capabilities = widget.controller.userCapabilities;

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
                Icons.video_library_rounded,
                color: SpotifyTheme.pastelCoral,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'User Library & Capabilities',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: SpotifyTheme.textDarkPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Target URI TextField
          TextField(
            controller: _targetUriController,
            decoration: InputDecoration(
              labelText: 'Target Track / Album URI',
              filled: true,
              fillColor: SpotifyTheme.backgroundLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: SpotifyTheme.borderLight),
              ),
              prefixIcon: const Icon(
                Icons.bookmark_outline,
                color: SpotifyTheme.textDarkSecondary,
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Library Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: widget.controller.isConnected
                      ? () {
                          final uri = _targetUriController.text.trim();
                          if (uri.isNotEmpty) {
                            unawaited(
                              widget.controller.addToLibrary(
                                spotifyUri: uri,
                              ),
                            );
                          }
                        }
                      : null,
                  icon: const Icon(
                    Icons.favorite_rounded,
                    color: Colors.white,
                  ),
                  label: const Text('Add to Library'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SpotifyTheme.pastelCoral,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: widget.controller.isConnected
                      ? () {
                          final uri = _targetUriController.text.trim();
                          if (uri.isNotEmpty) {
                            unawaited(
                              widget.controller.removeFromLibrary(
                                spotifyUri: uri,
                              ),
                            );
                          }
                        }
                      : null,
                  icon: const Icon(
                    Icons.favorite_border_rounded,
                    color: SpotifyTheme.errorPastel,
                  ),
                  label: const Text('Remove'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: widget.controller.isConnected
                      ? () {
                          final uri = _targetUriController.text.trim();
                          if (uri.isNotEmpty) {
                            unawaited(
                              widget.controller.getLibraryState(
                                spotifyUri: uri,
                              ),
                            );
                          }
                        }
                      : null,
                  icon: const Icon(
                    Icons.search_rounded,
                    color: SpotifyTheme.pastelLavender,
                  ),
                  label: const Text('Check Library State'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: widget.controller.isConnected
                      ? () {
                          final uri = _targetUriController.text.trim();
                          if (uri.isNotEmpty) {
                            unawaited(
                              widget.controller.getCapabilities(
                                spotifyUri: uri,
                              ),
                            );
                          }
                        }
                      : null,
                  icon: const Icon(
                    Icons.verified_user_rounded,
                    color: SpotifyTheme.pastelBlue,
                  ),
                  label: const Text('Get Capabilities'),
                ),
              ),
            ],
          ),

          if (libraryState != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: SpotifyTheme.backgroundLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    libraryState.isSaved
                        ? Icons.check_circle_rounded
                        : Icons.cancel_rounded,
                    color: libraryState.isSaved
                        ? SpotifyTheme.successPastel
                        : SpotifyTheme.errorPastel,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Saved: ${libraryState.isSaved} '
                    '(Can save: ${libraryState.canSave})',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: SpotifyTheme.textDarkPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (capabilities != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: SpotifyTheme.backgroundLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'User Capabilities:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: SpotifyTheme.textDarkSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Can Play On Demand: ${capabilities.canPlayOnDemand}',
                    style: const TextStyle(
                      fontSize: 12,
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
  }
}
