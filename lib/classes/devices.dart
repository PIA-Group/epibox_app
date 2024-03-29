import 'package:property_change_notifier/property_change_notifier.dart';

class Devices extends PropertyChangeNotifier<String> {
  /* This class holds all information regarding the biosignal acquisition
  devices, including the ones chosen by the user ("macAddress") and the ones
  received via MQTT from PyEpiBOX. */

  String _macAddress1 = 'xx:xx:xx:xx:xx:xx';
  String _macAddress2 = 'xx:xx:xx:xx:xx:xx';
  String _defaultMacAddress1 = 'xx:xx:xx:xx:xx:xx';
  String _defaultMacAddress2 = 'xx:xx:xx:xx:xx:xx';
  String _macAddress1Connection = 'disconnected';
  String _macAddress2Connection = 'disconnected';
  bool _isBit1Enabled = false;
  bool _isBit2Enabled = false;
  String _type = 'bitalino';

  String get macAddress1 => _macAddress1;
  String get macAddress2 => _macAddress2;
  String get defaultMacAddress1 => _defaultMacAddress1;
  String get defaultMacAddress2 => _defaultMacAddress2;
  String get macAddress1Connection => _macAddress1Connection;
  String get macAddress2Connection => _macAddress2Connection;
  bool get isBit1Enabled => _isBit1Enabled;
  bool get isBit2Enabled => _isBit2Enabled;
  String get type => _type;

  dynamic get(String key) => <String, dynamic>{
        'macAddress1': _macAddress1,
        'macAddress2': _macAddress2,
        'defaultMacAddress1': _defaultMacAddress1,
        'defaultMacAddress2': _defaultMacAddress2,
        'macAddress1Connection': _macAddress1Connection,
        'macAddress2Connection': _macAddress2Connection,
        'isBit1Enabled': _isBit1Enabled,
        'isBit2Enabled': _isBit2Enabled,
        'type': _type,
      }[key];

  set macAddress1(String value) {
    _macAddress1 = value;
    notifyListeners('macAddress1');
  }

  set macAddress2(String value) {
    _macAddress2 = value;
    notifyListeners('macAddress2');
  }

  set defaultMacAddress1(String value) {
    _defaultMacAddress1 = value;
    notifyListeners('defaultMacAddress1');
  }

  set defaultMacAddress2(String value) {
    _defaultMacAddress2 = value;
    notifyListeners('defaultMacAddress2');
  }

  set macAddress1Connection(String value) {
    _macAddress1Connection = value;
    notifyListeners('macAddress1Connection');
  }

  set macAddress2Connection(String value) {
    _macAddress2Connection = value;
    notifyListeners('macAddress2Connection');
  }

  set isBit1Enabled(bool value) {
    _isBit1Enabled = value;
    notifyListeners('isBit1Enabled');
  }

  set isBit2Enabled(bool value) {
    _isBit2Enabled = value;
    notifyListeners('isBit2Enabled');
  }

  set type(String value) {
    _type = value;
    notifyListeners('type');
  }
}
