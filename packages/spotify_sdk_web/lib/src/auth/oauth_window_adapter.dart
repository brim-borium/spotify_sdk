import 'dart:async';
import 'dart:js_interop';

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
  /// Checks if the current window is an OAuth popup child window (opened via
  /// `window.opener`) and posts the callback query parameter payload back to
  /// the opener before closing itself.
  static void handlePopupCallback() {
    try {
      final search = web.window.location.search;
      if (web.window.opener != null &&
          (search.contains('code=') || search.contains('error='))) {
        (web.window.opener as web.Window?)?.postMessage(search.toJS, '*'.toJS);
        web.window.close();
      }
    } on Object catch (_) {
      // Ignore cross-origin or non-window opener errors gracefully
    }
  }

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
        try {
          final jsData = event.data;
          if (jsData != null) {
            String? data;
            try {
              data = (jsData as JSString).toDart;
            } on Object catch (_) {
              data = jsData.toString();
            }
            if (data.contains('code=') || data.contains('error=')) {
              message = data;
            }
          }
        } on Object catch (_) {
          // Ignore non-string or external message events
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

    final Uri parsedMessage;
    final rawMessage = message!;
    if (rawMessage.startsWith('http://') || rawMessage.startsWith('https://')) {
      parsedMessage = Uri.parse(rawMessage);
    } else {
      parsedMessage = Uri.parse(
        'http://localhost/${rawMessage.startsWith('?') ? rawMessage : '?$rawMessage'}',
      );
    }

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
