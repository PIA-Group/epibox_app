import 'package:epibox/classes/acquisition.dart';
import 'package:epibox/classes/configurations.dart';
import 'package:epibox/classes/devices.dart';
import 'package:epibox/classes/error_handler.dart';
import 'package:epibox/classes/visualization.dart';
import 'package:epibox/costum_overlays/error_overlays.dart';
import 'package:epibox/mqtt/mqtt_states.dart';
import 'package:epibox/mqtt/mqtt_wrapper.dart';
import 'package:epibox/pages/speed_annotation.dart';
import 'package:epibox/shared_pref/pref_handler.dart';
import 'package:flutter/material.dart';

Future<void> startAcquisition({
  BuildContext context,
  ValueNotifier<MqttCurrentConnectionState> connectionNotifier,
  Devices devices,
  ErrorHandler errorHandler,
  Configurations configurations,
  MQTTClientWrapper mqttClientWrapper,
  Visualization visualizationMAC1,
  Visualization visualizationMAC2,
  ValueNotifier<List<String>> historyMAC,
  ValueNotifier<String> patientNotifier,
  ValueNotifier<List<String>> driveListNotifier,
}) async {
  if (connectionNotifier.value != MqttCurrentConnectionState.CONNECTED ||
      (devices.isBit1Enabled && devices.macAddress1Connection != 'connected') ||
      (devices.isBit2Enabled && devices.macAddress2Connection != 'connected')) {
    errorHandler.overlayInfo = {
      'overlayMessage': VerifyConnectionsOverlay(),
      'timer': 2,
      'showOverlay': true
    };
  } else {
    String _newDrive = configurations.chosenDrive
        .substring(0, configurations.chosenDrive.indexOf('('))
        .trim();
    mqttClientWrapper.publishMessage("['FOLDER', '$_newDrive']");
    mqttClientWrapper
        .publishMessage("['FS', ${configurations.controllerFreq.text}]");
    mqttClientWrapper.publishMessage("['ID', '${patientNotifier.value}']");
    mqttClientWrapper
        .publishMessage("['SAVE RAW', '${configurations.saveRaw}']");
    mqttClientWrapper.publishMessage("['EPI SERVICE', '${devices.type}']");

    List<List> _channels = _getChannels(configurations, devices);
    List<List<String>> _channels2Send = _channels[0];
    mqttClientWrapper.publishMessage("['CHANNELS', $_channels2Send]");

    visualizationMAC1.channelsMAC = _channels[1][0];
    visualizationMAC1.sensorsMAC = _channels[2][0];
    // visualizationMAC1.data2Plot = List.filled(
    //     configurations.bit1Selections.where((item) => item).length, [],
    //     growable: true);

    visualizationMAC2.channelsMAC = _channels[1][1];
    visualizationMAC2.sensorsMAC = _channels[2][1];
    // visualizationMAC2.data2Plot = List.filled(
    //     configurations.bit2Selections.where((item) => item).length, [],
    //     growable: true);

    mqttClientWrapper.publishMessage("['START']");

    saveMAC(devices.macAddress1, devices.macAddress2);
    saveMACHistory(devices.macAddress1, devices.macAddress2, historyMAC);
    saveChannels(visualizationMAC1.channelsMAC, visualizationMAC2.channelsMAC);
    saveSensors(visualizationMAC1.sensorsMAC, visualizationMAC2.sensorsMAC);
    saveConfigurations(configurations, driveListNotifier);
  }
}

List<List> _getChannels(Configurations configurations, Devices devices) {
  List<List<String>> _channels2Send = [];
  List<List<List<String>>> _channels2Save = [[], []];
  List<List<String>> _sensors2Save = [[], []];

  configurations.bit1Selections.asMap().forEach((channel, value) {
    if (value) {
      _channels2Send.add([
        "'${devices.macAddress1}'",
        "'${(channel + 1).toString()}'",
        "'${configurations.controllerSensors[channel].text}'"
      ]);
      _channels2Save[0]
          .add(["${devices.macAddress1}", "${(channel + 1).toString()}"]);
      _sensors2Save[0].add("${configurations.controllerSensors[channel].text}");
    }
  });
  configurations.bit2Selections.asMap().forEach((channel, value) {
    if (value) {
      _channels2Send.add([
        "'${devices.macAddress2}'",
        "'${(channel + 1).toString()}'",
        "'${configurations.controllerSensors[channel + 5].text}'"
      ]);
      _channels2Save[1]
          .add(["${devices.macAddress2}", "${(channel + 1).toString()}"]);
      _sensors2Save[1]
          .add("${configurations.controllerSensors[channel + 5].text}");
    }
  });
  return [_channels2Send, _channels2Save, _sensors2Save];
}

void stopAcquisition(MQTTClientWrapper mqttClientWrapper) {
  mqttClientWrapper.publishMessage("['INTERRUPT']");
}

void resumeAcquisition(MQTTClientWrapper mqttClientWrapper) {
  mqttClientWrapper.publishMessage("['RESUME ACQ']");
}

void pauseAcquisition({
  MQTTClientWrapper mqttClientWrapper,
  BuildContext context,
  Acquisition acquisition,
  ErrorHandler errorHandler,
}) {
  if (acquisition.acquisitionState != 'acquiring') {
    errorHandler.overlayInfo = {
      'overlayMessage': NotAcquiringOverlay(),
      'timer': 2,
      'showOverlay': true
    };
  } else {
    mqttClientWrapper.publishMessage("['PAUSE ACQ']");
  }
}

Future<void> speedAnnotation({
  BuildContext context,
  Acquisition acquisition,
  ErrorHandler errorHandler,
  ValueNotifier<List> annotationTypesD,
  ValueNotifier<String> patientNotifier,
  MQTTClientWrapper mqttClientWrapper,
}) async {
  List<String> annotationTypes = List<String>.from(annotationTypesD.value);
  if (acquisition.acquisitionState != 'acquiring') {
    errorHandler.overlayInfo = {
      'overlayMessage': NotAcquiringOverlay(),
      'timer': 2,
      'showOverlay': true
    };
  } else {
    Navigator.of(context).push(new MaterialPageRoute<Null>(
        builder: (BuildContext context) {
          return SpeedAnnotationDialog(
            annotationTypesD: annotationTypesD,
            annotationTypes: annotationTypes,
            patientNotifier: patientNotifier,
            mqttClientWrapper: mqttClientWrapper,
          );
        },
        fullscreenDialog: true));
  }
}
