import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

void main() {
  const channel = MethodChannel('spotify_sdk');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      return true;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('connectToSpotify', () async {
    expect(
        await SpotifySdk.connectToSpotifyRemote(
            clientId: 'null', redirectUrl: 'null'),
        true);
  });
}
