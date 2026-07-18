import 'package:spotify_sdk_platform_interface/spotify_sdk_platform_interface.dart';

/// The Android implementation of [SpotifySdkPlatform].
class SpotifySdkAndroid extends MethodChannelSpotifySdk {
  /// Registers this class as the default instance of [SpotifySdkPlatform].
  static void registerWith() {
    SpotifySdkPlatform.instance = SpotifySdkAndroid();
  }
}
