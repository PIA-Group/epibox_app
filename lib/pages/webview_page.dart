import 'package:flutter/material.dart';
import 'package:rPiInterface/utils/authentication.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebviewPage extends StatefulWidget {
  @override
  _WebviewPageState createState() => _WebviewPageState();
}

class _WebviewPageState extends State<WebviewPage> {

  final Auth _auth = Auth();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(title: new Text('Visualização'), actions: <Widget>[
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
            Navigator.pop(context);
          },
        )
      ]),
      body: WebView(
        initialUrl: 'https://en.wikipedia.org/wiki/Kraken',
        javascriptMode: JavascriptMode.unrestricted,
      ),
      
    );
  }
}