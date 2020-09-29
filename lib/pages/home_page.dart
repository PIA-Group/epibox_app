import 'package:flutter/material.dart';
import 'package:rPiInterface/pages/devices_setup.dart';
import 'package:rPiInterface/pages/rpi_setup.dart';
import 'package:rPiInterface/authentication.dart';
import 'package:provider/provider.dart';
import '../mqtt_wrapper.dart';
import 'dart:convert';


class HomePage extends StatefulWidget {

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Auth _auth = Auth();
  String message;

  MQTTClientWrapper mqttClientWrapper;

  void setupHome() {
    mqttClientWrapper = MQTTClientWrapper(() => {}, (newMessage) => gotNewMessage(newMessage));
  }

  @override
  void initState() {
    super.initState();
    setupHome();
  }

  void gotNewMessage(String newMessage) {
    setState(() => message = newMessage);
    print('This is the new message: $message');
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
          title: new Text('Aquisição de biossinais'),
          actions: <Widget>[
            FlatButton.icon(
              label: Text(
                'Sign out',
                style: TextStyle(color: Colors.white),
              ),
              icon: Icon(
                Icons.person,
                color: Colors.white,
              ),
              onPressed: () async {
                await _auth.signOut();
              },
            )
          ]),
      body: Container(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            FlatButton.icon(
              label: Text(
                'Escolher dispositivos',
                style: TextStyle(color: Colors.black),
              ),
              icon: Icon(
                Icons.bluetooth,
                color: Colors.black,
              ),
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return StreamProvider<User>.value(
                      value: Auth().user,
                      child:  DevicesPage(mqttClientWrapper: mqttClientWrapper, message: message,)
                    );
                  }),
                );
              },
            ),

            FlatButton.icon(
              label: Text(
                'Escolher dispositivos',
                style: TextStyle(color: Colors.black),
              ),
              icon: Icon(
                Icons.bluetooth,
                color: Colors.black,
              ),
              /* onPressed: () {setState(() {
                setup();
              });}, */
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return StreamProvider<User>.value(
                      value: Auth().user,
                      child: RPiPage(mqttClientWrapper: mqttClientWrapper)
                    );
                  }),
                );
              },
            ),

          ],
        ),
        // body: WebView(
        //   initialUrl: 'https://en.wikipedia.org/wiki/Kraken',
        //   javascriptMode: JavascriptMode.unrestricted,
        // ),
      ),
    );
  }
}
