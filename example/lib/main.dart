import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _loading = false;
  String _authenticationToken = "";
  String _currentStatus = "";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Spotify SDK example app'),
        ),
        body: Center(child: _sampleFlowWidget),
      ),
    );
  }

  Widget get _sampleFlowWidget {
    if (_loading) {
      return Center(child: CircularProgressIndicator());
    }
    return ListView(
      children: [
        Text("Status $_currentStatus"),
        Text("Token: $_authenticationToken"),
        RaisedButton(
          child: Text("connectToSpotify"),
          onPressed: () => connectSpotify(),
        ),
        RaisedButton(
          child: Text("getauthtoken"),
          onPressed: () => getAuthenticationToken(),
        ),
        RaisedButton(
          child: Text("getPlayerState "),
          onPressed: () => getPlayerState(),
        ),
        RaisedButton(
          child: Text("getCrossfadeState "),
          onPressed: () => getCrossfadeState(),
        ),
        RaisedButton(child: Text("queue"), onPressed: () => queue()),
        RaisedButton(child: Text("play"), onPressed: () => play()),
        RaisedButton(child: Text("pause"), onPressed: () => pause()),
        RaisedButton(child: Text("resume"), onPressed: () => resume()),
        RaisedButton(
            child: Text("toggle repeat"), onPressed: () => toggleRepeat()),
        RaisedButton(
            child: Text("toggle shuffle"), onPressed: () => toggleShuffle()),
        RaisedButton(child: Text("skip next"), onPressed: () => skipNext()),
        RaisedButton(
            child: Text("skip previous"), onPressed: () => skipPrevious()),
        RaisedButton(child: Text("seek to"), onPressed: () => seekTo()),
        RaisedButton(
            child: Text("seek to relative"), onPressed: () => seekToRelative()),
        RaisedButton(
            child: Text("add to library"), onPressed: () => addToLibrary()),
        RaisedButton(child: Text("get image"), onPressed: () => getImage()),
      ],
    );
  }

  Future<void> connectSpotify() async {
    try {
      var result = await SpotifySdk.connectToSpotifyRemote(
          clientId: "", redirectUrl: "");
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
      setState(() {
        _authenticationToken = authenticationToken;
      });
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

  void setStatus(String code, {String message}) {
    setState(() {
      _currentStatus = "$code \n $message";
    });
  }
}
