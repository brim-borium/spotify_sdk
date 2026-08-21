import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:spotify_sdk_example/controllers/spotify_controller.dart';
import 'package:spotify_sdk_example/screens/home_screen.dart';
import 'package:spotify_sdk_example/theme/spotify_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  runApp(const SpotifySdkApp());
}

/// The root application widget for Spotify SDK Example.
class SpotifySdkApp extends StatefulWidget {
  /// Constructor for [SpotifySdkApp].
  const SpotifySdkApp({super.key});

  @override
  State<SpotifySdkApp> createState() => _SpotifySdkAppState();
}

class _SpotifySdkAppState extends State<SpotifySdkApp> {
  late final SpotifyController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SpotifyController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return MaterialApp(
          title: 'Spotify SDK Example',
          debugShowCheckedModeBanner: false,
          theme: SpotifyTheme.lightTheme,
          home: HomeScreen(controller: _controller),
        );
      },
    );
  }
}
