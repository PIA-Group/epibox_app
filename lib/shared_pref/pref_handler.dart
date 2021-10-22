import 'package:epibox/classes/acquisition.dart';
import 'package:epibox/classes/configurations.dart';
import 'package:epibox/classes/devices.dart';
import 'package:epibox/classes/visualization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// DEVICES

void getLastMAC(Devices devices) async {
  await SharedPreferences.getInstance().then((prefs) {
    if (prefs.containsKey('lastMAC')) {
      List<String> lastMAC = (prefs.getStringList('lastMAC').toList() ??
          ['xx:xx:xx:xx:xx:xx', 'xx:xx:xx:xx:xx:xx']);
      /* devices.defaultMacAddress1 = lastMAC[0];
      devices.defaultMacAddress2 = lastMAC[1]; */
      devices.macAddress1 = lastMAC[0];
      devices.macAddress2 = lastMAC[1];
    } else {
      List<String> lastMAC = ['xx:xx:xx:xx:xx:xx', 'xx:xx:xx:xx:xx:xx'];
      /* devices.defaultMacAddress1 = lastMAC[0];
      devices.defaultMacAddress2 = lastMAC[1]; */
      devices.macAddress1 = lastMAC[0];
      devices.macAddress2 = lastMAC[1];
    }
  });
}

void getLastDeviceType(Devices devices) async {
  await SharedPreferences.getInstance().then((prefs) {
    if (prefs.containsKey('deviceType')) {
      try {
        String device = prefs.getString('deviceType') ?? 'Bitalino';
        devices.type = device;
      } catch (e) {
        print(e);
      }
    } else {
      devices.type = 'Bitalino';
    }
  });
}

Future<void> saveChannels(
    List<List> channelsMAC1, List<List> channelsMAC2) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  try {
    await prefs.setString('channelsMAC1', json.encode(channelsMAC1));
  } catch (e) {
    print(e);
  }

  try {
    await prefs.setString('channelsMAC2', json.encode(channelsMAC2));
  } catch (e) {
    print(e);
  }
}

void getLastChannels(
    Visualization visualizationMAC1, Visualization visualizationMAC2) async {
  await SharedPreferences.getInstance().then((prefs) {
    if (prefs.containsKey('channelsMAC1')) {
      try {
        List<List> channels =
            List<List>.from(json.decode(prefs.getString('channelsMAC1'))) ?? [];
        visualizationMAC1.channelsMAC = channels;
      } catch (e) {
        print(e);
      }
    } else {
      visualizationMAC1.channelsMAC = [];
    }

    if (prefs.containsKey('channelsMAC2')) {
      try {
        List<List> channels =
            List<List>.from(json.decode(prefs.getString('channelsMAC2'))) ?? [];
        visualizationMAC2.channelsMAC = channels;
      } catch (e) {
        print(e);
      }
    } else {
      visualizationMAC2.channelsMAC = [];
    }
  });
}

Future<void> saveSensors(List sensorsMAC1, List sensorsMAC2) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  try {
    await prefs.setString('sensorsMAC1', json.encode(sensorsMAC1));
  } catch (e) {
    print(e);
  }

  try {
    await prefs.setString('sensorsMAC2', json.encode(sensorsMAC2));
  } catch (e) {
    print(e);
  }
}

void getLastSensors(
    Visualization visualizationMAC1, Visualization visualizationMAC2) async {
  await SharedPreferences.getInstance().then((prefs) {
    if (prefs.containsKey('sensorsMAC1')) {
      try {
        List sensors = json.decode(prefs.getString('sensorsMAC1')) ?? [];
        visualizationMAC1.sensorsMAC = sensors;
      } catch (e) {
        print(e);
      }
    } else {
      visualizationMAC1.sensorsMAC = [];
    }

    if (prefs.containsKey('sensorsMAC2')) {
      try {
        List sensors = json.decode(prefs.getString('sensorsMAC2')) ?? [];
        visualizationMAC2.sensorsMAC = sensors;
      } catch (e) {
        print(e);
      }
    } else {
      visualizationMAC2.sensorsMAC = [];
    }
  });
}

Future<void> saveMAC(mac1, mac2) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  try {
    await prefs.setStringList('lastMAC', [mac1, mac2]);
  } catch (e) {
    print(e);
  }
}

Future<void> saveMACHistory(
    String mac1, String mac2, ValueNotifier<List<String>> historyMAC) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  try {
    if (mac1 != '' &&
        mac1 != ' ' &&
        mac1 != 'xx:xx:xx:xx:xx:xx' &&
        !historyMAC.value.contains(mac1)) {
      historyMAC.value.add(mac1);
      await prefs.setStringList('historyMAC', historyMAC.value);
    }
  } catch (e) {
    print(e);
  }

  try {
    if (mac2 != '' &&
        mac2 != ' ' &&
        mac2 != 'xx:xx:xx:xx:xx:xx' &&
        !historyMAC.value.contains(mac2)) {
      historyMAC.value.add(mac2);
      await prefs.setStringList('historyMAC', historyMAC.value);
    }
  } catch (e) {
    print(e);
  }
}

void getMACHistory(ValueNotifier<List<String>> historyMAC) async {
  await SharedPreferences.getInstance().then((prefs) {
    if (prefs.containsKey('historyMAC')) {
      try {
        List<String> history =
            (prefs.getStringList('historyMAC').toList() ?? [' ']);
        historyMAC.value = history;
      } catch (e) {
        print(e);
      }
    } else {
      historyMAC.value = [' '];
    }
  });
}

void getLastConfigurations(Configurations configurations,
    ValueNotifier<List<String>> driveListNotifier) async {
  await SharedPreferences.getInstance().then((prefs) {
    if (prefs.containsKey('configurations')) {
      try {
        Configurations auxConf = Configurations();
        String conf = (prefs.getString('configurations') ?? '');
        if (conf != '') {
          Map<String, dynamic> confMap = json.decode(conf);
          driveListNotifier.value
              .addAll(List<String>.from(confMap['driveList']));
          configurations.bit1Selections =
              List<bool>.from(confMap['bit1Selections']);
          configurations.bit2Selections =
              List<bool>.from(confMap['bit2Selections']);
          configurations.configDefault = confMap['configDefault'];
          configurations.controllerSensors = List.generate(
              12,
              (i) =>
                  TextEditingController(text: confMap['controllerSensors'][i]));
          configurations.chosenDrive = confMap['chosenDrive'];
          configurations.controllerFreq =
              TextEditingController(text: confMap['controllerFreq']);
          configurations.saveRaw = confMap['saveRaw'];

          //configurations = auxConf;
          //configurations.notifyConfigListeners();
          //configurations.controllerFreq = TextEditingController(text: '1000');
        }
      } catch (e) {
        print(e);
      }
    }
  });
}

void saveConfigurations(Configurations configurations,
    ValueNotifier<List<String>> driveListNotifier) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> listConfigurations = [
    'bit1Selections',
    'bit2Selections',
    'configDefault',
    'controllerSensors',
    'chosenDrive',
    'controllerFreq',
    'saveRaw'
  ];
  Map<String, dynamic> confMap =
      Map<String, dynamic>.fromIterable(listConfigurations,
          key: (item) => item,
          value: (item) {
            if (item == 'controllerSensors')
              return List.generate(
                  12, (i) => configurations.controllerSensors[i].text);
            else if (item == 'controllerFreq')
              return configurations.controllerFreq.text;
            else
              return configurations.get(item);
          });
  confMap['driveList'] = driveListNotifier.value;
  await prefs.setString('configurations', json.encode(confMap));
}

void removeSharedPrefs(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove(key);
}

// ANNOTATIONS

void getAnnotationTypes(ValueNotifier<List> annotationTypesD) async {
  await SharedPreferences.getInstance().then((prefs) {
    if (prefs.containsKey('annotationTypes')) {
      try {
        List annot = prefs.getStringList('annotationTypes').toList() ?? [];
        annotationTypesD.value = annot;
      } catch (e) {
        print(e);
      }
    } else {
      annotationTypesD.value = [];
    }
  });
}

// BATTERIES

void getLastBatteries(Acquisition acquisition) async {
  await SharedPreferences.getInstance().then((prefs) {
    if (prefs.containsKey('lastBatteries')) {
      try {
        List<String> lastBatteries =
            (prefs.getStringList('lastBatteries').toList() ?? [null, null]);
        if (lastBatteries[0] != null) {
          acquisition.batteryBit1 = num.tryParse(lastBatteries[0])?.toDouble();
        }
        if (lastBatteries[1] != null) {
          acquisition.batteryBit2 = num.tryParse(lastBatteries[1])?.toDouble();
        }
      } catch (e) {
        print(e);
      }
    }
  });
}

Future<void> saveBatteries(String battery1, String battery2) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  try {
    await prefs.setStringList('lastBatteries', [
      battery1,
      battery2,
    ]);
  } catch (e) {
    print(e);
  }
}
