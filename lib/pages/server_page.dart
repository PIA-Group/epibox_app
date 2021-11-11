import 'package:epibox/classes/acquisition.dart';
import 'package:epibox/classes/configurations.dart';
import 'package:epibox/classes/devices.dart';
import 'package:epibox/classes/error_handler.dart';
import 'package:epibox/mqtt/connection_manager.dart';
import 'package:flutter/material.dart';
import 'package:epibox/decor/default_colors.dart';
import 'package:epibox/decor/text_styles.dart';
import 'package:epibox/mqtt/mqtt_states.dart';
import 'package:epibox/mqtt/mqtt_wrapper.dart';
import 'package:mqtt_client/mqtt_client.dart';

class ServerPage extends StatefulWidget {
  final Devices devices;
  final Acquisition acquisition;

  final ValueNotifier<MqttCurrentConnectionState> connectionNotifier;
  MQTTClientWrapper mqttClientWrapper;

  final MqttClient client;
  final Configurations configurations;
  final ErrorHandler errorHandler;

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
    this.client,
    this.configurations,
    this.errorHandler,
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
                                'Para conectar ao servidor e iniciar (ou reiniciar) o processo, clicar em ',
                            style: MyTextStyle(
                                color: DefaultColors.textColorOnLight)),
                        TextSpan(
                            text: '"Conectar / Reiniciar"',
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
                      print(
                          'HERE current connectionstate: ${widget.connectionNotifier.value}');
                      if (widget.connectionNotifier.value !=
                              MqttCurrentConnectionState.DISCONNECTED &&
                          widget.connectionNotifier.value !=
                              MqttCurrentConnectionState.ERROR_WHEN_CONNECTING)
                        widget.shouldRestart.value = 'full';
                      Future.delayed(Duration.zero).then((value) {
                        // widget.mqttClientWrapper = setupHome(
                        //   mqttClientWrapper: widget.mqttClientWrapper,
                        //   client: widget.client,
                        //   devices: widget.devices,
                        //   acquisition: widget.acquisition,
                        //   configurations: widget.configurations,
                        //   driveListNotifier: widget.driveListNotifier,
                        //   timedOut: widget.timedOut,
                        //   errorHandler: widget.errorHandler,
                        //   startupError: widget.startupError,
                        //   shouldRestart: widget.shouldRestart,
                        //   connectionNotifier: widget.connectionNotifier,
                        // );
                        setup(widget.mqttClientWrapper,
                            widget.connectionNotifier);
                      });
                    },
                    child: new Text(
                      "Conectar / Reiniciar",
                      key: Key('connectServerButton'),
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
                                'tenha sido iniciado, reinincie. Em último caso, desligue e volte a ligar o dispositivo.',
                            style: MyTextStyle(
                                color: DefaultColors.textColorOnLight)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ]),
        ),
      ],
    );
  }
}
