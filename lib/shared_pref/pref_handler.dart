import 'package:epibox/classes/acquisition.dart';
import 'package:epibox/classes/devices.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// DEVICES

void getLastMAC(Devices devices) async {
  await SharedPreferences.getInstance().then((prefs) {
    if (prefs.containsKey('lastMAC')) {
      List<String> lastMAC = (prefs.getStringList('lastMAC').toList() ??
          ['xx:xx:xx:xx:xx:xx', 'xx:xx:xx:xx:xx:xx']);
      devices.defaultMacAddress1 = lastMAC[0];
      devices.defaultMacAddress2 = lastMAC[1];
    } else {
      List<String> lastMAC = ['xx:xx:xx:xx:xx:xx', 'xx:xx:xx:xx:xx:xx'];
      devices.defaultMacAddress1 = lastMAC[0];
      devices.defaultMacAddress2 = lastMAC[1];
    }
  });
}

void getPreviousDeviceType(Devices devices) async {
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
