import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:spotify_sdk_example/widgets/sized_icon_button.dart';

Future<void> main() async {
  await dotenv.load();
  runApp(const Home());
}

/// A [StatefulWidget] which uses:
/// * [spotify_sdk](https://pub.dev/packages/spotify_sdk)
/// to connect to Spotify and use controls.
class Home extends StatefulWidget {
  /// Constructor for [Home]
  const Home({super.key});

  @override
  HomeState createState() => HomeState();
}

/// The state for the [Home] widget.
class HomeState extends State<Home> {
  bool _loading = false;
  bool _connected = false;
  final Logger _logger = Logger(
    //filter: CustomLogFilter(), // custom logfilter can be used to have logs in release mode
    printer: PrettyPrinter(),
  );

  /// The current crossfade state.
  CrossfadeState? crossfadeState;

  /// The URI for the current track's image.
  late ImageUri? currentTrackImageUri;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: StreamBuilder<ConnectionStatus>(
        stream: SpotifySdk.subscribeConnectionStatus(),
        builder: (context, snapshot) {
          _connected = false;
          final data = snapshot.data;
          if (data != null) {
            _connected = data.connected;
          }
          return Scaffold(
            appBar: AppBar(
              title: const Text('SpotifySdk Example'),
              actions: [
                if (_connected)
                  IconButton(
                    onPressed: disconnect,
                    icon: const Icon(Icons.exit_to_app),
                  )
                else
                  Container(),
              ],
            ),
            body: _sampleFlowWidget(context),
            bottomNavigationBar: _connected ? _buildBottomBar(context) : null,
          );
        },
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          SizedIconButton(
            width: 50,
            icon: Icons.queue_music,
            onPressed: queue,
          ),
          SizedIconButton(
            width: 50,
            icon: Icons.playlist_play,
            onPressed: play,
          ),
          SizedIconButton(
            width: 50,
            icon: Icons.repeat,
            onPressed: toggleRepeat,
          ),
          SizedIconButton(
            width: 50,
            icon: Icons.shuffle,
            onPressed: toggleShuffle,
          ),
          SizedIconButton(
            width: 50,
            onPressed: addToLibrary,
            icon: Icons.favorite,
          ),
        ],
      ),
    );
  }

  Widget _sampleFlowWidget(BuildContext context2) {
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                TextButton(
                  onPressed: connectToSpotifyRemote,
                  child: const Icon(Icons.settings_remote),
                ),
                TextButton(
                  onPressed: getAccessToken,
                  child: const Text('get auth token '),
                ),
              ],
            ),
            const Divider(),
            Text(
              'Player State',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            if (_connected)
              _buildPlayerStateWidget()
            else
              const Center(
                child: Text('Not connected'),
              ),
            const Divider(),
            Text(
              'Player Context',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            if (_connected)
              _buildPlayerContextWidget()
            else
              const Center(
                child: Text('Not connected'),
              ),
            const Divider(),
            Text(
              'Player Api',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ElevatedButton(
                  onPressed: seekTo,
                  child: const Text('seek to 20000ms'),
                ),
                ElevatedButton(
                  onPressed: seekToRelative,
                  child: const Text('seek to relative 20000ms'),
                ),
              ],
            ),
            const Divider(),
            Text(
              'Connect Api',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton(
                  onPressed: switchToLocalDevice,
                  child: const Text('switch to local device'),
                ),
              ],
            ),
            const Divider(),
            Text(
              'Crossfade State',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Status',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  crossfadeState?.isEnabled ?? false ? 'Enabled' : 'Disabled',
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Duration',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                Text(crossfadeState?.duration.toString() ?? 'Unknown'),
                Row(
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: getCrossfadeState,
                      child: const Text(
                        'get crossfade state',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        if (_loading)
          const ColoredBox(
            color: Colors.black12,
            child: Center(child: CircularProgressIndicator()),
          )
        else
          const SizedBox(),
      ],
    );
  }

  Widget _buildPlayerStateWidget() {
    return StreamBuilder<PlayerState>(
      stream: SpotifySdk.subscribePlayerState(),
      builder: (context, snapshot) {
        final track = snapshot.data?.track;
        currentTrackImageUri = track?.imageUri;
        final playerState = snapshot.data;

        if (playerState == null || track == null) {
          return Center(
            child: Container(),
          );
        }

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                SizedIconButton(
                  width: 50,
                  icon: Icons.skip_previous,
                  onPressed: skipPrevious,
                ),
                if (playerState.isPaused)
                  SizedIconButton(
                    width: 50,
                    icon: Icons.play_arrow,
                    onPressed: resume,
                  )
                else
                  SizedIconButton(
                    width: 50,
                    icon: Icons.pause,
                    onPressed: pause,
                  ),
                SizedIconButton(
                  width: 50,
                  icon: Icons.skip_next,
                  onPressed: skipNext,
                ),
              ],
            ),
            if (track.isPodcast)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    child: const SizedBox(
                      width: 50,
                      child: Text('x0.5'),
                    ),
                    onPressed: () =>
                        setPlaybackSpeed(PodcastPlaybackSpeed.playbackSpeed_50),
                  ),
                  TextButton(
                    child: const SizedBox(
                      width: 50,
                      child: Text('x1'),
                    ),
                    onPressed: () => setPlaybackSpeed(
                      PodcastPlaybackSpeed.playbackSpeed_100,
                    ),
                  ),
                  TextButton(
                    child: const SizedBox(
                      width: 50,
                      child: Text('x1.5'),
                    ),
                    onPressed: () => setPlaybackSpeed(
                      PodcastPlaybackSpeed.playbackSpeed_150,
                    ),
                  ),
                  TextButton(
                    child: const SizedBox(
                      width: 50,
                      child: Text('x3.0'),
                    ),
                    onPressed: () => setPlaybackSpeed(
                      PodcastPlaybackSpeed.playbackSpeed_300,
                    ),
                  ),
                ],
              )
            else
              Container(),
            Text(
              'Track',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(
              '${track.name} by ${track.artist.name} '
              'from the album ${track.album.name}',
              maxLines: 2,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Playback',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Playback speed: ${playerState.playbackSpeed}'),
                Text(
                  'Progress: ${playerState.playbackPosition}ms/${track.duration}ms',
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Paused: ${playerState.isPaused}'),
                Text('Shuffling: ${playerState.playbackOptions.isShuffling}'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Is episode: ${track.isEpisode}'),
                Text('Is podcast: ${track.isPodcast}'),
              ],
            ),
            Row(
              children: [
                Text('RepeatMode: ${playerState.playbackOptions.repeatMode}'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text(
                      'Repeat Mode:',
                    ),
                    DropdownButton<SpotifyRepeatMode>(
                      value: playerState.playbackOptions.repeatMode,
                      items: const [
                        DropdownMenuItem(
                          value: SpotifyRepeatMode.off,
                          child: Text('off'),
                        ),
                        DropdownMenuItem(
                          value: SpotifyRepeatMode.track,
                          child: Text('track'),
                        ),
                        DropdownMenuItem(
                          value: SpotifyRepeatMode.context,
                          child: Text('context'),
                        ),
                      ],
                      onChanged: (repeatMode) => setRepeatMode(repeatMode!),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text('Switch shuffle: '),
                    Switch.adaptive(
                      value: playerState.playbackOptions.isShuffling,
                      onChanged: (value) => setShuffle(shuffle: value),
                    ),
                  ],
                ),
              ],
            ),
            if (_connected)
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 8),
                child: spotifyImageWidget(track.imageUri),
              )
            else
              const Text('Connect to see an image...'),
            Text(
              track.imageUri.raw,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        );
      },
    );
  }

  Widget _buildPlayerContextWidget() {
    return StreamBuilder<PlayerContext>(
      stream: SpotifySdk.subscribePlayerContext(),
      initialData: PlayerContext('', '', '', ''),
      builder: (context, snapshot) {
        final playerContext = snapshot.data;
        if (playerContext == null) {
          return const Center(
            child: Text('Not connected'),
          );
        }

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Title',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(playerContext.title),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Subtitle',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            Text(playerContext.subtitle),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Type',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            Text(playerContext.type),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Uri',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            Text(
              playerContext.uri,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        );
      },
    );
  }

  /// Displays an image from Spotify.
  Widget spotifyImageWidget(ImageUri image) {
    return FutureBuilder(
      future: SpotifySdk.getImage(
        imageUri: image,
        dimension: ImageDimension.large,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Image.memory(snapshot.data!);
        } else if (snapshot.hasError) {
          setStatus(snapshot.error.toString());
          return SizedBox(
            width: ImageDimension.large.value.toDouble(),
            height: ImageDimension.large.value.toDouble(),
            child: const Center(child: Text('Error getting image')),
          );
        } else {
          return SizedBox(
            width: ImageDimension.large.value.toDouble(),
            height: ImageDimension.large.value.toDouble(),
            child: const Center(child: Text('Getting image...')),
          );
        }
      },
    );
  }

  /// Disconnects from Spotify.
  Future<void> disconnect() async {
    try {
      setState(() {
        _loading = true;
      });
      final result = await SpotifySdk.disconnect();
      setStatus(result ? 'disconnect successful' : 'disconnect failed');
      setState(() {
        _loading = false;
      });
    } on PlatformException catch (e) {
      setState(() {
        _loading = false;
      });
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setState(() {
        _loading = false;
      });
      setStatus('not implemented');
    }
  }

  /// Connects to Spotify Remote.
  Future<void> connectToSpotifyRemote() async {
    try {
      setState(() {
        _loading = true;
      });
      final result = await SpotifySdk.connectToSpotifyRemote(
        clientId: dotenv.env['CLIENT_ID'].toString(),
        redirectUrl: dotenv.env['REDIRECT_URL'].toString(),
      );
      setStatus(
        result ? 'connect to spotify successful' : 'connect to spotify failed',
      );
      setState(() {
        _loading = false;
      });
    } on PlatformException catch (e) {
      setState(() {
        _loading = false;
      });
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setState(() {
        _loading = false;
      });
      setStatus('not implemented');
    }
  }

  /// Gets an access token.
  Future<String> getAccessToken() async {
    try {
      final authenticationToken = await SpotifySdk.getAccessToken(
        clientId: dotenv.env['CLIENT_ID'].toString(),
        redirectUrl: dotenv.env['REDIRECT_URL'].toString(),
        scope:
            'app-remote-control, '
            'user-modify-playback-state, '
            'playlist-read-private, '
            'playlist-modify-public,user-read-currently-playing',
      );
      setStatus('Got a token: $authenticationToken');
      return authenticationToken;
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
      return Future.error('$e.code: $e.message');
    } on MissingPluginException {
      setStatus('not implemented');
      return Future.error('not implemented');
    }
  }

  /// Gets the current player state.
  Future<PlayerState?> getPlayerState() async {
    try {
      return await SpotifySdk.getPlayerState();
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
      return null;
    } on MissingPluginException {
      setStatus('not implemented');
      return null;
    }
  }

  /// Gets the current crossfade state.
  Future<void> getCrossfadeState() async {
    try {
      final crossfadeStateValue = await SpotifySdk.getCrossFadeState();
      setState(() {
        crossfadeState = crossfadeStateValue;
      });
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  /// Queues a track.
  Future<void> queue() async {
    try {
      await SpotifySdk.queue(
        spotifyUri: 'spotify:track:58kNJana4w5BIjlZE2wq5m',
      );
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  /// Toggles the repeat mode.
  Future<void> toggleRepeat() async {
    try {
      await SpotifySdk.toggleRepeat();
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  /// Sets the repeat mode.
  Future<void> setRepeatMode(SpotifyRepeatMode repeatMode) async {
    try {
      await SpotifySdk.setRepeatMode(
        repeatMode: repeatMode,
      );
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  /// Sets the shuffle mode.
  Future<void> setShuffle({required bool shuffle}) async {
    try {
      await SpotifySdk.setShuffle(
        shuffle: shuffle,
      );
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  /// Toggles the shuffle mode.
  Future<void> toggleShuffle() async {
    try {
      await SpotifySdk.toggleShuffle();
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  /// Sets the playback speed.
  Future<void> setPlaybackSpeed(
    PodcastPlaybackSpeed podcastPlaybackSpeed,
  ) async {
    try {
      await SpotifySdk.setPodcastPlaybackSpeed(
        podcastPlaybackSpeed: podcastPlaybackSpeed,
      );
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  /// Starts playback.
  Future<void> play() async {
    try {
      await SpotifySdk.play(spotifyUri: 'spotify:track:58kNJana4w5BIjlZE2wq5m');
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  /// Pauses playback.
  Future<void> pause() async {
    try {
      await SpotifySdk.pause();
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  /// Resumes playback.
  Future<void> resume() async {
    try {
      await SpotifySdk.resume();
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  /// Skips to the next track.
  Future<void> skipNext() async {
    try {
      await SpotifySdk.skipNext();
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  /// Skips to the previous track.
  Future<void> skipPrevious() async {
    try {
      await SpotifySdk.skipPrevious();
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  /// Seeks to a position.
  Future<void> seekTo() async {
    try {
      await SpotifySdk.seekTo(positionedMilliseconds: 20000);
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  /// Seeks relative to the current position.
  Future<void> seekToRelative() async {
    try {
      await SpotifySdk.seekToRelativePosition(relativeMilliseconds: 20000);
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  /// Switches to the local device.
  Future<void> switchToLocalDevice() async {
    try {
      await SpotifySdk.switchToLocalDevice();
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  /// Adds a track to the library.
  Future<void> addToLibrary() async {
    try {
      await SpotifySdk.addToLibrary(
        spotifyUri: 'spotify:track:58kNJana4w5BIjlZE2wq5m',
      );
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  /// Sets the status message.
  void setStatus(String code, {String? message}) {
    final text = message ?? '';
    _logger.i('$code$text');
  }
}
