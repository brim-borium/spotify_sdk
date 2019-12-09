import 'package:flutter/material.dart';
import 'dart:async';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:flutter/services.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_sdk/models/player_context.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Home());
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _loading = false;
  bool _connected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SpotifySdk Example"),
      ),
      body: _sampleFlowWidget(context),
    );
  }

  Widget _sampleFlowWidget(BuildContext context2) {
    if (_loading) {
      return Center(child: CircularProgressIndicator());
    }
    return ListView(
      padding: EdgeInsets.all(8),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            FlatButton(
              child: Icon(Icons.settings_remote),
              onPressed: () => connectToSpotifyRemote(),
            ),
            FlatButton(
              child: Text("get auth token "),
              onPressed: () => getAuthenticationToken(),
            ),
          ],
        ),
        Divider(),
        Text("Player State", style: TextStyle(fontSize: 16)),
        if (_connected)
          StreamBuilder<PlayerState>(
            stream: SpotifySdk.subscribePlayerState(),
            initialData: PlayerState(null, false, 1, 1, null, null),
            builder:
                (BuildContext context, AsyncSnapshot<PlayerState> snapshot) {
              if (snapshot.data != null && snapshot.data.track != null) {
                var playerState = snapshot.data;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                        "${playerState.track.name} by ${playerState.track.artist.name} from the album ${playerState.track.album.name} "),
                    Text("Speed: ${playerState.playbackSpeed}"),
                    Text("IsPaused: ${playerState.isPaused}"),
                    Text(
                        "Is Shuffling: ${playerState.playbackOptions.isShuffling}"),
                    Text(
                        "RepeatMode: ${playerState.playbackOptions.repeatMode}")
                  ],
                );
              } else {
                return Center(
                  child: Text("Not connected"),
                );
              }
            },
          )
        else
          Center(
            child: Text("Not connected"),
          ),
        Divider(),
        Text("Player Context", style: TextStyle(fontSize: 16)),
        if (_connected)
          StreamBuilder<PlayerContext>(
            stream: SpotifySdk.subscribePlayerContext(),
            initialData: PlayerContext("", "", "", ""),
            builder:
                (BuildContext context, AsyncSnapshot<PlayerContext> snapshot) {
              if (snapshot.data != null && snapshot.data.title != "") {
                var playerContext = snapshot.data;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text("Title: ${playerContext.title}"),
                    Text("Subtitle: ${playerContext.subtitle}"),
                    Text("Type: ${playerContext.type}"),
                    Text("Uri: ${playerContext.uri}"),
                  ],
                );
              } else {
                return Center(
                  child: Text("Not connected"),
                );
              }
            },
          )
        else
          Center(
            child: Text("Not connected"),
          ),
        Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            SizedBox(
              width: 50,
              child: FlatButton(
                  child: Icon(
                    Icons.skip_previous,
                  ),
                  onPressed: () => skipPrevious()),
            ),
            SizedBox(
                width: 50,
                child: FlatButton(
                    child: Icon(Icons.play_arrow), onPressed: () => resume())),
            SizedBox(
                width: 50,
                child: FlatButton(
                    child: Icon(Icons.pause), onPressed: () => pause())),
            SizedBox(
              width: 50,
              child: FlatButton(
                  child: Icon(Icons.skip_next), onPressed: () => skipNext()),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            SizedBox(
              width: 50,
              child: FlatButton(
                  child: Icon(Icons.queue_music), onPressed: () => queue()),
            ),
            SizedBox(
              width: 50,
              child: FlatButton(
                  child: Icon(Icons.play_circle_filled),
                  onPressed: () => play()),
            ),
            SizedBox(
              width: 50,
              child: FlatButton(
                  child: Icon(Icons.repeat), onPressed: () => toggleRepeat()),
            ),
            SizedBox(
              width: 50,
              child: FlatButton(
                  child: Icon(Icons.shuffle), onPressed: () => toggleShuffle()),
            ),
          ],
        ),
        FlatButton(
            child: Icon(Icons.favorite), onPressed: () => addToLibrary()),
        RaisedButton(child: Text("seek to"), onPressed: () => seekTo()),
        RaisedButton(
            child: Text("seek to relative"), onPressed: () => seekToRelative()),
      ],
    );
  }

  Future<void> connectToSpotifyRemote() async {
    try {
      var result = await SpotifySdk.connectToSpotifyRemote(
          clientId: "4ee5e972f7154c3293f4c0fdec99f373",
          redirectUrl: "https://mysite.com/callback/");
      setState(() {
        _connected = result;
      });
      setStatus(result
          ? "connect to spotify successful"
          : "conntect to spotify failed");
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus("not implemented");
    }
  }

  Future<void> getAuthenticationToken() async {
    try {
      var authenticationToken = await SpotifySdk.getAuthenticationToken(
          clientId: "", redirectUrl: "");
      setStatus(authenticationToken);
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus("not implemented");
    }
  }

  Future getPlayerState() async {
    try {
      return await SpotifySdk.getPlayerState();
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus("not implemented");
    }
  }

  Future getCrossfadeState() async {
    try {
      return await SpotifySdk.getCrossFadeState();
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus("not implemented");
    }
  }

  Future<void> queue() async {
    try {
      await SpotifySdk.queue(
          spotifyUri: "spotify:track:58kNJana4w5BIjlZE2wq5m");
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus("not implemented");
    }
  }

  Future<void> toggleRepeat() async {
    try {
      await SpotifySdk.toggleRepeat();
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus("not implemented");
    }
  }

  Future<void> toggleShuffle() async {
    try {
      await SpotifySdk.toggleShuffle();
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus("not implemented");
    }
  }

  Future<void> play() async {
    try {
      await SpotifySdk.play(spotifyUri: "spotify:track:58kNJana4w5BIjlZE2wq5m");
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus("not implemented");
    }
  }

  Future<void> pause() async {
    try {
      await SpotifySdk.pause();
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus("not implemented");
    }
  }

  Future<void> resume() async {
    try {
      await SpotifySdk.resume();
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus("not implemented");
    }
  }

  Future<void> skipNext() async {
    try {
      await SpotifySdk.skipNext();
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus("not implemented");
    }
  }

  Future<void> skipPrevious() async {
    try {
      await SpotifySdk.skipPrevious();
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus("not implemented");
    }
  }

  Future<void> seekTo() async {
    try {
      await SpotifySdk.seekTo(positionedMilliseconds: 20000);
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus("not implemented");
    }
  }

  Future<void> seekToRelative() async {
    try {
      await SpotifySdk.seekToRelativePosition(relativeMilliseconds: 20000);
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus("not implemented");
    }
  }

  Future<void> addToLibrary() async {
    try {
      await SpotifySdk.addToLibrary(
          spotifyUri: "spotify:track:58kNJana4w5BIjlZE2wq5m");
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus("not implemented");
    }
  }

  Future<void> getImage() async {
    try {
      await SpotifySdk.getImage(
          imageUri:
              "https://i.scdn.co/image/ab67616d0000b2734a83c2c7cfba8eeab6242053",
          dimension: ImageDimension.large);
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus("not implemented");
    }
  }

  void setStatus(String code, {String message = ""}) {
    Fluttertoast.showToast(
        msg: "$code $message",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 2,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }
}
