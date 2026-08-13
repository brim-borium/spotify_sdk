import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:spotify_sdk_platform_interface/spotify_sdk_platform_interface.dart';
import 'package:spotify_sdk_web/src/auth/spotify_auth_session.dart';
import 'package:spotify_sdk_web/src/player/web_player_dispatcher.dart';
import 'package:spotify_sdk_web/src/player/web_player_manager.dart';

void main() {
  group('WebPlayerManager', () {
    late StreamController<PlayerContext> playerContextController;
    late StreamController<PlayerState> playerStateController;
    late StreamController<ConnectionStatus> connectionStatusController;
    late WebPlayerDispatcher dispatcher;
    late WebPlayerManager manager;

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

      manager = WebPlayerManager(
        authSession: SpotifyAuthSession(),
        playerDispatcher: dispatcher,
      );
    });

    tearDown(() async {
      await playerContextController.close();
      await playerStateController.close();
      await connectionStatusController.close();
    });

    test('initial state has null deviceId and currentPlayer', () {
      expect(manager.currentPlayer, isNull);
      expect(manager.deviceId, isNull);
    });

    test(
      'handleConnected resolves device ID on active player manager',
      () async {
        manager.handleConnected('test-device-123');
        expect(manager.deviceId, equals('test-device-123'));
      },
    );

    test('disconnect resets active player state cleanly', () {
      manager
        ..handleConnected('test-device-123')
        ..disconnect();
      expect(manager.currentPlayer, isNull);
      expect(manager.deviceId, isNull);
    });
  });
}
