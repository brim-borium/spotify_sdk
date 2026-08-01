import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spotify_sdk_platform_interface/src/platform_channel_gateway.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PlatformChannelGateway', () {
    const channel = MethodChannel('spotify_sdk');
    late PlatformChannelGateway gateway;

    setUp(() {
      gateway = PlatformChannelGateway(methodChannel: channel);
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('invoke returns direct value when no decoder provided', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (methodCall) async {
            if (methodCall.method == 'testMethod') {
              return 'hello';
            }
            return null;
          });

      final result = await gateway.invoke<String>('testMethod');
      expect(result, 'hello');
    });

    test('invoke decodes JSON string when decoder provided', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (methodCall) async {
            if (methodCall.method == 'getJson') {
              return jsonEncode({'key': 'value'});
            }
            return null;
          });

      final result = await gateway.invoke<Map<String, dynamic>>(
        'getJson',
        decode: (json) => json as Map<String, dynamic>,
      );

      expect(result, {'key': 'value'});
    });

    test('invoke rethrows PlatformException on error', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (methodCall) async {
            throw PlatformException(code: 'TEST_ERROR', message: 'Failed');
          });

      expect(
        () => gateway.invoke<bool>('failMethod'),
        throwsA(isA<PlatformException>()),
      );
    });
  });
}
