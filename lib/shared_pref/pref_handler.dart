import 'package:epibox/classes/acquisition.dart';
import 'package:epibox/classes/devices.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// DEVICES

void getLastMAC(Devices devices) async {
  await SharedPreferences.getInstance().then((value) {
    List<String> lastMAC = (value.getStringList('lastMAC').toList() ??
        ['xx:xx:xx:xx:xx:xx', 'xx:xx:xx:xx:xx:xx']);
    devices.defaultMacAddress1 = lastMAC[0];
    devices.defaultMacAddress2 = lastMAC[1];
  });
}

void getPreviousDeviceType(Devices devices) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String device;
  try {
    device = prefs.getString('deviceType') ?? 'Bitalino';
    devices.type = device;
  } catch (e) {
    print(e);
  }
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
  await Future.delayed(Duration.zero);
  List<String> history;
  await SharedPreferences.getInstance().then((value) {
    try {
      history = (value.getStringList('historyMAC').toList() ?? [' ']);
    } catch (e) {
      history = [' '];
    }
    historyMAC.value = history;
  });
}

// ANNOTATIONS

void getAnnotationTypes(ValueNotifier<List> annotationTypesD) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List annot;
  try {
    if (prefs.containsKey('annotationTypes')) {
      annot = prefs.getStringList('annotationTypes').toList() ?? [];
      annotationTypesD.value = annot;
    }
  } catch (e) {
    print(e);
  }
}

// BATTERIES

void getLastBatteries(Acquisition acquisition) async {
  await Future.delayed(Duration.zero);
  await SharedPreferences.getInstance().then((value) {
    List<String> lastBatteries =
        (value.getStringList('lastBatteries').toList() ?? [null, null]);
    if (lastBatteries[0] != null) {
      print(lastBatteries[0]);
      print(num.tryParse(lastBatteries[0])?.toDouble());
      acquisition.batteryBit1 = num.tryParse(lastBatteries[0])?.toDouble();
    }
    if (lastBatteries[1] != null) {
      acquisition.batteryBit2 = num.tryParse(lastBatteries[1])?.toDouble();
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
