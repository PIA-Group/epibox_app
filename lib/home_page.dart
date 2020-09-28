import 'package:flutter/material.dart';
import 'package:rPiInterface/choose_devices.dart';
import 'package:rPiInterface/services/authentication.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';


BluetoothConnection connection;
bool get isConnected => connection != null && connection.isConnected;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Auth _auth = Auth();

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
            // Expanded(
            //   child: Text(isConnected
            //       ? connection.isConnected.toString()
            //       : isConnected.toString()),
            // ),
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
                      child: Provider<BluetoothConnection>.value(
                        value: connection,
                        child: DevicesPage()
                      )
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
