import 'package:property_change_notifier/property_change_notifier.dart';

class Acquisition extends PropertyChangeNotifier<String> {
  String _acquisitionState = 'off';
  double _batteryBit1;
  double _batteryBit2;
  List<List> _dataMAC1 = [];
  List<List> _dataMAC2 = [];
  List<List> _channelsMAC1 = [];
  List<List> _channelsMAC2 = [];
  List _sensorsMAC1 = [];
  List _sensorsMAC2 = [];
  List<int> _annotateCanvas1 = [];
  List<int> _annotateCanvas2 = [];

  String get acquisitionState => _acquisitionState;
  double get batteryBit1 => _batteryBit1;
  double get batteryBit2 => _batteryBit2;
  List<List> get dataMAC1 => _dataMAC1;
  List<List> get dataMAC2 => _dataMAC2;
  List<List> get channelsMAC1 => _channelsMAC1;
  List<List> get channelsMAC2 => _channelsMAC2;
  List get sensorsMAC1 => _sensorsMAC1;
  List get sensorsMAC2 => _sensorsMAC2;
  List<int> get annotateCanvas1 => _annotateCanvas1;
  List<int> get annotateCanvas2 => _annotateCanvas2;

  set acquisitionState(String value) {
    _acquisitionState = value;
    notifyListeners('acquisitionState');
  }

  set batteryBit1(double value) {
    _batteryBit1 = value;
    notifyListeners('batteryBit1');
  }

  set batteryBit2(double value) {
    _batteryBit2 = value;
    notifyListeners('batteryBit2');
  }

  set dataMAC1(List<List> value) {
    _dataMAC1 = value;
    notifyListeners('dataMAC1');
  }

  set dataMAC2(List<List> value) {
    _dataMAC2 = value;
    notifyListeners('dataMAC2');
  }

  set channelsMAC1(List<List> value) {
    _channelsMAC1 = value;
    notifyListeners('channelsMAC1');
  }

  set channelsMAC2(List<List> value) {
    _channelsMAC2 = value;
    notifyListeners('channelsMAC2');
  }

  set sensorsMAC1(List value) {
    _sensorsMAC1 = value;
    notifyListeners('sensorsMAC1');
  }

  set sensorsMAC2(List value) {
    _sensorsMAC2 = value;
    notifyListeners('sensorsMAC2');
  }

  set annotateCanvas1(List<int> value) {
    _annotateCanvas1 = value;
    notifyListeners('annotateCanvas1');
  }

  set annotateCanvas2(List<int> value) {
    _annotateCanvas2 = value;
    notifyListeners('annotateCanvas2');
  }
}
