import 'package:flutter/material.dart';
import 'package:property_change_notifier/property_change_notifier.dart';

class Configurations extends PropertyChangeNotifier<String> {

  List<bool> _bit1Selections;
  List<bool> _bit2Selections;
  Map<String, dynamic> _configDefault = {};
  List<TextEditingController> _controllerSensors = List.generate(12, (i) => TextEditingController());
  String _chosenDrive = ' ';
  TextEditingController _controllerFreq = TextEditingController(text: ' ');
  bool _saveRaw = true;

  List<bool> get bit1Selections => _bit1Selections;
  List<bool> get bit2Selections => _bit2Selections;
  Map<String, dynamic> get configDefault => _configDefault;
  List<TextEditingController> get controllerSensors => _controllerSensors;
  String get chosenDrive => _chosenDrive;
  TextEditingController get controllerFreq => _controllerFreq;
  bool get saveRaw => _saveRaw;


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


}