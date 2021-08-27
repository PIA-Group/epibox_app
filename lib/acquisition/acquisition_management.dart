import 'package:epibox/classes/configurations.dart';
import 'package:epibox/classes/devices.dart';
import 'package:epibox/classes/error_handler.dart';
import 'package:epibox/classes/visualization.dart';
import 'package:epibox/decor/default_colors.dart';
import 'package:epibox/decor/text_styles.dart';
import 'package:epibox/mqtt/mqtt_states.dart';
import 'package:epibox/mqtt/mqtt_wrapper.dart';
import 'package:epibox/pages/speed_annotation.dart';
import 'package:epibox/shared_pref/pref_handler.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';

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
}) async {
  if (connectionNotifier.value != MqttCurrentConnectionState.CONNECTED ||
      (devices.isBit1Enabled && devices.macAddress1Connection != 'connected') ||
      (devices.isBit2Enabled && devices.macAddress2Connection != 'connected')) {
    if (context.loaderOverlay.visible) context.loaderOverlay.hide();
    errorHandler.overlayMessage = Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(
            'Não foi possível iniciar',
            textAlign: TextAlign.center,
            style: MyTextStyle(
                color: DefaultColors.textColorOnLight, fontSize: 20),
          ),
          SizedBox(height: 20),
          Text(
            'Verifique a conexão ao servidor e aos dispositivos de aquisição!',
            textAlign: TextAlign.center,
            style: MyTextStyle(
                color: DefaultColors.textColorOnLight, fontSize: 20),
          ),
          SizedBox(height: 20),
        ]),
      ),
    );
    context.loaderOverlay.show();
    Future.delayed(const Duration(seconds: 3), () {
      context.loaderOverlay.hide();
    });
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

    visualizationMAC1.channelsMAC = _channels[1];
    visualizationMAC1.sensorsMAC = _channels[2];

    visualizationMAC2.channelsMAC = _channels[1];
    visualizationMAC2.sensorsMAC = _channels[2];

    mqttClientWrapper.publishMessage("['START']");

    saveMAC(devices.macAddress1, devices.macAddress2);
    saveMACHistory(devices.macAddress1, devices.macAddress2, historyMAC);
  }
}

List<List> _getChannels(Configurations configurations, Devices devices) {
  List<List<String>> _channels2Send = [];
  List<List<String>> _channels2Save = [];
  List<String> _sensors2Save = [];

  configurations.bit1Selections.asMap().forEach((channel, value) {
    if (value) {
      _channels2Send.add([
        "'${devices.macAddress1}'",
        "'${(channel + 1).toString()}'",
        "'${configurations.controllerSensors[channel].text}'"
      ]);
      _channels2Save
          .add(["${devices.macAddress1}", "${(channel + 1).toString()}"]);
      _sensors2Save.add("${configurations.controllerSensors[channel].text}");
    }
  });
  configurations.bit2Selections.asMap().forEach((channel, value) {
    if (value) {
      _channels2Send.add([
        "'${devices.macAddress2}'",
        "'${(channel + 1).toString()}'",
        "'${configurations.controllerSensors[channel + 5].text}'"
      ]);
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

void pauseAcquisition(MQTTClientWrapper mqttClientWrapper) {
  mqttClientWrapper.publishMessage("['PAUSE ACQ']");
}

Future<void> speedAnnotation(
    BuildContext context,
    ValueNotifier<List> annotationTypesD,
    ValueNotifier<String> patientNotifier,
    MQTTClientWrapper mqttClientWrapper) async {
  List<String> annotationTypes = List<String>.from(annotationTypesD.value);
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
