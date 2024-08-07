import 'package:epibox/app_localizations.dart';
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
  /* This page allows the user to connect the EpiBOX App to the MQTT server,
  i.e. the EpiBOX App becomes a MQTT client, both as a publisher and subscriber */

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
    final height = MediaQuery.of(context).size.height -
        MediaQuery.of(context).viewInsets.top -
        MediaQuery.of(context).viewInsets.bottom;

    return ListView(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: height * 0.01),
          child: Column(children: [
            Text(
              AppLocalizations.of(context).translate('welcome to').inCaps,
              style: MyTextStyle(
                fontSize: 18,
                color: DefaultColors.mainColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text('EpiBOX',
                style: TextStyle(
                    fontSize: 70,
                    fontFamily: 'canter',
                    color: DefaultColors.mainColor)),
          ]),
        ),
        Padding(
          padding: EdgeInsets.only(top: 30.0),
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
                            text: AppLocalizations.of(context)
                                    .translate(
                                        'to connect to the server and (re)start the process, press')
                                    .inCaps +
                                ' ',
                            style: MyTextStyle(
                                color: DefaultColors.textColorOnLight)),
                        TextSpan(
                            text:
                                '"${AppLocalizations.of(context).translate("connect").inCaps}/${AppLocalizations.of(context).translate("restart").inCaps}"',
                            style: MyTextStyle(
                                fontWeight: FontWeight.bold,
                                color: DefaultColors.textColorOnLight)),
                        TextSpan(
                            text: '. ' +
                                AppLocalizations.of(context)
                                    .translate(
                                        'this will initiate all necessary procedures to start the data acquisition')
                                    .inCaps +
                                '!',
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
                      if (widget.connectionNotifier.value !=
                              MqttCurrentConnectionState.DISCONNECTED &&
                          widget.connectionNotifier.value !=
                              MqttCurrentConnectionState.ERROR_WHEN_CONNECTING)
                        widget.shouldRestart.value = 'full';
                      else
                        setup(widget.mqttClientWrapper,
                            widget.connectionNotifier);
                    },
                    child: new Text(
                      '${AppLocalizations.of(context).translate("connect").inCaps} / ${AppLocalizations.of(context).translate("restart").inCaps}',
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
                            text: AppLocalizations.of(context)
                                .translate('in case you are')
                                .inCaps,
                            style: MyTextStyle(
                                color: DefaultColors.textColorOnLight)),
                        TextSpan(
                            text:
                                ' ${AppLocalizations.of(context).translate("connected to the server")} ',
                            style: MyTextStyle(
                                fontWeight: FontWeight.bold,
                                color: DefaultColors.textColorOnLight)),
                        TextSpan(
                            text: AppLocalizations.of(context).translate(
                                    'but the process has not yet started, restart') +
                                '. ' +
                                AppLocalizations.of(context)
                                    .translate(
                                        'as a last resort, turn the RPi off and turn it on again')
                                    .inCaps +
                                '.',
                            style: MyTextStyle(
                              color: DefaultColors.textColorOnLight,
                            )),
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
