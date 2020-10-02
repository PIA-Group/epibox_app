import 'package:flutter/material.dart';
import 'package:rPiInterface/utils/models.dart';
import '../mqtt_wrapper.dart';
import '../utils/authentication.dart';


// programar button "Usar default" e "Usar novo" para enviar MACAddress para RPi e voltar à HomePage
// programar button "Definir novo default" para enviar MACAddress para RPi e mudar "defaultBIT"

class RPiPage extends StatefulWidget {

  ValueNotifier<MqttCurrentConnectionState> connectionNotifier;
  MQTTClientWrapper mqttClientWrapper;
  MqttCurrentConnectionState connectionState;
  ValueNotifier<bool> receivedMACNotifier;

  RPiPage({this.mqttClientWrapper, this.connectionState, this.connectionNotifier, this.receivedMACNotifier});

  @override
  _RPiPageState createState() => _RPiPageState();
}

class _RPiPageState extends State<RPiPage> {
  final Auth _auth = Auth();

  /* String _connectionText;
  Color _connectionColor; */

  String message;

  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller.text = '192.168.2.112';
  }

  Future<void> setup() async {
    //widget.mqttClientWrapper = MQTTClientWrapper(() => {}, (newMessage) => gotNewMessage(newMessage));
    await widget.mqttClientWrapper.prepareMqttClient(_controller.text);
    //Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: new Text('Conectar a RPi'), actions: <Widget>[
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
      body: Center(
        child: ListView(
          children: <Widget>[
            ValueListenableBuilder(
                valueListenable: widget.connectionNotifier,
                builder: (BuildContext context,
                    MqttCurrentConnectionState state, Widget child) {
                  return Container(
                    height: 20,
                    color: state ==
                            MqttCurrentConnectionState.CONNECTED
                        ? Colors.green[50]
                        : state ==
                                MqttCurrentConnectionState.CONNECTING
                            ? Colors.yellow[50]
                            : Colors.red[50],
                    child: Align(
                      alignment: Alignment.center,
                      child: Container(
                        child: Text(
                          state ==
                                  MqttCurrentConnectionState.CONNECTED
                              ? 'Conectado'
                              : state ==
                                      MqttCurrentConnectionState.CONNECTING
                                  ? 'A conectar...'
                                  : 'Disconectado',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            //fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                ValueListenableBuilder(
                valueListenable: widget.receivedMACNotifier,
                builder: (BuildContext context,
                    bool state, Widget child) {
                  return Container(
                    height: 20,
                    color: state
                        ? Colors.green[50]
                        : Colors.red[50],
                    child: Align(
                      alignment: Alignment.center,
                      child: Container(
                        child: Text(
                          state
                              ? 'Processo completo'
                              : 'Processo incompleto',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            //fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
            Padding(
              padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
              child: Column(children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20.0, 0.0, 0.0, 10.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      child: Text(
                        'Endereço Raspberry Pi',
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
                            style: TextStyle(color: Colors.grey[600]),
                            controller: _controller,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Endereço RPi',
                              ),
                              onChanged: null),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
                  child: RaisedButton(
                    onPressed: () {
                      setup();
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
