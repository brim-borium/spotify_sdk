import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spotify_sdk_platform_interface/platform_channels.dart';
import 'package:spotify_sdk_platform_interface/spotify_sdk_platform_interface.dart';
import 'package:spotify_sdk_web/spotify_sdk_web.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SpotifySdkPlugin', () {
    late StreamController<PlayerContext> playerContextController;
    late StreamController<PlayerState> playerStateController;
    late StreamController<Capabilities> capabilitiesController;
    late StreamController<UserStatus> userStatusController;
    late StreamController<ConnectionStatus> connectionStatusController;
    late SpotifySdkPlugin plugin;

    setUp(() {
      playerContextController = StreamController<PlayerContext>.broadcast();
      playerStateController = StreamController<PlayerState>.broadcast();
      capabilitiesController = StreamController<Capabilities>.broadcast();
      userStatusController = StreamController<UserStatus>.broadcast();
      connectionStatusController =
          StreamController<ConnectionStatus>.broadcast();

      plugin = SpotifySdkPlugin(
        playerContextController,
        playerStateController,
        capabilitiesController,
        userStatusController,
        connectionStatusController,
      );
    });

    tearDown(() async {
      await playerContextController.close();
      await playerStateController.close();
      await capabilitiesController.close();
      await userStatusController.close();
      await connectionStatusController.close();
    });

    test('registerWith sets SpotifySdkPlatform instance', () {
      expect(SpotifySdkPlugin.tokenSwapURL, isNull);
      expect(SpotifySdkPlugin.tokenRefreshURL, isNull);
    });

    test('typed stream subscriptions return expected stream instances', () {
      expect(plugin.subscribePlayerContext(), isA<Stream<PlayerContext>>());
      expect(plugin.subscribePlayerState(), isA<Stream<PlayerState>>());
      expect(plugin.subscribeCapabilities(), isA<Stream<Capabilities>>());
      expect(plugin.subscribeUserStatus(), isA<Stream<UserStatus>>());
      expect(
        plugin.subscribeConnectionStatus(),
        isA<Stream<ConnectionStatus>>(),
      );
    });

    test('handleMethodCall throws PlatformException for unknown method', () {
      expect(
        () => plugin.handleMethodCall(
          const MethodCall('unimplementedMethod'),
        ),
        throwsA(isA<PlatformException>()),
      );
    });

    test(
      'handleMethodCall throws PlatformException when client ID missing',
      () {
        expect(
          () => plugin.handleMethodCall(
            const MethodCall(MethodNames.connectToSpotify, {
              ParamNames.clientId: '',
              ParamNames.redirectUrl: '',
            }),
          ),
          throwsA(isA<PlatformException>()),
        );
      },
    );
  });
}
