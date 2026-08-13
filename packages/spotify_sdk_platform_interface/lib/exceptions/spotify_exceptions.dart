import 'package:flutter/services.dart';

/// Base exception class for all Spotify SDK errors.
abstract class SpotifyException implements Exception {
  /// Constructs a [SpotifyException].
  const SpotifyException(
    this.message, {
    this.code,
    this.details,
    this.cause,
  });

  /// Factory translating any generic [Exception] or [PlatformException] into
  /// a specific [SpotifyException] subclass.
  factory SpotifyException.fromException(Exception e) {
    if (e is SpotifyException) {
      return e;
    }
    if (e is MissingPluginException) {
      return SpotifyUnimplementedException(
        e.message ?? 'Method not implemented on this platform',
        cause: e,
      );
    }
    if (e is PlatformException) {
      return SpotifyException.fromPlatformException(e);
    }
    return SpotifyGeneralException(
      e.toString(),
      cause: e,
    );
  }

  /// Factory mapping a [PlatformException] by its code and message into
  /// the appropriate domain exception subtype.
  factory SpotifyException.fromPlatformException(PlatformException e) {
    final codeLower = e.code.toLowerCase();
    final msg = (e.message != null && e.message!.isNotEmpty)
        ? e.message!
        : e.code;

    if (codeLower.contains('notinstalled') ||
        codeLower.contains('not_installed') ||
        codeLower.contains('spotifynotinstalled')) {
      return SpotifyNotInstalledException(
        msg,
        code: e.code,
        details: e.details,
        cause: e,
      );
    }

    if (codeLower.contains('auth') || codeLower.contains('token')) {
      return SpotifyAuthenticationException(
        msg,
        code: e.code,
        details: e.details,
        cause: e,
      );
    }

    if (codeLower.contains('connecting') ||
        codeLower.contains('connection') ||
        codeLower.contains('appremotenull') ||
        codeLower.contains('pendingoperation') ||
        codeLower.contains('not ready')) {
      return SpotifyConnectionException(
        msg,
        code: e.code,
        details: e.details,
        cause: e,
      );
    }

    if (codeLower.contains('library') || codeLower.contains('capabilities')) {
      return SpotifyLibraryException(
        msg,
        code: e.code,
        details: e.details,
        cause: e,
      );
    }

    if (codeLower.contains('image')) {
      return SpotifyImageException(
        msg,
        code: e.code,
        details: e.details,
        cause: e,
      );
    }

    if (codeLower.contains('play') ||
        codeLower.contains('pause') ||
        codeLower.contains('resume') ||
        codeLower.contains('skip') ||
        codeLower.contains('seek') ||
        codeLower.contains('shuffle') ||
        codeLower.contains('repeat') ||
        codeLower.contains('queue')) {
      return SpotifyPlaybackException(
        msg,
        code: e.code,
        details: e.details,
        cause: e,
      );
    }

    if (codeLower.contains('unimplemented')) {
      return SpotifyUnimplementedException(
        msg,
        code: e.code,
        details: e.details,
        cause: e,
      );
    }

    return SpotifyGeneralException(
      msg,
      code: e.code,
      details: e.details,
      cause: e,
    );
  }

  /// Human-readable error message describing the failure.
  final String message;

  /// Error code identifying the category or native error code.
  final String? code;

  /// Additional diagnostic details if provided by the platform.
  final dynamic details;

  /// Underlying error or cause if translated from a platform or network error.
  final Object? cause;

  @override
  String toString() {
    final buffer = StringBuffer(runtimeType.toString())..write(': $message');
    if (code != null && code!.isNotEmpty) {
      buffer.write(' (code: $code)');
    }
    if (details != null && details.toString().isNotEmpty) {
      buffer.write(' [details: $details]');
    }
    return buffer.toString();
  }
}

/// Thrown when authentication, token swap, or token refresh fails.
class SpotifyAuthenticationException extends SpotifyException {
  /// Constructs a [SpotifyAuthenticationException].
  const SpotifyAuthenticationException(
    super.message, {
    super.code,
    super.details,
    super.cause,
  });
}

/// Thrown when Spotify app is not installed on the mobile host device.
class SpotifyNotInstalledException extends SpotifyException {
  /// Constructs a [SpotifyNotInstalledException].
  const SpotifyNotInstalledException(
    super.message, {
    super.code,
    super.details,
    super.cause,
  });
}

/// Thrown when connecting to Spotify App Remote fails or Spotify Remote
/// is disconnected.
class SpotifyConnectionException extends SpotifyException {
  /// Constructs a [SpotifyConnectionException].
  const SpotifyConnectionException(
    super.message, {
    super.code,
    super.details,
    super.cause,
  });
}

/// Thrown when playback commands (play, pause, skip, seek, queue, repeat,
/// shuffle) fail.
class SpotifyPlaybackException extends SpotifyException {
  /// Constructs a [SpotifyPlaybackException].
  const SpotifyPlaybackException(
    super.message, {
    super.code,
    super.details,
    super.cause,
  });
}

/// Thrown when user library or capability operations fail.
class SpotifyLibraryException extends SpotifyException {
  /// Constructs a [SpotifyLibraryException].
  const SpotifyLibraryException(
    super.message, {
    super.code,
    super.details,
    super.cause,
  });
}

/// Thrown when image / artwork fetching fails.
class SpotifyImageException extends SpotifyException {
  /// Constructs a [SpotifyImageException].
  const SpotifyImageException(
    super.message, {
    super.code,
    super.details,
    super.cause,
  });
}

/// Thrown when a method is not implemented on the current platform.
class SpotifyUnimplementedException extends SpotifyException {
  /// Constructs a [SpotifyUnimplementedException].
  const SpotifyUnimplementedException(
    super.message, {
    super.code,
    super.details,
    super.cause,
  });
}

/// Generic Spotify SDK exception for uncategorized errors.
class SpotifyGeneralException extends SpotifyException {
  /// Constructs a [SpotifyGeneralException].
  const SpotifyGeneralException(
    super.message, {
    super.code,
    super.details,
    super.cause,
  });
}
