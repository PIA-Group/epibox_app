import 'package:property_change_notifier/property_change_notifier.dart';

class Visualization extends PropertyChangeNotifier<String> {
  List<List> _dataMAC = [];
  List _sensorsMAC = [];
  List<List> _channelsMAC = [];
  List<List<double>> _data2Plot = [];
  List<List<double>> _rangesList = List.filled(6, [-1, 10, 1]);
  bool _refresh = false;
  List<int> _annotateCanvas = [];
  List<List<int>> _events2Paint = [];

  List<List> get dataMAC => _dataMAC;
  List get sensorsMAC => _sensorsMAC;
  List<List> get channelsMAC => _channelsMAC;
  List<List<double>> get data2Plot => _data2Plot;
  List<List<double>> get rangesList => _rangesList;
  bool get refresh => _refresh;
  List<int> get annotateCanvas => _annotateCanvas;
  List<List<int>> get events2Paint => _events2Paint;

  set dataMAC(List<List> value) {
    _dataMAC = value;
    notifyListeners('dataMAC');
  }

  set sensorsMAC(List value) {
    _sensorsMAC = value;
    notifyListeners('sensorsMAC');
  }

  set channelsMAC(List<List> value) {
    _channelsMAC = value;
    notifyListeners('channelsMAC');
  }

  set data2Plot(List<List<double>> value) {
    _data2Plot = value;
    notifyListeners('data2Plot');
  }

  set rangesList(List<List<double>> value) {
    _rangesList = value;
    notifyListeners('rangesList');
  }

  set refresh(bool value) {
    _refresh = value;
    notifyListeners('refresh');
  }

  set annotateCanvas(List<int> value) {
    _annotateCanvas = value;
    notifyListeners('annotateCanvas');
  }

  set events2Paint(List<List<int>> value) {
    _events2Paint = value;
    notifyListeners('events2Paint');
  }
}
