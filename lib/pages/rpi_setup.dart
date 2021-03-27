import 'package:flutter/material.dart';
import 'package:rPiInterface/appbars/condensed_appbar.dart';
import 'package:rPiInterface/bottom_navbar/destinations.dart';
import 'package:rPiInterface/bottom_navbar/visualization_page.dart';
import 'package:rPiInterface/decor/default_colors.dart';
import 'package:rPiInterface/decor/text_styles.dart';
import 'package:rPiInterface/utils/models.dart';
import 'package:rPiInterface/utils/mqtt_wrapper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rPiInterface/states/server_state.dart';
import 'package:rPiInterface/states/process_state.dart';

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

  ValueNotifier<List<List>> dataMAC1Notifier;
  ValueNotifier<List<List>> dataMAC2Notifier;
  ValueNotifier<List<List>> channelsMAC1Notifier;
  ValueNotifier<List<List>> channelsMAC2Notifier;
  ValueNotifier<List> sensorsMAC1Notifier;
  ValueNotifier<List> sensorsMAC2Notifier;

  ValueNotifier<String> patientNotifier;

  ValueNotifier<List> annotationTypesD;

  ValueNotifier<String> timedOut;
  ValueNotifier<bool> startupError;

  List<Destination> allDestinations;

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
    this.dataMAC1Notifier,
    this.dataMAC2Notifier,
    this.channelsMAC1Notifier,
    this.channelsMAC2Notifier,
    this.sensorsMAC1Notifier,
    this.sensorsMAC2Notifier,
    this.patientNotifier,
    this.annotationTypesD,
    this.timedOut,
    this.startupError,
    this.allDestinations,
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

      widget.driveListNotifier.value = ['RPi'];

      widget.batteryBit1Notifier.value = null;
      widget.batteryBit2Notifier.value = null;

      widget.isBit1Enabled.value = false;
      widget.isBit1Enabled.value = false;
    });

    saveBatteries(null, null);
    saveMAC('Endereço MAC', 'Endereço MAC');
  }

  Future<void> saveMAC(mac1, mac2) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      await prefs.setStringList('lastMAC', [mac1, mac2]);
    } catch (e) {
      print(e);
    }
  }

  Future<void> saveBatteries(battery1, battery2) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      await prefs.setStringList('lastBatteries', [
        battery1,
        battery2,
      ]);
    } catch (e) {
      print(e);
    }
  }

  Future<void> _setup() async {
    //_restart('');
    await widget.mqttClientWrapper
        .prepareMqttClient(widget.hostnameNotifier.value);
    var timeStamp = DateTime.now();
    String time =
        "${timeStamp.year}-${timeStamp.month}-${timeStamp.day} ${timeStamp.hour}:${timeStamp.minute}:${timeStamp.second}";
    widget.mqttClientWrapper.publishMessage("['TIME', '$time']");
    widget.mqttClientWrapper.publishMessage("['Send MAC Addresses']");
    widget.mqttClientWrapper.publishMessage("['Send config']");
    widget.mqttClientWrapper.publishMessage("['Send drives']");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CondensedAppBar(
        text1: 'Servidor: ',
        state1: ServerState(
            connectionNotifier: widget.connectionNotifier, fontSize: 16),
        text2: 'Processo: ',
        state2: ProcessState(
            receivedMACNotifier: widget.receivedMACNotifier, fontSize: 16),
      ),
      body: Center(
        child: ListView(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 50.0),
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
                                style: MyTextStyle(
                                    color: DefaultColors.textColorOnLight)),
                            TextSpan(
                                text: '"Conectar"',
                                style: MyTextStyle(
                                    color: DefaultColors.textColorOnLight)),
                            TextSpan(
                                text:
                                    '. Isto irá colocar em marcha os procedimentos necessários para iniciar a aquisição de dados! ',
                                style: MyTextStyle(
                                    color: DefaultColors.textColorOnLight)),
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
                                style: MyTextStyle(
                                    color: DefaultColors.textColorOnLight)),
                            TextSpan(
                                text: '"Reiniciar" ',
                                style: MyTextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[600],
                                  letterSpacing: 1,
                                  fontFamily: 'Hind',
                                )),
                          ])),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: DefaultColors.mainLColor, // background
                          //onPrimary: Colors.white, // foreground
                        ),
                        onPressed: () {
                          _setup();
                        },
                        child: new Text(
                          "Conectar",
                          style: MyTextStyle(
                            color: DefaultColors.textColorOnDark,
                            letterSpacing: 1,
                            fontFamily: 'Hind',
                          ),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: DefaultColors.mainLColor, // background
                          //onPrimary: Colors.white, // foreground
                        ),
                        onPressed: () {
                          _restart('all');
                          _setup();
                        },
                        child: new Text(
                          "Reiniciar",
                          style: MyTextStyle(
                            color: DefaultColors.textColorOnDark,
                            letterSpacing: 1,
                            fontFamily: 'Hind',
                          ),
                        ),
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
                                style: MyTextStyle(
                                    color: DefaultColors.textColorOnLight)),
                            TextSpan(
                                text: 'conectado ao servidor ',
                                style: MyTextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: DefaultColors.textColorOnLight)),
                            TextSpan(
                                text: 'mas o processo ',
                                style: MyTextStyle(
                                  color: DefaultColors.textColorOnLight,
                                )),
                            TextSpan(
                                text: 'não ',
                                style: MyTextStyle(
                                    color: DefaultColors.textColorOnLight)),
                            TextSpan(
                                text:
                                    'tenha sido iniciado, reinincie e tente conectar novamente. Em último caso, desligue e volte a ligar o dispositivo.',
                                style: MyTextStyle(
                                    color: DefaultColors.textColorOnLight)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
                  child: ValueListenableBuilder(
                      valueListenable: widget.acquisitionNotifier,
                      builder:
                          (BuildContext context, String state, Widget child) {
                        return RaisedButton(
                          textColor: Colors.grey[600],
                          disabledTextColor: Colors.transparent,
                          disabledColor: Colors.transparent,
                          elevation: state == 'acquiring' ? 2 : 0,
                          onPressed: state == 'acquiring'
                              ? () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) {
                                      return VisualizationPage(
                                        dataMAC1Notifier:
                                            widget.dataMAC1Notifier,
                                        dataMAC2Notifier:
                                            widget.dataMAC2Notifier,
                                        channelsMAC1Notifier:
                                            widget.channelsMAC1Notifier,
                                        channelsMAC2Notifier:
                                            widget.channelsMAC2Notifier,
                                        sensorsMAC1Notifier:
                                            widget.sensorsMAC1Notifier,
                                        sensorsMAC2Notifier:
                                            widget.sensorsMAC2Notifier,
                                        mqttClientWrapper:
                                            widget.mqttClientWrapper,
                                        acquisitionNotifier:
                                            widget.acquisitionNotifier,
                                        batteryBit1Notifier:
                                            widget.batteryBit1Notifier,
                                        batteryBit2Notifier:
                                            widget.batteryBit2Notifier,
                                        patientNotifier: widget.patientNotifier,
                                        annotationTypesD:
                                            widget.annotationTypesD,
                                        connectionNotifier:
                                            widget.connectionNotifier,
                                        timedOut: widget.timedOut,
                                        startupError: widget.startupError,
                                        allDestinations: widget.allDestinations,
                                      );
                                    }),
                                  );
                                }
                              : null,
                          child: new Text(
                            "Aquisição a decorrer!",
                          ),
                        );
                      }),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
