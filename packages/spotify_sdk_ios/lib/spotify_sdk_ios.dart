import 'package:spotify_sdk_platform_interface/spotify_sdk_platform_interface.dart';

/// The iOS implementation of [SpotifySdkPlatform].
class SpotifySdkIOS extends MethodChannelSpotifySdk {
  /// Registers this class as the default instance of [SpotifySdkPlatform].
  static void registerWith() {
    SpotifySdkPlatform.instance = SpotifySdkIOS();
  }
}
