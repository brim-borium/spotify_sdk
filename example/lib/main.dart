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
  String _authentication = 'Unknown';

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> authenticateSpotify() async {
    String authentication;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      authentication =
          await SpotifySdk.connectSpotify(clientId: "", redirectUrl: "");
    } on PlatformException catch (e) {
      var message = e.message;
      var details = e.details;

      authentication = '$message: $details';
    } on Exception catch (e) {
      authentication = e.toString();
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _authentication = authentication;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Spotify SDK example app'),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              Text('Auth: $_authentication\n'),
              RaisedButton(
                child: Text("authenticate Spotify"),
                onPressed: () async => await authenticateSpotify(),
              )
            ],
          ),
        ),
      ),
    );
  }
}
