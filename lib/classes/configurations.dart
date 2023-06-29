import 'package:flutter/material.dart';
import 'package:property_change_notifier/property_change_notifier.dart';

class Configurations extends PropertyChangeNotifier<String> {
  /* This class holds all information regarding acquisition 
  configurations, chosen by the user. */

  List<bool> _bit1Selections = [false, false, false, false, false, false];
  List<bool> _bit2Selections = [false, false, false, false, false, false];
  Map<String, dynamic> _configDefault = {};
  List<TextEditingController> _controllerSensors =
      List.generate(12, (i) => TextEditingController(text: '-'));
  String _chosenDrive = 'EpiBOX Core';
  TextEditingController _controllerFreq = TextEditingController(text: ' ');
  bool _saveRaw = true;

  List<bool> get bit1Selections => _bit1Selections;
  List<bool> get bit2Selections => _bit2Selections;
  Map<String, dynamic> get configDefault => _configDefault;
  List<TextEditingController> get controllerSensors => _controllerSensors;
  String get chosenDrive => _chosenDrive;
  TextEditingController get controllerFreq => _controllerFreq;
  bool get saveRaw => _saveRaw;

  dynamic get(String key) => <String, dynamic>{
        'bit1Selections': _bit1Selections,
        'bit2Selections': _bit2Selections,
        'configDefault': _configDefault,
        'controllerSensors': _controllerSensors,
        'chosenDrive': _chosenDrive,
        'controllerFreq': _controllerFreq,
        'saveRaw': _saveRaw,
      }[key];

  set bit1Selections(List<bool> value) {
    _bit1Selections = value;
    notifyListeners('bit1Selections');
  }

  set bit2Selections(List<bool> value) {
    _bit2Selections = value;
    notifyListeners('bit2Selections');
  }

  set configDefault(Map<String, dynamic> value) {
    _configDefault = value;
    notifyListeners('configDefault');
  }

  set controllerSensors(List<TextEditingController> value) {
    _controllerSensors = value;
    notifyListeners('controllerSensors');
  }

  set chosenDrive(String value) {
    _chosenDrive = value;
    notifyListeners('chosenDrive');
  }

  set controllerFreq(TextEditingController value) {
    _controllerFreq = value;
    notifyListeners('controllerFreq');
  }

  set saveRaw(bool value) {
    _saveRaw = value;
    notifyListeners('saveRaw');
  }

  void notifyConfigListeners() {
    notifyListeners('bit1Selections');
    notifyListeners('bit2Selections');
    notifyListeners('configDefault');
    notifyListeners('controllerSensors');
    notifyListeners('chosenDrive');
    notifyListeners('controllerFreq');
    notifyListeners('saveRaw');
  }
}
