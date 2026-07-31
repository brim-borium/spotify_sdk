import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:spotify_sdk_web/src/player/web_player_dispatcher.dart';

void main() {
  group('WebPlayerDispatcher', () {
    late StreamController<String> playerContextController;
    late StreamController<String> playerStateController;
    late StreamController<String> connectionStatusController;
    late WebPlayerDispatcher dispatcher;

    setUp(() {
      playerContextController = StreamController<String>.broadcast();
      playerStateController = StreamController<String>.broadcast();
      connectionStatusController = StreamController<String>.broadcast();

      dispatcher = WebPlayerDispatcher(
        playerContextEventController: playerContextController,
        playerStateEventController: playerStateController,
        connectionStatusEventController: connectionStatusController,
        onSpotifyConnected: (_) {},
        onSpotifyDisconnected: ({errorCode, errorDetails}) {},
      );
    });

    tearDown(() async {
      await playerContextController.close();
      await playerStateController.close();
      await connectionStatusController.close();
    });

    test('toPlayerState returns null when input state is null', () {
      expect(dispatcher.toPlayerState(null), isNull);
    });

    test('toPlayerContext returns null when input state is null', () {
      expect(dispatcher.toPlayerContext(null), isNull);
    });
  });
}
