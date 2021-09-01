import 'package:epibox/classes/error_handler.dart';
import 'package:epibox/costum_overlays/server_overlay.dart';
import 'package:epibox/mqtt/mqtt_states.dart';
import 'package:flutter/material.dart';

void serverConnectionHandler(
    BuildContext context,
    ValueNotifier<MqttCurrentConnectionState> connectionNotifier,
    ErrorHandler errorHandler) {
  if (connectionNotifier.value == MqttCurrentConnectionState.CONNECTING) {
    errorHandler.overlayInfo = {'overlayMessage': ServerCustomOverlay(connectionState: connectionNotifier.value), 'timer': null};
    
  } else if (connectionNotifier.value == MqttCurrentConnectionState.CONNECTED) {
    errorHandler.overlayInfo = {'overlayMessage': ServerCustomOverlay(connectionState: connectionNotifier.value), 'timer': 2};
  } else if (connectionNotifier.value ==
      MqttCurrentConnectionState.ERROR_WHEN_CONNECTING) {
    errorHandler.overlayInfo = {'overlayMessage': ServerCustomOverlay(connectionState: connectionNotifier.value), 'timer': 2};
  }
}
