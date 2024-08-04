import 'package:epibox/acquisition/acquisition_management.dart';
import 'package:epibox/app_localizations.dart';
import 'package:epibox/classes/acquisition.dart';
import 'package:epibox/classes/configurations.dart';
import 'package:epibox/classes/devices.dart';
import 'package:epibox/classes/error_handler.dart';
import 'package:epibox/classes/shared_pref.dart';
import 'package:epibox/classes/visualization.dart';
import 'package:epibox/decor/default_colors.dart';
import 'package:epibox/mqtt/message_handler.dart';
import 'package:epibox/mqtt/mqtt_states.dart';
import 'package:epibox/mqtt/mqtt_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:property_change_notifier/property_change_notifier.dart';

class DrawerFloater extends StatelessWidget {
  const DrawerFloater({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment(-0.9, -0.65),
      child: Builder(builder: (context) {
        return FloatingActionButton(
            heroTag: null,
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            child: Icon(Icons.more_vert),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            });
      }),
    );
  }
}

class MQTTStateFloater extends StatelessWidget {
  final ValueNotifier<MqttCurrentConnectionState> connectionNotifier;

  MQTTStateFloater({Key key, this.connectionNotifier}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment(0.7, -0.65),
      child: Builder(builder: (context) {
        return ValueListenableBuilder(
            valueListenable: connectionNotifier,
            builder: (BuildContext context, MqttCurrentConnectionState state,
                Widget child) {
              return FloatingActionButton(
                  heroTag: null,
                  backgroundColor: Colors.transparent,
                  elevation: 0.0,
                  child: CircleAvatar(
                    key: Key('serverStateIcon'),
                    backgroundColor:
                        state == MqttCurrentConnectionState.CONNECTED
                            ? Colors.green[800]
                            : state == MqttCurrentConnectionState.CONNECTING
                                ? Colors.yellow[800]
                                : Colors.red[800],
                    radius: 20,
                    child: Icon(Icons.wifi_tethering, color: Colors.white),
                  ),
                  onPressed: null);
            });
      }),
    );
  }
}

class MACAddressConnectionFloater extends StatelessWidget {
  const MACAddressConnectionFloater({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment(1.1, -0.65),
      child: Builder(builder: (context) {
        return PropertyChangeConsumer<Devices>(
            properties: [
              'macAddress1Connection',
              'macAddress2Connection',
              'isBit1Enabled',
              'isBit2Enabled'
            ],
            builder: (context, devices, properties) {
              bool btState =
                  ((devices.macAddress1Connection == 'disconnected' &&
                          devices.macAddress2Connection == 'disconnected') ||
                      (devices.isBit1Enabled &&
                          devices.macAddress1Connection != 'connected') ||
                      (devices.isBit2Enabled &&
                          devices.macAddress2Connection != 'connected'));
              return FloatingActionButton(
                  heroTag: null,
                  backgroundColor: Colors.transparent,
                  elevation: 0.0,
                  child: CircleAvatar(
                      backgroundColor:
                          btState ? Colors.red[800] : Colors.green[800],
                      radius: 20,
                      child: btState
                          ? Icon(Icons.bluetooth_disabled_rounded,
                              color: Colors.white)
                          : Icon(Icons.bluetooth_connected_rounded,
                              color: Colors.white)),
                  onPressed: null);
            });
      }),
    );
  }
}

class SpeedAnnotationFloater extends StatelessWidget {
  final MQTTClientWrapper mqttClientWrapper;
  final ValueNotifier<String> patientNotifier;
  final Acquisition acquisition;
  final ErrorHandler errorHandler;
  final Preferences preferences;

  SpeedAnnotationFloater({
    Key key,
    this.mqttClientWrapper,
    this.patientNotifier,
    this.acquisition,
    this.errorHandler,
    this.preferences,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment(-0.8, 1.0),
      child: FloatingActionButton(
        backgroundColor: DefaultColors.mainLColor,
        mini: true,
        heroTag: null,
        onPressed: () => speedAnnotation(
          context: context,
          acquisition: acquisition,
          errorHandler: errorHandler,
          patientNotifier: patientNotifier,
          mqttClientWrapper: mqttClientWrapper,
          preferences: preferences,
        ),
        child: Icon(MdiIcons.lightningBolt),
      ),
    );
  }
}

class TimestampButton extends StatelessWidget {
  final MQTTClientWrapper mqttClientWrapper;
  final ErrorHandler errorHandler;
  const TimestampButton({Key key, this.mqttClientWrapper, this.errorHandler})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment(0.2, 1.0),
      child: PropertyChangeConsumer<Acquisition>(
          properties: ['acquisitionState'],
          builder: (context, acquisition, properties) {
            return FloatingActionButton(
              heroTag: null,
              backgroundColor: DefaultColors.mainLColor,
              mini: true,
              onPressed: () {
                sendActualDatetime(mqttClientWrapper);
              },
              child: Icon(Icons.access_time_filled),
            );
          }),
    );
  }
}

class StartStopButton extends StatelessWidget {
  final ValueNotifier<MqttCurrentConnectionState> connectionNotifier;
  final Devices devices;
  final ErrorHandler errorHandler;
  final Configurations configurations;
  final MQTTClientWrapper mqttClientWrapper;
  final Visualization visualizationMAC1;
  final Visualization visualizationMAC2;
  final ValueNotifier<String> patientNotifier;
  final ValueNotifier<List<String>> driveListNotifier;

  StartStopButton({
    Key key,
    this.connectionNotifier,
    this.devices,
    this.errorHandler,
    this.configurations,
    this.mqttClientWrapper,
    this.visualizationMAC1,
    this.visualizationMAC2,
    this.patientNotifier,
    this.driveListNotifier,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: PropertyChangeConsumer<Acquisition>(
          properties: ['acquisitionState'],
          builder: (context, acquisition, properties) {
            return FloatingActionButton.extended(
              heroTag: null,
              backgroundColor: DefaultColors.mainLColor,
              key: Key('startStopButton'),
              onPressed: () => stopAcquisition(mqttClientWrapper),
              label:
                  Text(AppLocalizations.of(context).translate('stop').inCaps),
              icon: Icon(Icons.stop),
            );
          }),
    );
  }
}
