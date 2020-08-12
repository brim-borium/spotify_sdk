import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

void main() {
  const channel = MethodChannel('spotify_sdk');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return true;
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('connectToSpotify', () async {
    expect(
        await SpotifySdk.connectToSpotifyRemote(
            clientId: 'null', redirectUrl: 'null'),
        true);
  });
}
