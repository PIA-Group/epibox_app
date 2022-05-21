import 'package:property_change_notifier/property_change_notifier.dart';

class Preferences extends PropertyChangeNotifier<String> {
  /* This class holds all information stored in shared preferences. */

  List<String> _macHistory = [''];
  List<String> _annotationTypes = [];

  List<String> get macHistory => _macHistory;
  List<String> get annotationTypes => _annotationTypes;

  dynamic get(String key) => <String, dynamic>{
        'macHistory': _macHistory,
        'annotationTypes': _annotationTypes,
      }[key];

  set macHistory(List<String> value) {
    _macHistory = value;
    notifyListeners('macHistory');
  }

  set annotationTypes(List<String> value) {
    _annotationTypes = value;
    notifyListeners('annotationTypes');
  }

  void notifyConfigListeners() {
    notifyListeners('macHistory');
    notifyListeners('annotationTypes');
  }
}
