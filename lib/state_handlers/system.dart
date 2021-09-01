import 'package:epibox/classes/acquisition.dart';
import 'package:epibox/classes/configurations.dart';
import 'package:epibox/classes/devices.dart';
import 'package:epibox/mqtt/mqtt_wrapper.dart';
import 'package:epibox/shared_pref/pref_handler.dart';
import 'package:flutter/material.dart';

Future<void> restart(
    String restart,
    MQTTClientWrapper mqttClientWrapper,
    Devices devices,
    Acquisition acquisition,
    Configurations configurations,
    ValueNotifier<List<String>> driveListNotifier) async {
  mqttClientWrapper.publishMessage("['RESTART']");

  if (restart == 'full') {
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
    
  } else if (restart == 'medium') {
    acquisition.batteryBit1 = null;
    acquisition.batteryBit2 = null;

    saveBatteries(null, null);
    saveMAC('xx:xx:xx:xx:xx:xx', 'xx:xx:xx:xx:xx:xx');
  }

  devices.macAddress1Connection = 'disconnected';
  devices.macAddress2Connection = 'disconnected';
  acquisition.acquisitionState = 'off';
}
