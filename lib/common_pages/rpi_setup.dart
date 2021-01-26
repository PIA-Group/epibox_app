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

  Future<void> _restart(String method) async {
    if (method == 'all') {
      widget.mqttClientWrapper.publishMessage("['RESTART']");
      await widget.mqttClientWrapper.diconnectClient();
    }
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
    _restart('');
    await widget.mqttClientWrapper
        .prepareMqttClient(widget.hostnameNotifier.value);
    var timeStamp = DateTime.now();
    String time = "${timeStamp.year}-${timeStamp.month}-${timeStamp.day} ${timeStamp.hour}:${timeStamp.minute}:${timeStamp.second}";
    widget.mqttClientWrapper.publishMessage("['TIME', '$time']");
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
                              ? 'Processo iniciado'
                              : 'Processo não iniciado',
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
                  padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      child: RichText(
                          textAlign: TextAlign.justify,
                          text: TextSpan(children: [
                        TextSpan(
                            text:
                                'Para conectar ao servidor e iniciar processo, clicar em ',
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[600])),
                        TextSpan(
                            text: '"Conectar"',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600])),
                        TextSpan(
                            text:
                                '. Isto irá colocar em marcha os procedimentos necessários para iniciar a aquisição de dados! ',
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[600])),
                      ])),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      child: RichText(
                          textAlign: TextAlign.justify,
                          text: TextSpan(children: [
                        TextSpan(
                            text:
                                'Caso queira fazer uma nova aquisição ou caso seja necessário reiniciar o processo, clicar em ',
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[600])),
                        TextSpan(
                            text: '"Reiniciar" ',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600])),
                      ])),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
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
                          _restart('all');
                        },
                        child: new Text("Reiniciar"),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      child: RichText(
                        textAlign: TextAlign.justify,
                        text: TextSpan(
                          children: [
                            TextSpan(
                                text: 'Caso esteja ',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey[600])),
                            TextSpan(
                                text: 'conectado ao servidor ',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[600])),
                            TextSpan(
                                text: 'mas o processo ',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey[600])),
                            TextSpan(
                                text: 'não ',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[600])),
                            TextSpan(
                                text:
                                    'tenha sido iniciado, reinincie e tente conectar novamente. Em último caso, desligue e volte a ligar o dispositivo.',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey[600])),
                          ],
                        ),
                      ),
                    ),
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
