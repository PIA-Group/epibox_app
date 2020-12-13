import 'package:flutter/material.dart';
import 'package:rPiInterface/utils/auth_wrapper.dart';
import 'package:rPiInterface/utils/id_wrapper.dart';

class ModeSelectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(title: new Text('EpiBox')),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(40.0, 0.0, 0.0, 20.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("Escolha a modalidade:",
                    style:
                        TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.grey[600])),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 15.0),
              child: ButtonTheme(
                minWidth: 215.0,
                child: RaisedButton(
                  color: Colors.blue,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) {
                        return AuthWrapper();
                      }),
                    );
                  },
                  child: new Text(
                    "ÁREA DO PACIENTE",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ),
            ButtonTheme(
              minWidth: 215.0,
              child: RaisedButton(
                color: Colors.blue,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return IDWrapper();
                    }),
                  );
                },
                child: new Text(
                  "ÁREA DO INVESTIGADOR",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
