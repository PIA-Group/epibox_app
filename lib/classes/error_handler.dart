import 'package:epibox/decor/default_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:property_change_notifier/property_change_notifier.dart';

class ErrorHandler extends PropertyChangeNotifier<String> {

  Widget _overlayMessage = Center(
      child: SpinKitFoldingCube(
        color: DefaultColors.mainColor,
        size: 70.0,
      ),
    );
  

  Widget get overlayMessage => _overlayMessage;


 set overlayMessage(Widget value) {
    _overlayMessage = value;
    notifyListeners('overlayMessage');
  }

  
  
}