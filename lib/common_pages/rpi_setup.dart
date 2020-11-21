import 'package:flutter/material.dart';
import 'package:rPiInterface/utils/models.dart';
import 'package:rPiInterface/utils/mqtt_wrapper.dart';

class RPiPage extends StatefulWidget {
  ValueNotifier<MqttCurrentConnectionState> connectionNotifier;
  MQTTClientWrapper mqttClientWrapper;

  ValueNotifier<String> defaultMacAddress1Notifier;
  ValueNotifier<String> defaultMacAddress2Notifier;

  ValueNotifier<String> macAddress1Notifier;
  ValueNotifier<String> macAddress2Notifier;

  ValueNotifier<List<String>> driveListNotifier;

  ValueNotifier<bool> receivedMACNotifier;
  ValueNotifier<String> acquisitionNotifier;
  ValueNotifier<String> hostnameNotifier;

  ValueNotifier<bool> sentMACNotifier;
  ValueNotifier<bool> sentConfigNotifier;

  ValueNotifier<double> batteryBit1Notifier;
  ValueNotifier<double> batteryBit2Notifier;

  ValueNotifier<bool> isBit1Enabled;
  ValueNotifier<bool> isBit2Enabled;

  RPiPage({
    this.mqttClientWrapper,
    this.connectionNotifier,
    this.defaultMacAddress1Notifier,
    this.defaultMacAddress2Notifier,
    this.macAddress1Notifier,
    this.macAddress2Notifier,
    this.receivedMACNotifier,
    this.driveListNotifier,
    this.acquisitionNotifier,
    this.hostnameNotifier,
    this.sentMACNotifier,
    this.sentConfigNotifier,
    this.batteryBit1Notifier,
    this.batteryBit2Notifier,
    this.isBit1Enabled,
    this.isBit2Enabled,
  });

  @override
  _RPiPageState createState() => _RPiPageState();
}

class _RPiPageState extends State<RPiPage> {
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
    _controller.text = widget.hostnameNotifier.value;
  }

  Future<void> _restart() async {
    widget.mqttClientWrapper.publishMessage("['RESTART']");
    await widget.mqttClientWrapper.diconnectClient();
    setState(() {
      widget.defaultMacAddress1Notifier.value = 'Endereço MAC';
      widget.defaultMacAddress2Notifier.value = 'Endereço MAC';

      widget.macAddress1Notifier.value = 'Endereço MAC';
      widget.macAddress2Notifier.value = 'Endereço MAC';

      widget.receivedMACNotifier.value = false;
      widget.sentMACNotifier.value = false;
      widget.sentConfigNotifier.value = false;

      widget.acquisitionNotifier.value = 'off';

      widget.driveListNotifier.value = ['Armazenamento interno'];

      widget.batteryBit1Notifier.value = null;
      widget.batteryBit2Notifier.value = null;

      widget.isBit1Enabled.value = false;
      widget.isBit1Enabled.value = false;
    });
  }

  Future<void> _setup() async {
    print(_controller.text.replaceAll(new RegExp(r"\s+"), ""));
    setState(() => widget.hostnameNotifier.value =
        _controller.text.replaceAll(new RegExp(r"\s+"), ""));
    await widget.mqttClientWrapper
        .prepareMqttClient(_controller.text.replaceAll(new RegExp(r"\s+"), ""));
    widget.mqttClientWrapper.publishMessage("['Send MAC Addresses']");
    widget.mqttClientWrapper.publishMessage("['Send config']");  
    widget.mqttClientWrapper.publishMessage("['Send drives']");  
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Text('Conectividade'),
      ),
      body: Center(
        child: ListView(
          children: <Widget>[
            ValueListenableBuilder(
                valueListenable: widget.connectionNotifier,
                builder: (BuildContext context,
                    MqttCurrentConnectionState state, Widget child) {
                  return Container(
                    height: 20,
                    color: state == MqttCurrentConnectionState.CONNECTED
                        ? Colors.green[50]
                        : state == MqttCurrentConnectionState.CONNECTING
                            ? Colors.yellow[50]
                            : Colors.red[50],
                    child: Align(
                      alignment: Alignment.center,
                      child: Container(
                        child: Text(
                          state == MqttCurrentConnectionState.CONNECTED
                              ? 'Conectado ao servidor'
                              : state == MqttCurrentConnectionState.CONNECTING
                                  ? 'A conectar...'
                                  : 'Disconectado do servidor',
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
                builder: (BuildContext context, bool state, Widget child) {
                  return Container(
                    height: 20,
                    color: state ? Colors.green[50] : Colors.red[50],
                    child: Align(
                      alignment: Alignment.center,
                      child: Container(
                        child: Text(
                          state
                              // && _conn == MqttCurrentConnectionState.CONNECTED)
                              ? 'Conectado ao RPi'
                              : 'Disconectado do RPi',
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
                        'Endereço Servidor',
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
                              labelText: 'Endereço',
                            ),
                            onChanged: null,
                          ),
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
                        onPressed: () {
                          _setup();
                        },
                        child: new Text("Conectar"),
                      ),
                      RaisedButton(
                        onPressed: () {
                          _restart();
                        },
                        child: new Text("Reininciar"),
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
