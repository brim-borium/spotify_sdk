import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:spotify_sdk_platform_interface/exceptions/spotify_exceptions.dart';
import 'package:spotify_sdk_platform_interface/logging/logger.dart';

/// Gateway encapsulating method channels, event channels,
/// deserialization, and logging.
class PlatformChannelGateway {
  /// Creates a [PlatformChannelGateway].
  PlatformChannelGateway({
    MethodChannel? methodChannel,
    Logger? logger,
  }) : _channel = methodChannel ?? const MethodChannel('spotify_sdk'),
       _logger = logger ?? Logger();

  final MethodChannel _channel;
  final Logger _logger;
  final Map<String, EventChannel> _eventChannels = {};

  EventChannel _getEventChannel(String channelName) =>
      _eventChannels.putIfAbsent(
        channelName,
        () => EventChannel(channelName),
      );

  /// Invokes a method channel call expecting no return payload.
  Future<void> invokeVoid(
    String method, {
    Map<String, dynamic>? arguments,
  }) async {
    await invoke<void>(method, arguments: arguments);
  }

  /// Invokes a method channel call that returns a JSON object,
  /// decoding it into [T] via [decode].
  Future<T?> invokeJson<T>(
    String method, {
    required T Function(Map<String, dynamic> json) decode,
    Map<String, dynamic>? arguments,
  }) async {
    return invoke<T>(
      method,
      arguments: arguments,
      decode: (raw) => decode(raw as Map<String, dynamic>),
    );
  }

  /// Invokes a method channel call, handling logging and optional decoding.
  Future<T?> invoke<T>(
    String method, {
    Map<String, dynamic>? arguments,
    T Function(dynamic json)? decode,
  }) async {
    try {
      final dynamic rawResult = await _channel.invokeMethod<dynamic>(
        method,
        arguments,
      );

      if (rawResult == null) {
        return null;
      }

      if (decode != null) {
        final dynamic parsedJson = rawResult is String
            ? jsonDecode(rawResult)
            : rawResult;
        return decode(parsedJson);
      }

      return rawResult as T;
    } on Exception catch (e) {
      logException(method, e);
      rethrow;
    }
  }

  /// Subscribes to an event stream by channel name, decoding JSON payloads
  /// into [T] and wrapping exception logging for [method].
  Stream<T> listenJson<T>(
    String channelName,
    String method,
    T Function(Map<String, dynamic> json) decode,
  ) {
    return listen<T>(_getEventChannel(channelName), method, decode);
  }

  /// Subscribes to an [EventChannel] stream, decoding JSON payloads
  /// and wrapping exception logging for [method].
  Stream<T> listen<T>(
    EventChannel channel,
    String method,
    T Function(Map<String, dynamic> json) decode,
  ) {
    try {
      final stream = channel.receiveBroadcastStream();
      return stream.asyncMap((dynamic event) {
        final jsonMap = event is String
            ? jsonDecode(event) as Map<String, dynamic>
            : (event as Map<dynamic, dynamic>).cast<String, dynamic>();
        return decode(jsonMap);
      });
    } on Exception catch (e) {
      logException(method, e);
      rethrow;
    }
  }

  /// Logs exceptions accurately mapped to the given [method] name.
  void logException(String method, Exception e) {
    if (e is SpotifyException) {
      _logger.e('$method failed with: ${e.message} (code: ${e.code})');
    } else if (e is PlatformException) {
      var message = e.message ?? '';
      message += e.details != null ? '\n${e.details}' : '';
      _logger.e('$method failed with: $message');
    } else if (e is MissingPluginException) {
      _logger.e('$method not implemented');
    } else {
      _logger.e('$method throws unhandled exception: $e');
    }
  }
}
