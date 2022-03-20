import 'package:epibox/classes/acquisition.dart';
import 'package:epibox/classes/configurations.dart';
import 'package:epibox/classes/devices.dart';
import 'package:epibox/mqtt/connection_manager.dart';
import 'package:epibox/mqtt/mqtt_states.dart';
import 'package:epibox/mqtt/mqtt_wrapper.dart';
import 'package:epibox/shared_pref/pref_handler.dart';
import 'package:flutter/material.dart';

Future<void> restart(
    String restart,
    MQTTClientWrapper mqttClientWrapper,
    ValueNotifier<MqttCurrentConnectionState> connectionNotifier,
    Devices devices,
    Acquisition acquisition,
    Configurations configurations,
    ValueNotifier<List<String>> driveListNotifier) async {
  if (restart == 'full') {
    //mqttClientWrapper.publishMessage("['RESTART']");
    await mqttClientWrapper.diconnectClient();

    devices.defaultMacAddress1 = 'xx:xx:xx:xx:xx:xx';
    devices.defaultMacAddress2 = 'xx:xx:xx:xx:xx:xx';

    devices.macAddress1 = 'xx:xx:xx:xx:xx:xx';
    devices.macAddress2 = 'xx:xx:xx:xx:xx:xx';

    driveListNotifier.value = [' '];
    configurations.chosenDrive = ' ';
    configurations.controllerFreq.text = ' ';

    devices.isBit1Enabled = false;
    devices.isBit2Enabled = false;

    await setup(mqttClientWrapper, connectionNotifier);
  } else if (restart == 'medium') {
    mqttClientWrapper.publishMessage("['RESTART']");
    acquisition.batteryBit1 = null;
    acquisition.batteryBit2 = null;

    saveBatteries(null, null);
    saveMAC('xx:xx:xx:xx:xx:xx', 'xx:xx:xx:xx:xx:xx');
    removeSharedPrefs('configurations');
  }
  Future.delayed(Duration.zero).then((value) {
    devices.macAddress1Connection = 'disconnected';
    devices.macAddress2Connection = 'disconnected';
    acquisition.acquisitionState = 'off';
  });
}
