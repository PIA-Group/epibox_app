import 'package:epibox/classes/configurations.dart';
import 'package:epibox/classes/devices.dart';
import 'package:epibox/classes/visualization.dart';
import 'package:epibox/decor/default_colors.dart';
import 'package:epibox/decor/text_styles.dart';
import 'package:epibox/pages/visualization_page.dart';
import 'package:epibox/mqtt/mqtt_states.dart';
import 'package:epibox/mqtt/mqtt_wrapper.dart';
import 'package:flutter/material.dart';

class VisualizationNavPage extends StatelessWidget {
  VisualizationNavPage({
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
          tabs: [devices.macAddress1, devices.macAddress2]
              .map(
                (macAddress) => Tab(
                  child: Text(macAddress,
                      style: MyTextStyle(
                          color: DefaultColors.textColorOnLight, fontSize: 15)),
                ),
              )
              .toList(),
        ),
        Expanded(
          child: TabBarView(
            children: [visualizationMAC1, visualizationMAC2]
                .map(
                  (visualizationMAC) => VisualizationPage(
                    configurations: configurations,
                    visualizationMAC: visualizationMAC,
                    mqttClientWrapper: mqttClientWrapper,
                    patientNotifier: patientNotifier,
                    annotationTypesD: annotationTypesD,
                    connectionNotifier: connectionNotifier,
                    timedOut: timedOut,
                    startupError: startupError,
                  ),
                )
                .toList(),
          ),
        ),
      ]),
    );
  }
}
