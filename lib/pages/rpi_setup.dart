import 'package:flutter/material.dart';
import 'package:rPiInterface/utils/models.dart';
import '../authentication.dart';
import '../mqtt_wrapper.dart';

// programar button "Usar default" e "Usar novo" para enviar MACAddress para RPi e voltar à HomePage
// programar button "Definir novo default" para enviar MACAddress para RPi e mudar "defaultBIT"

class RPiPage extends StatefulWidget {
  MQTTClientWrapper mqttClientWrapper;
  RPiPage({this.mqttClientWrapper});

  @override
  _RPiPageState createState() => _RPiPageState();
}

class _RPiPageState extends State<RPiPage> {
  final Auth _auth = Auth();

  String _connectionText;
  Color _connectionColor;
  MqttCurrentConnectionState _connectionState;

  String message;
  String _hostAddress = '192.168.2.112';

  void setup() {
    //widget.mqttClientWrapper = MQTTClientWrapper(() => {}, (newMessage) => gotNewMessage(newMessage));
    widget.mqttClientWrapper.prepareMqttClient(_hostAddress);
  }

  @override
  void initState() {
    super.initState();
    _connectionState = widget.mqttClientWrapper.connectionState;
    _connectionColor = _connectionState == MqttCurrentConnectionState.CONNECTED
        ? Colors.green[50]
        : _connectionState == MqttCurrentConnectionState.CONNECTING
            ? Colors.yellow[50]
            : Colors.red[50];
    _connectionText = _connectionState == MqttCurrentConnectionState.CONNECTED
        ? 'Conectado'
        : _connectionState == MqttCurrentConnectionState.CONNECTING
            ? 'A conectar...'
            : 'Disconectado';
    print('Connection state: $_connectionText');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: new Text('Conectar RPi'), actions: <Widget>[
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
            Container(
              height: 20,
              color: _connectionColor,
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  child: Text(_connectionText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      //fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
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
                    child: new Text("Conectar"),
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
