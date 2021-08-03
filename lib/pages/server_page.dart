import 'package:epibox/acquisition_navbar/destinations.dart';
import 'package:epibox/classes/mac_devices.dart';
import 'package:flutter/material.dart';
import 'package:epibox/decor/default_colors.dart';
import 'package:epibox/decor/text_styles.dart';
import 'package:epibox/utils/models.dart';
import 'package:epibox/utils/mqtt_wrapper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ServerPage extends StatefulWidget {

  MacDevices macDevices;
  
  final ValueNotifier<MqttCurrentConnectionState> connectionNotifier;
  final MQTTClientWrapper mqttClientWrapper;

  final ValueNotifier<List<String>> driveListNotifier;

  final ValueNotifier<bool> receivedMACNotifier;
  final ValueNotifier<String> acquisitionNotifier;
  final ValueNotifier<String> hostnameNotifier;

  final ValueNotifier<bool> sentMACNotifier;
  final ValueNotifier<bool> sentConfigNotifier;

  final ValueNotifier<double> batteryBit1Notifier;
  final ValueNotifier<double> batteryBit2Notifier;


  final ValueNotifier<List<List>> dataMAC1Notifier;
  final ValueNotifier<List<List>> dataMAC2Notifier;
  final ValueNotifier<List<List>> channelsMAC1Notifier;
  final ValueNotifier<List<List>> channelsMAC2Notifier;
  final ValueNotifier<List> sensorsMAC1Notifier;
  final ValueNotifier<List> sensorsMAC2Notifier;

  final ValueNotifier<String> patientNotifier;

  final ValueNotifier<List> annotationTypesD;

  final ValueNotifier<String> timedOut;
  final ValueNotifier<bool> startupError;

  final List<Destination> allDestinations;

  final ValueNotifier<bool> saveRaw;

  ValueNotifier<String> chosenDrive;
  ValueNotifier<TextEditingController> controllerFreq;

  ServerPage({
    this.macDevices,
    this.mqttClientWrapper,
    this.connectionNotifier,
    this.receivedMACNotifier,
    this.driveListNotifier,
    this.acquisitionNotifier,
    this.hostnameNotifier,
    this.sentMACNotifier,
    this.sentConfigNotifier,
    this.batteryBit1Notifier,
    this.batteryBit2Notifier,
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
    this.saveRaw,
    this.chosenDrive,
    this.controllerFreq,
  });

  @override
  _ServerPageState createState() => _ServerPageState();
}

class _ServerPageState extends State<ServerPage> {
  String message;

  @override
  void initState() {
    super.initState();
    print('SAVE RAW: ${widget.saveRaw}');
  }

  Future<void> _restart(bool restart) async {
    widget.mqttClientWrapper.publishMessage("['RESTART']");

    if (restart) {
      await widget.mqttClientWrapper.diconnectClient();
      setState(() {

        widget.macDevices.defaultMacAddress1 = 'xx:xx:xx:xx:xx:xx';
        widget.macDevices.defaultMacAddress2 = 'xx:xx:xx:xx:xx:xx';

        widget.macDevices.macAddress1 = 'xx:xx:xx:xx:xx:xx';
        widget.macDevices.macAddress2 = 'xx:xx:xx:xx:xx:xx';

        widget.driveListNotifier.value = [' '];
        widget.chosenDrive.value = ' ';
        widget.controllerFreq.value.text = ' ';

        widget.macDevices.isBit1Enabled = false;
        widget.macDevices.isBit1Enabled = false;
      });
    }

    setState(() {

      widget.macDevices.macAddress1Connection = 'disconnected';
      widget.macDevices.macAddress2Connection = 'disconnected';

      widget.acquisitionNotifier.value = 'off';

      widget.batteryBit1Notifier.value = null;
      widget.batteryBit2Notifier.value = null;
    });

    saveBatteries(null, null);
    saveMAC('xx:xx:xx:xx:xx:xx', 'xx:xx:xx:xx:xx:xx');
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

  Future<void> _setup() async { // connects the client instance to the server and topic
    await widget.mqttClientWrapper
        .prepareMqttClient()
        .then((value) {
      if (widget.connectionNotifier.value ==
          MqttCurrentConnectionState.CONNECTED) {
        var timeStamp = DateTime.now();
        String time =
            "${timeStamp.year}-${timeStamp.month}-${timeStamp.day} ${timeStamp.hour}:${timeStamp.minute}:${timeStamp.second}";
        widget.mqttClientWrapper.publishMessage("['TIME', '$time']");
        widget.mqttClientWrapper.publishMessage("['Send default']");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
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
                                fontWeight: FontWeight.bold,
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
                              fontWeight: FontWeight.bold,
                              color: DefaultColors.textColorOnLight,
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
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: DefaultColors.mainLColor, // background
                      //onPrimary: Colors.white, // foreground
                    ),
                    onPressed: () {
                      _restart(true);
                      _setup();
                    },
                    child: new Text(
                      "Reiniciar",
                      style: MyTextStyle(
                        color: DefaultColors.textColorOnDark,
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
            /* Padding(
              padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
              child: ValueListenableBuilder(
                  valueListenable: widget.acquisitionNotifier,
                  builder: (BuildContext context, String state, Widget child) {
                    return RaisedButton(
                      textColor: DefaultColors.textColorOnLight,
                      disabledTextColor: Colors.transparent,
                      disabledColor: Colors.transparent,
                      elevation: state == 'acquiring' ? 2 : 0,
                      onPressed: state == 'acquiring' ? () {} : null,
                      child: new Text(
                        "Aquisição a decorrer!",
                      ),
                    );
                  }),
            ), */
          ]),
        ),
      ],
    );
  }
}
