import 'package:epibox/bottom_navbar/destinations.dart';
import 'package:epibox/decor/default_colors.dart';
import 'package:epibox/decor/text_styles.dart';
import 'package:epibox/pages/visualization_destination.dart';
import 'package:epibox/utils/models.dart';
import 'package:epibox/utils/mqtt_wrapper.dart';
import 'package:flutter/material.dart';

class AcquisitionPage extends StatelessWidget {
  AcquisitionPage({
    this.dataMAC1Notifier,
    this.dataMAC2Notifier,
    this.channelsMAC1Notifier,
    this.channelsMAC2Notifier,
    this.sensorsMAC1Notifier,
    this.sensorsMAC2Notifier,
    this.mqttClientWrapper,
    this.acquisitionNotifier,
    this.batteryBit1Notifier,
    this.batteryBit2Notifier,
    this.patientNotifier,
    this.annotationTypesD,
    this.connectionNotifier,
    this.timedOut,
    this.startupError,
    this.macAddress1Notifier,
    this.macAddress2Notifier,
    this.allDestinations,
    this.saveRaw,
  });

  final ValueNotifier<String> macAddress1Notifier;
  final ValueNotifier<String> macAddress2Notifier;

  final ValueNotifier<List<List>> dataMAC1Notifier;
  final ValueNotifier<List<List>> dataMAC2Notifier;
  final ValueNotifier<List<List>> channelsMAC1Notifier;
  final ValueNotifier<List<List>> channelsMAC2Notifier;
  final ValueNotifier<List> sensorsMAC1Notifier;
  final ValueNotifier<List> sensorsMAC2Notifier;

  final MQTTClientWrapper mqttClientWrapper;

  final ValueNotifier<String> acquisitionNotifier;

  final ValueNotifier<double> batteryBit1Notifier;
  final ValueNotifier<double> batteryBit2Notifier;

  final ValueNotifier<String> patientNotifier;

  final ValueNotifier<List> annotationTypesD;

  final ValueNotifier<String> timedOut;
  final ValueNotifier<bool> startupError;

  final List<Destination> allDestinations;

  final ValueNotifier<MqttCurrentConnectionState> connectionNotifier;

  final ValueNotifier<bool> saveRaw;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(children: [
        TabBar(
          tabs: [
            Tab(
              child: Text(macAddress1Notifier.value, style: MyTextStyle(color: DefaultColors.textColorOnLight),),
            ),
            Tab(
              child: Text(macAddress2Notifier.value, style: MyTextStyle(color: DefaultColors.textColorOnLight),),
            ),
          ],
        ),
        Expanded(
          child: TabBarView(
            children: allDestinations.map<Widget>((Destination destination) {
              return DestinationView(
                destination: destination,
                dataMAC1Notifier: dataMAC1Notifier,
                dataMAC2Notifier: dataMAC2Notifier,
                channelsMAC1Notifier: channelsMAC1Notifier,
                channelsMAC2Notifier: channelsMAC2Notifier,
                sensorsMAC1Notifier: sensorsMAC1Notifier,
                sensorsMAC2Notifier: sensorsMAC2Notifier,
                mqttClientWrapper: mqttClientWrapper,
                acquisitionNotifier: acquisitionNotifier,
                batteryBit1Notifier: batteryBit1Notifier,
                batteryBit2Notifier: batteryBit2Notifier,
                patientNotifier: patientNotifier,
                annotationTypesD: annotationTypesD,
                connectionNotifier: connectionNotifier,
                timedOut: timedOut,
                startupError: startupError,
                saveRaw: saveRaw,
              );
            }).toList(),
          ),
        ),
      ]),
    );
  }
}