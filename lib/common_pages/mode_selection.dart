import 'package:flutter/material.dart';
import 'package:rPiInterface/utils/auth_wrapper.dart';
import 'package:rPiInterface/utils/id_wrapper.dart';

class ModeSelectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(title: new Text('PreEpiSeizures')),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return AuthWrapper();
                  }),
                );
              },
              child: new Text("Paciente"),
            ),
            RaisedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return IDWrapper();
                  }),
                );
              },
              child: new Text("Ambiente hospitalar"),
            ),
          ],
        ),
      ),
    );
  }
}
