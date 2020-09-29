import 'package:flutter/material.dart';

import '../authentication.dart';

// programar button "Usar default" e "Usar novo" para enviar MACAddress para RPi e voltar à HomePage
// programar button "Definir novo default" para enviar MACAddress para RPi e mudar "defaultBIT"


class DevicesPage extends StatefulWidget {
  @override
  _DevicesPageState createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {

 final Auth _auth = Auth();

  String _macAddress1 = 'Endereço MAC 1';
  String _macAddress2 = 'Endereço MAC 2';

  String _newMacAddress1 = 'Novo endereço MAC 1';
  String _newMacAddress2 = 'Novo endereço MAC 2';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
          title: new Text('Dispositivos'),
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
      body: Center(
        child: ListView(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
              child: Column(children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20.0, 0.0, 0.0, 10.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      child: Text(
                        'Dispositivos default',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 150.0,
                  width: 300.0,
                  color: Colors.transparent,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey[200],
                            offset: new Offset(5.0, 5.0))
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
                          child: Container(
                            height: 60.0,
                            width: 290.0,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              shape: BoxShape.rectangle,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4.0)),
                              border: new Border.all(
                                  color: Colors.grey,
                                  width: 1.0,
                                  style: BorderStyle.solid),
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding:
                                    EdgeInsets.fromLTRB(11.0, 0.0, 0.0, 0.0),
                                child: Text(
                                  _macAddress1,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
                          child: Container(
                            height: 60.0,
                            width: 290.0,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              shape: BoxShape.rectangle,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4.0)),
                              border: new Border.all(
                                  color: Colors.grey,
                                  width: 1.0,
                                  style: BorderStyle.solid),
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding:
                                    EdgeInsets.fromLTRB(11.0, 0.0, 0.0, 0.0),
                                child: Text(
                                  _macAddress2,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
                  child: RaisedButton(
                    onPressed: () => print("Button Pressed"),
                    child: new Text("Usar default"),
                  ),
                ),
              ]),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
              child: Column(children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20.0, 0.0, 0.0, 10.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      child: Text(
                        'Escolher novo(s) dispositivo(s)',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 150.0,
                  width: 300.0,
                  color: Colors.transparent,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey[200],
                            offset: new Offset(5.0, 5.0))
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
                          child: TextField(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Endereço MAC',
                              ),
                              onChanged: (text) {
                                setState(() {
                                  _newMacAddress1 = text;
                                });
                                print("Novo MAC address 1: $_newMacAddress1");
                              }),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
                          child: TextField(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Endereço MAC',
                              ),
                              onChanged: (text) {
                                setState(() {
                                  _newMacAddress2 = text;
                                });
                                print("Novo MAC address 2: $_newMacAddress2");
                              }),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      RaisedButton(
                        onPressed: () {},
                        child: new Text("Usar novo"),
                      ),
                      RaisedButton(
                        onPressed: () {
                          setState(() {
                            _macAddress1 = _newMacAddress1;
                            _macAddress2 = _newMacAddress2;
                          });
                        },
                        child: new Text("Definir novo default"),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
