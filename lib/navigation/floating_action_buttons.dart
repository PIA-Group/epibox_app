import 'package:epibox/acquisition/acquisition_management.dart';
import 'package:epibox/classes/acquisition.dart';
import 'package:epibox/classes/configurations.dart';
import 'package:epibox/classes/devices.dart';
import 'package:epibox/classes/error_handler.dart';
import 'package:epibox/classes/visualization.dart';
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
                  backgroundColor: Colors.transparent,
                  elevation: 0.0,
                  child: CircleAvatar(
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
  final ValueNotifier<List> annotationTypesD;
  final ValueNotifier<String> patientNotifier;

  SpeedAnnotationFloater(
      {Key key,
      this.mqttClientWrapper,
      this.annotationTypesD,
      this.patientNotifier})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment(-0.8, 1.0),
      child: FloatingActionButton(
        mini: true,
        heroTag: null,
        onPressed: () => speedAnnotation(
            context, annotationTypesD, patientNotifier, mqttClientWrapper),
        child: Icon(MdiIcons.lightningBolt),
      ),
    );
  }
}

class ResumePauseButton extends StatelessWidget {
  final MQTTClientWrapper mqttClientWrapper;
  const ResumePauseButton({Key key, this.mqttClientWrapper}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment(0.2, 1.0),
      child: PropertyChangeConsumer<Acquisition>(
          properties: ['acquisitionState'],
          builder: (context, acquisition, properties) {
            return FloatingActionButton(
              mini: true,
              onPressed: acquisition.acquisitionState == 'paused'
                  ? () => resumeAcquisition(mqttClientWrapper)
                  : () => pauseAcquisition(mqttClientWrapper),
              child: acquisition.acquisitionState == 'paused'
                  ? Icon(Icons.play_arrow)
                  : Icon(Icons.pause),
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
  final ValueNotifier<List<String>> historyMAC;
  final ValueNotifier<String> patientNotifier;

  StartStopButton({
    Key key,
    this.connectionNotifier,
    this.devices,
    this.errorHandler,
    this.configurations,
    this.mqttClientWrapper,
    this.visualizationMAC1,
    this.visualizationMAC2,
    this.historyMAC,
    this.patientNotifier,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: PropertyChangeConsumer<Acquisition>(
          properties: ['acquisitionState'],
          builder: (context, acquisition, properties) {
            return FloatingActionButton.extended(
              onPressed: (acquisition.acquisitionState == 'stopped' ||
                      acquisition.acquisitionState == 'off')
                  ? () => startAcquisition(
                        context: context,
                        connectionNotifier: connectionNotifier,
                        devices: devices,
                        errorHandler: errorHandler,
                        configurations: configurations,
                        mqttClientWrapper: mqttClientWrapper,
                        visualizationMAC1: visualizationMAC1,
                        visualizationMAC2: visualizationMAC2,
                        historyMAC: historyMAC,
                        patientNotifier: patientNotifier,
                      )
                  : () => stopAcquisition(mqttClientWrapper),
              label: (acquisition.acquisitionState == 'stopped' ||
                      acquisition.acquisitionState == 'off')
                  ? Text('Iniciar')
                  : Text('Parar'),
              icon: (acquisition.acquisitionState == 'stopped' ||
                      acquisition.acquisitionState == 'off')
                  ? Icon(Icons.play_arrow_rounded)
                  : Icon(Icons.stop),
            );
          }),
    );
  }
}
