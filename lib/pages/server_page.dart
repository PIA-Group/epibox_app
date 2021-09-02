import 'package:epibox/classes/acquisition.dart';
import 'package:epibox/classes/devices.dart';
import 'package:epibox/mqtt/connection_manager.dart';
import 'package:flutter/material.dart';
import 'package:epibox/decor/default_colors.dart';
import 'package:epibox/decor/text_styles.dart';
import 'package:epibox/mqtt/mqtt_states.dart';
import 'package:epibox/mqtt/mqtt_wrapper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ServerPage extends StatefulWidget {
  final Devices devices;
  final Acquisition acquisition;

  final ValueNotifier<MqttCurrentConnectionState> connectionNotifier;
  final MQTTClientWrapper mqttClientWrapper;

  final ValueNotifier<List<String>> driveListNotifier;

  final ValueNotifier<bool> receivedMACNotifier;
  final ValueNotifier<String> hostnameNotifier;

  final ValueNotifier<bool> sentMACNotifier;

  final ValueNotifier<String> patientNotifier;

  final ValueNotifier<List> annotationTypesD;

  final ValueNotifier<String> timedOut;
  final ValueNotifier<bool> startupError;

  final ValueNotifier<TextEditingController> controllerFreq;

  final ValueNotifier<String> shouldRestart;

  ServerPage({
    this.devices,
    this.acquisition,
    this.mqttClientWrapper,
    this.connectionNotifier,
    this.receivedMACNotifier,
    this.driveListNotifier,
    this.hostnameNotifier,
    this.sentMACNotifier,
    this.patientNotifier,
    this.annotationTypesD,
    this.timedOut,
    this.startupError,
    this.controllerFreq,
    this.shouldRestart,
  });

  @override
  _ServerPageState createState() => _ServerPageState();
}

class _ServerPageState extends State<ServerPage> {
  String message;

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

  @override
  Widget build(BuildContext context) {
    print('rebuilding ServerPage');
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
                      setup(
                          widget.mqttClientWrapper, widget.connectionNotifier);
                    },
                    child: new Text(
                      "Conectar",
                      style: MyTextStyle(
                        color: DefaultColors.textColorOnDark,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    key: Key('connectServerButton'),
                    style: ElevatedButton.styleFrom(
                      primary: DefaultColors.mainLColor,
                    ),
                    onPressed: () {
                      widget.shouldRestart.value = 'full';
                      Future.delayed(Duration.zero).then((value) => setup(
                          widget.mqttClientWrapper, widget.connectionNotifier));
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
