import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:spotify_sdk_platform_interface/spotify_sdk_platform_interface.dart';
import 'package:spotify_sdk_web/src/player/web_player_dispatcher.dart';

void main() {
  group('WebPlayerDispatcher', () {
    late StreamController<PlayerContext> playerContextController;
    late StreamController<PlayerState> playerStateController;
    late StreamController<ConnectionStatus> connectionStatusController;
    late WebPlayerDispatcher dispatcher;

    setUp(() {
      playerContextController = StreamController<PlayerContext>.broadcast();
      playerStateController = StreamController<PlayerState>.broadcast();
      connectionStatusController =
          StreamController<ConnectionStatus>.broadcast();

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
