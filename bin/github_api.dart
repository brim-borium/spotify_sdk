import 'dart:convert';

import 'package:http/http.dart' as http;

import 'android_setup.dart';

/// [fetchLatestAppRemoteReleaseAssetDownloadUrl] fetches the latest release of
/// the Spotify Android SDK from GitHub API and returns the name and download
/// url of the spotify-app-remote-release-*.aar asset.
/// Throws an exception if the request fails.
class GitHubApi {
  static const String apiUrl = 'https://api.github.com/repos';
  static const String spotifyAndroidSdkRepo = '/spotify/android-sdk';
  static const String latestRelease = '/releases/latest';
  static const String allReleases = '/releases';

  static Future<(String, Uri)>
  fetchLatestAppRemoteReleaseAssetDownloadUrl() async {
    // fetch the github api to get the latest release
    final uri = Uri.parse(apiUrl + spotifyAndroidSdkRepo + latestRelease);
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return _findAsset(data);
      } else {
        logger.e('Failed to fetch data from the API.');
      }
    } on Exception catch (e) {
      logger.e('An error occurred: $e');
    }
    throw Exception();
  }

  static Future<(String, Uri)> fetchVersionedAppRemoteReleaseAssetDownloadUrl(
    String sdkVersion,
  ) async {
    var version = sdkVersion;
    if (version.startsWith('--sdk-version=')) {
      version = version.substring(14);
    }
    if (version.startsWith('v')) {
      version = version.substring(1);
    }

    // fetch the github api to get all releases
    final uri = Uri.parse(apiUrl + spotifyAndroidSdkRepo + allReleases);
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;

        logger.t(
          'Found ${data.length} releases of the Spotify Android SDK '
          'on GitHub.',
        );
        final releaseData =
            data.firstWhere(
                  (element) {
                    final releaseMap = element as Map<String, dynamic>;
                    final tagName = releaseMap['tag_name'] as String;
                    return tagName.contains('v$version');
                  },
                  orElse: () {
                    logger.e(
                      'Failed to find a release with version "$version".',
                    );
                    throw Exception();
                  },
                )
                as Map<String, dynamic>;

        return _findAsset(releaseData);
      }
    } on Exception catch (e) {
      logger.e('An error occurred: $e');
    }
    throw Exception();
  }

  static (String, Uri) _findAsset(Map<String, dynamic> data) {
    final assets = data['assets'] as List<dynamic>;

    final assetMap = <int, (String, String)>{};
    for (final asset in assets) {
      final assetMapData = asset as Map<String, dynamic>;
      final id = assetMapData['id'] as int;
      final name = assetMapData['name'] as String;
      final url = assetMapData['browser_download_url'] as String;
      assetMap[id] = (name, url);
    }

    // find the spotify-app-remote-release-*.aar asset
    final assetId = assetMap.keys.firstWhere(
      (id) =>
          assetMap[id]?.$1.startsWith('spotify-app-remote-release-') ?? false,
      orElse: () => -1,
    );

    if (assetId == -1) {
      logger.e('Failed to find the Spotify Android SDK asset.');
      throw Exception();
    }

    // return the download url of the spotify-app-remote-release-*.aar asset
    logger.i(
      'Found the Spotify Android SDK asset: '
      '${assetMap[assetId]!.$1}',
    );
    return (assetMap[assetId]!.$1, Uri.parse(assetMap[assetId]!.$2));
  }
}
