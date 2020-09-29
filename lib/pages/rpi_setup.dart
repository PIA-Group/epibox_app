import 'package:flutter/material.dart';
import '../authentication.dart';
import '../mqtt_wrapper.dart';

// programar button "Usar default" e "Usar novo" para enviar MACAddress para RPi e voltar à HomePage
// programar button "Definir novo default" para enviar MACAddress para RPi e mudar "defaultBIT"

class RPiPage extends StatefulWidget {

  final MQTTClientWrapper mqttClientWrapper;
  RPiPage({this.mqttClientWrapper});

  @override
  _RPiPageState createState() => _RPiPageState();
}

class _RPiPageState extends State<RPiPage> {

  final Auth _auth = Auth();
  //MQTTClientWrapper mqttClientWrapper;

  String _hostAddress = '192.168.2.112';

  void setup() {
    //widget.mqttClientWrapper = MQTTClientWrapper(() => {});
    widget.mqttClientWrapper.prepareMqttClient(_hostAddress);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: new Text('Selecionar RPi'),
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
                        'Endereço RPi',
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
                                labelText: _hostAddress,
                              ),
                              onChanged: (text) {
                                setState(() => _hostAddress = text);
                                print("Novo host: $_hostAddress");
                              }),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
                  child: RaisedButton(
                    onPressed: () {
                      setState(() => setup());
                    },
                    child: new Text("Selecionar"),
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
