import 'package:property_change_notifier/property_change_notifier.dart';

class Configurations extends PropertyChangeNotifier<String> {

  List<bool> _bit1Selections;
  List<bool> _bit2Selections;

  List<bool> get bit1Selections => _bit1Selections;
  List<bool> get bit2Selections => _bit2Selections;


  set bit1Selections(List<bool> value) {
    _bit1Selections = value;
    notifyListeners('bit1Selections');
  }

  set bit2Selections(List<bool> value) {
    _bit2Selections = value;
    notifyListeners('bit2Selections');
  }


}