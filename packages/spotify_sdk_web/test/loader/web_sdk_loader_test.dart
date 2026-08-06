import 'package:flutter_test/flutter_test.dart';
import 'package:spotify_sdk_web/src/loader/web_sdk_loader.dart';

void main() {
  group('WebSdkLoader', () {
    late WebSdkLoader loader;

    setUp(() {
      loader = WebSdkLoader();
    });

    test('initial loader state is not loaded', () {
      expect(loader.isLoaded, isFalse);
    });
  });
}
