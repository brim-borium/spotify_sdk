import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spotify_sdk_platform_interface/platform_channels.dart';
import 'package:spotify_sdk_web/spotify_sdk_web.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SpotifySdkPlugin', () {
    late StreamController<String> playerContextController;
    late StreamController<String> playerStateController;
    late StreamController<String> capabilitiesController;
    late StreamController<String> userStatusController;
    late StreamController<String> connectionStatusController;
    late SpotifySdkPlugin plugin;

    setUp(() {
      playerContextController = StreamController<String>.broadcast();
      playerStateController = StreamController<String>.broadcast();
      capabilitiesController = StreamController<String>.broadcast();
      userStatusController = StreamController<String>.broadcast();
      connectionStatusController = StreamController<String>.broadcast();

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
