import 'package:property_change_notifier/property_change_notifier.dart';

class ErrorHandler extends PropertyChangeNotifier<String> {
  /* Widget _overlayMessage = Center(
      child: SpinKitFoldingCube(
        color: DefaultColors.mainColor,
        size: 70.0,
      ),
    ); */

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
