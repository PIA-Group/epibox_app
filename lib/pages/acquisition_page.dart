import 'package:epibox/classes/configurations.dart';
import 'package:epibox/classes/devices.dart';
import 'package:epibox/classes/visualization.dart';
import 'package:epibox/decor/default_colors.dart';
import 'package:epibox/decor/text_styles.dart';
import 'package:epibox/navigation/visualization_destination.dart';
import 'package:epibox/utils/models.dart';
import 'package:epibox/utils/mqtt_wrapper.dart';
import 'package:flutter/material.dart';

class AcquisitionPage extends StatelessWidget {
  AcquisitionPage({
    this.devices,
    this.configurations,
    this.visualizationMAC1,
    this.visualizationMAC2,
    this.mqttClientWrapper,
    this.patientNotifier,
    this.annotationTypesD,
    this.connectionNotifier,
    this.timedOut,
    this.startupError,
  });

  final Devices devices;
  final Configurations configurations;
  final Visualization visualizationMAC1;
  final Visualization visualizationMAC2;

  final MQTTClientWrapper mqttClientWrapper;

  final ValueNotifier<String> patientNotifier;

  final ValueNotifier<List> annotationTypesD;

  final ValueNotifier<String> timedOut;
  final ValueNotifier<bool> startupError;

  final ValueNotifier<MqttCurrentConnectionState> connectionNotifier;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(children: [
        TabBar(
          tabs: [
            Tab(
              child: Text(
                devices.macAddress1,
                style: MyTextStyle(
                    color: DefaultColors.textColorOnLight, fontSize: 15),
              ),
            ),
            Tab(
              child: Text(
                devices.macAddress2,
                style: MyTextStyle(
                    color: DefaultColors.textColorOnLight, fontSize: 15),
              ),
            ),
          ],
        ),
        Expanded(
          child: TabBarView(children: [
            DestinationView(
              configurations: configurations,
              visualizationMAC: visualizationMAC1,
              mqttClientWrapper: mqttClientWrapper,
              patientNotifier: patientNotifier,
              annotationTypesD: annotationTypesD,
              connectionNotifier: connectionNotifier,
              timedOut: timedOut,
              startupError: startupError,
            ),
            DestinationView(
              configurations: configurations,
              visualizationMAC: visualizationMAC2,
              mqttClientWrapper: mqttClientWrapper,
              patientNotifier: patientNotifier,
              annotationTypesD: annotationTypesD,
              connectionNotifier: connectionNotifier,
              timedOut: timedOut,
              startupError: startupError,
            ),
          ]),
        ),
      ]),
    );
  }
}
