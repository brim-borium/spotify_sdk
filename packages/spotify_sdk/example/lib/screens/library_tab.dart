import 'package:flutter/material.dart';
import 'package:spotify_sdk_example/controllers/spotify_controller.dart';
import 'package:spotify_sdk_example/widgets/library_capabilities_card.dart';

/// Tab for managing User Library and Capabilities.
class LibraryTab extends StatelessWidget {
  /// Creates a [LibraryTab].
  const LibraryTab({
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
        LibraryCapabilitiesCard(controller: controller),
      ],
    );
  }
}
