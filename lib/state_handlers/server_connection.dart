import 'package:epibox/classes/error_handler.dart';
import 'package:epibox/costum_overlays/server_overlay.dart';
import 'package:epibox/mqtt/mqtt_states.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';

void serverConnectionHandler(
    BuildContext context,
    ValueNotifier<MqttCurrentConnectionState> connectionNotifier,
    ErrorHandler errorHandler) {
  if (connectionNotifier.value == MqttCurrentConnectionState.CONNECTING) {
    if (context.loaderOverlay.visible) context.loaderOverlay.hide();
    errorHandler.overlayMessage =
        ServerCustomOverlay(connectionState: connectionNotifier.value);
    context.loaderOverlay.show();
  } else if (connectionNotifier.value == MqttCurrentConnectionState.CONNECTED) {
    if (context.loaderOverlay.visible) context.loaderOverlay.hide();

    errorHandler.overlayMessage =
        ServerCustomOverlay(connectionState: connectionNotifier.value);
    context.loaderOverlay.show();
    Future.delayed(const Duration(seconds: 2), () {
      context.loaderOverlay.hide();
    });
  } else if (connectionNotifier.value ==
      MqttCurrentConnectionState.ERROR_WHEN_CONNECTING) {
    if (context.loaderOverlay.visible) context.loaderOverlay.hide();
    errorHandler.overlayMessage = ServerCustomOverlay(
      connectionState: connectionNotifier.value,
    );

    context.loaderOverlay.show();
    Future.delayed(const Duration(seconds: 3), () {
      context.loaderOverlay.hide();
    });
  }
}
