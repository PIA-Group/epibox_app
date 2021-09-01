import 'package:property_change_notifier/property_change_notifier.dart';

class Visualization extends PropertyChangeNotifier<String> {

  List<List> _dataMAC = [];
  List _sensorsMAC = [];
  List<List> _channelsMAC = [];
  List<List> _data2Plot = [];
  List<List<double>> _rangesList = List.filled(6, [-1, 10, 1]);
  

  List<List> get dataMAC => _dataMAC;
  List get sensorsMAC => _sensorsMAC;
  List<List> get channelsMAC => _channelsMAC;
  List<List> get data2Plot => _data2Plot;
  List<List<double>> get rangesList => _rangesList;


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

  set data2Plot(List<List> value) {
    _data2Plot = value;
    notifyListeners('data2Plot');
  }

  set rangesList(List<List<double>> value) {
    _rangesList = value;
    notifyListeners('rangesList');
  }

  
}