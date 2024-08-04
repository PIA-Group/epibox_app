import 'package:epibox/classes/configurations.dart';
import 'package:epibox/classes/devices.dart';
import 'package:epibox/classes/shared_pref.dart';
import 'package:epibox/mqtt/message_handler.dart';
import 'package:epibox/mqtt/mqtt_wrapper.dart';
import 'package:epibox/shared_pref/pref_handler.dart';
import 'package:flutter/material.dart';

List<List<String>> _getChannels2Send(Configurations configurations) {
  List<List<String>> _channels2Send = [];
  configurations.bit1Selections.asMap().forEach((channel, value) {
    if (value) {
      _channels2Send.add([
        // "'${widget.devices.macAddress1}'",
        "'MAC1'",
        "'${(channel + 1).toString()}'",
        "'${configurations.controllerSensors[channel].text}'"
      ]);
    }
  });

  configurations.bit2Selections.asMap().forEach((channel, value) {
    if (value) {
      _channels2Send.add([
        // "'${widget.devices.macAddress2}'",
        "'MAC2'",
        "'${(channel + 1).toString()}'",
        "'${configurations.controllerSensors[channel + 5].text}'"
      ]);
    }
  });
  return _channels2Send;
}

void newDefault(
    MQTTClientWrapper mqttClientWrapper,
    Configurations configurations,
    Devices devices,
    ValueNotifier<String> patientNotifier,
    Preferences preferences) {
  List<List<String>> _channels2Send = _getChannels2Send(configurations);
  saveMACHistory(devices.macAddress1, devices.macAddress2, preferences);
  print('chosen drive: ${configurations.chosenDrive.trim().isEmpty}');
  String _newDefaultDrive = 'EpiBOX Core';
  print(
      "['NEW CONFIG DEFAULT', {'initial_dir': '', 'fs': ${configurations.controllerFreq.text}, 'channels': $_channels2Send, 'save_raw': '${configurations.saveRaw}', 'devices_mac': {'MAC1':'${devices.macAddress1}','MAC2':'${devices.macAddress2}'}, 'patient_id': '${patientNotifier.value}', 'service': '${devices.type}'}]");
  if (configurations.chosenDrive.trim().isNotEmpty) {
    try {
      _newDefaultDrive = configurations.chosenDrive
          .substring(0, configurations.chosenDrive.indexOf('('))
          .trim();
    } catch (e) {
      _newDefaultDrive = configurations.chosenDrive.trim();
    }
  }
  mqttClientWrapper.publishMessage(
      "['NEW CONFIG DEFAULT', {'initial_dir': '$_newDefaultDrive', 'fs': ${configurations.controllerFreq.text}, 'channels': $_channels2Send, 'save_raw': '${configurations.saveRaw}', 'devices_mac': {'MAC1':'${devices.macAddress1}','MAC2':'${devices.macAddress2}'}, 'patient_id': '${patientNotifier.value}', 'service': '${devices.type}'}]");
}
