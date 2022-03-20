import 'package:property_change_notifier/property_change_notifier.dart';

class ErrorHandler extends PropertyChangeNotifier<String> {
  /* This class is multi-purpose, used to notify the user of all kinds of
  messaged, using an overlay - the messages are defined in ../custom_overlays */

  Map<String, dynamic> _overlayInfo = {
    'overlayMessage': null,
    'timer': 2,
    'showOverlay': true
  };
  bool _showOverlay = false;

  Map<String, dynamic> get overlayInfo => _overlayInfo;
  bool get showOverlay => _showOverlay;

  set overlayInfo(Map<String, dynamic> value) {
    _overlayInfo = value;
    notifyListeners('overlayInfo');
  }

  set showOverlay(bool value) {
    _showOverlay = value;
    notifyListeners('showOverlay');
  }
}
