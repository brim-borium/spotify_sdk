import 'dart:async';
import 'package:flutter/services.dart';
import 'package:web/web.dart' as web;

/// Interface for launching the Spotify authorization popup window.
// ignore: one_member_abstracts
abstract class OAuthWindowAdapter {
  /// Opens popup to [authorizationUri] and returns
  /// the OAuth response query string.
  Future<String> requestAuthCode({
    required Uri authorizationUri,
    required String expectedState,
  });
}

/// Production implementation of [OAuthWindowAdapter] using `web.window.open`.
class BrowserWindowAdapter implements OAuthWindowAdapter {
  @override
  Future<String> requestAuthCode({
    required Uri authorizationUri,
    required String expectedState,
  }) async {
    final authPopup = web.window.open(
      authorizationUri.toString(),
      'Spotify Authorization',
    );

    String? message;
    final sub = web.window.onMessage.listen(
      (event) {
        final data = event.data.toString();
        if (data.startsWith('?code=')) {
          message = data;
        }
      },
    );

    while (authPopup?.closed != true && message == null) {
      await Future<void>.delayed(const Duration(milliseconds: 250));
    }

    if (message == null) {
      await sub.cancel();
      throw PlatformException(
        message: 'User closed authentication window',
        code: 'Authentication Error',
      );
    }

    final parsedMessage = Uri.parse(message!);
    await sub.cancel();

    if (authPopup?.closed != true) {
      authPopup?.close();
    }

    if (expectedState != parsedMessage.queryParameters['state']) {
      throw PlatformException(
        message: 'Invalid state',
        code: 'Authentication Error',
      );
    }

    if (parsedMessage.queryParameters['error'] != null ||
        parsedMessage.queryParameters['code'] == null) {
      throw PlatformException(
        message: '${parsedMessage.queryParameters['error']}',
        code: 'Authentication Error',
      );
    }

    return parsedMessage.queryParameters['code']!;
  }
}

/// Fake implementation of [OAuthWindowAdapter] for testing.
class FakeWindowAdapter implements OAuthWindowAdapter {
  /// Creates a [FakeWindowAdapter].
  FakeWindowAdapter({this.authCodeToReturn = 'mock_auth_code'});

  /// Auth code to return automatically.
  final String authCodeToReturn;

  @override
  Future<String> requestAuthCode({
    required Uri authorizationUri,
    required String expectedState,
  }) async {
    return authCodeToReturn;
  }
}
