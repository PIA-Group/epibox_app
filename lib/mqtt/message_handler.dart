import 'package:epibox/classes/acquisition.dart';
import 'package:epibox/classes/configurations.dart';
import 'package:epibox/classes/devices.dart';
import 'package:epibox/classes/error_handler.dart';
import 'package:epibox/costum_overlays/system_overlay.dart';
import 'package:epibox/mqtt/mqtt_wrapper.dart';
import 'dart:convert';
import 'package:flutter/cupertino.dart';

void gotNewMessage({
  String message,
  MQTTClientWrapper mqttClientWrapper,
  Devices devices,
  Acquisition acquisition,
  Configurations configurations,
  ValueNotifier<List<String>> driveListNotifier,
  ValueNotifier<String> timedOut,
  ErrorHandler errorHandler,
  ValueNotifier<bool> startupError,
  ValueNotifier<String> shouldRestart,
}) {
  // runs functions based on the received message
  List message2List = json.decode(message.replaceAll('\'', '\"'));

  if (message2List[0] != 'DATA') print('message received: ${message2List[0]}');

  switch (message2List[0]) {
    case 'DEFAULT MAC':
      isMACAddress(message2List, devices);
      break;
    case 'MAC STATE':
      isMACState(message, devices);
      break;
    case 'DRIVES':
      isDrivesList(message, driveListNotifier, mqttClientWrapper);
      break;
    case 'DEFAULT CONFIG':
      isDefaultConfig(message2List, configurations);
      break;
    case 'DATA':
      isData(message2List, devices, acquisition);
      break;
    case 'BATTERY':
      isBatteryLevel(message2List, devices, acquisition);
      break;
    case 'TIMEOUT':
      isTimeout(message2List, timedOut);
      break;
    case 'ERROR':
      isStartupError(startupError, shouldRestart);
      break;
    case 'TURNED OFF':
      isTurnedOff(errorHandler, shouldRestart);
      break;
    case 'STARTING':
    case 'ACQUISITION ON':
    case 'RECONNECTING':
    case 'PAIRING':
    case 'STOPPED':
    case 'PAUSED':
      isAcquisitionState(message, acquisition, shouldRestart);
      break;
    default:
      break;
  }
}

// DEVICES

void isMACAddress(List message2List, Devices devices) {
  try {
    devices.defaultMacAddress1 = message2List[1];
    devices.defaultMacAddress2 = message2List[2];
    devices.macAddress1 = message2List[1];
    devices.macAddress2 = message2List[2];
  } catch (e) {
    print(e);
  }

  if (devices.defaultMacAddress1 == '' || devices.defaultMacAddress1 == ' ') {
    devices.isBit1Enabled = false;
  } else {
    devices.isBit1Enabled = true;
  }
  if (devices.defaultMacAddress2 == '' || devices.defaultMacAddress2 == ' ') {
    devices.isBit2Enabled = false;
  } else {
    devices.isBit2Enabled = true;
  }
}

void isMACState(String message, Devices devices) {
  List messageList = json.decode(message.replaceAll('\'', '\"'));

  if (messageList[1] == devices.macAddress1) {
    devices.macAddress1Connection = messageList[2];
  } else if (messageList[1] == devices.macAddress2) {
    devices.macAddress2Connection = messageList[2];
  } else {
    print('Not valid MAC address');
  }
}

// CONFIGURATIONS

void isDrivesList(String message, ValueNotifier<List<String>> driveListNotifier,
    MQTTClientWrapper mqttClientWrapper) {
  try {
    List<String> listDrives = message.split(",");
    listDrives.removeAt(0);
    listDrives = listDrives.map((drive) => drive.split("'")[1]).toList();
    driveListNotifier.value = listDrives;
    //mqttClientWrapper.publishMessage("['GO TO DEVICES']");
  } catch (e) {
    print(e);
  }
}

void isDefaultConfig(List message2List, Configurations configurations) {
  configurations.configDefault = message2List[1];
}

// ACQUISITION

void isAcquisitionState(String message, Acquisition acquisition,
    ValueNotifier<String> shouldRestart) {
  if (message.contains('STARTING')) {
    acquisition.acquisitionState = 'starting';
  } else if (message.contains('ACQUISITION ON')) {
    if (acquisition.acquisitionState != 'acquiring') {
      print('changed acquisition state in isAcquisitionState');
      acquisition.acquisitionState = 'acquiring';
    }
  } else if (message.contains('RECONNECTING')) {
    acquisition.acquisitionState = 'reconnecting';
  } else if (message.contains('PAIRING')) {
    acquisition.acquisitionState = 'pairing';
  } else if (message.contains('STOPPED')) {
    acquisition.acquisitionState = 'stopped';
    shouldRestart.value = 'medium';
  } else if (message.contains('PAUSED')) {
    acquisition.acquisitionState = 'paused';
  }
}

void isData(List message2List, Devices devices, Acquisition acquisition) {
  if (acquisition.acquisitionState != 'acquiring') {
    print('changed acquisition state in isData');
    acquisition.acquisitionState = 'acquiring';
  }
  if (devices.macAddress1.trim() != '' &&
      devices.macAddress1Connection != 'connected')
    devices.macAddress1Connection = 'connected';
  if (devices.macAddress2.trim() != '' &&
      devices.macAddress2Connection != 'connected')
    devices.macAddress2Connection = 'connected';

  List<List> dataMAC1 = [];
  List<List> dataMAC2 = [];

  List<int> annotateCanvas1 = [];
  List<int> annotateCanvas2 = [];

  message2List[2].asMap().forEach((index, channel) {
    if (channel[0] == devices.macAddress1) {
      dataMAC1.add(message2List[1][index]);
      annotateCanvas1.add(channel[2]);
    } else {
      dataMAC2.add(message2List[1][index]);
      annotateCanvas2.add(channel[2]);
    }
  });

  acquisition.dataMAC1 = dataMAC1;
  acquisition.dataMAC2 = dataMAC2;
}

void isBatteryLevel(
    List message2List, Devices devices, Acquisition acquisition) {
  double _levelRatio;
  for (var entry in message2List[1].entries) {
    // list of dict [{'MAC1': ABAT in volts}, {'MAC2': ABAT in volts}]

    _levelRatio = (entry.value - 3.4) / (4.2 - 3.4);
    double _level = (_levelRatio > 1)
        ? 1
        : (_levelRatio < 0)
            ? 0
            : _levelRatio;

    if (entry.key == devices.macAddress1) {
      acquisition.batteryBit1 = _level;
      /* if (entry.value <= 3.4) { //TODO: deal with battery
            showNotification('1');
          } */
    } else if (entry.key == devices.macAddress2) {
      acquisition.batteryBit2 = _level;
      /* if (entry.value <= 3.4) {
            showNotification('2');
          } */
    }
  }
  /* saveBatteries(acquisition.batteryBit1.toString(),
          acquisition.batteryBit2.toString()); */
}

/* showNotification(device) async {
    print('BATERIA BAIXA: DEVICE $device');
    var android = AndroidNotificationDetails('id', 'channel ', 'description',
        priority: Priority.high, importance: Importance.max);
    var iOS = IOSNotificationDetails();
    var platform = new NotificationDetails(android: android, iOS: iOS);
    await batteryNotification.show(
        0, 'Bateria fraca', 'Trocar bateria do dispositivo $device', platform);
  } */

// SYSTEM

void isTimeout(List message2List, ValueNotifier<String> timedOut) {
  timedOut.value = message2List[1];
}

void isStartupError(
    ValueNotifier<bool> startupError, ValueNotifier<String> shouldRestart) {
  startupError.value = true;
  shouldRestart.value = 'medium';
}

void isTurnedOff(
    ErrorHandler errorHandler, ValueNotifier<String> shouldRestart) {
  shouldRestart.value = 'medium';
  errorHandler.overlayInfo = {
    'overlayMessage': SystemCustomOverlay(),
    'timer': 2,
    'showOverlay': true
  };
}
