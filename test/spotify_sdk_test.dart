import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spotify_sdk/models/crossfade_state.dart';
import 'package:spotify_sdk/platform_channels.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

void main() {
  const channel = MethodChannel(MethodChannels.spotifySdk);

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {});

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  void setupMethodCall(String methodCall) {
    channel.setMockMethodCallHandler((call) async {
      switch (call.method) {
        case MethodNames.connectToSpotify:
          return true;
        case MethodNames.getAuthenticationToken:
          return MethodNames.getAuthenticationToken;
        case MethodNames.getCrossfadeState:
          var crossfadeState = CrossfadeState(12, isEnabled: true);
          var json = jsonEncode(crossfadeState);
          return json;
      }
    });
  }

  group(MethodNames.connectToSpotify, () {
    test('withValidArguments', () async {
      setupMethodCall(MethodNames.connectToSpotify);

      expect(
          await SpotifySdk.connectToSpotifyRemote(
              clientId: "089d841ccc194c10a77afad9e1c11d54",
              redirectUrl: "comspotifytestsdk://callback"),
          true);
    });
  });

  group(MethodNames.getAuthenticationToken, () {
    test('withValidArguments', () async {
      setupMethodCall(MethodNames.getAuthenticationToken);

      expect(
          await SpotifySdk.getAuthenticationToken(
              clientId: "089d841ccc194c10a77afad9e1c11d54",
              redirectUrl: "comspotifytestsdk://callback",
              scope: ""),
          MethodNames.getAuthenticationToken);
    });
  });

  group(MethodNames.getCrossfadeState, () {
    test('withValidArguments', () async {
      setupMethodCall(MethodNames.getCrossfadeState);
      var crossfadeState = await SpotifySdk.getCrossFadeState();
      expect(crossfadeState, isA<CrossfadeState>());
      expect(crossfadeState.duration, 12);
      expect(crossfadeState.isEnabled, true);
    });
  });
}
