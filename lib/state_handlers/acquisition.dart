import 'package:epibox/classes/acquisition.dart';
import 'package:epibox/classes/error_handler.dart';
import 'package:epibox/costum_overlays/acquisition_overlay.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';

void acquisitionHandler(
    BuildContext context, Acquisition acquisition, ErrorHandler errorHandler) {
  print('---- change in acquisition state: ${acquisition.acquisitionState}');
  if (acquisition.acquisitionState == 'starting') {
    errorHandler.overlayMessage =
        AcquisitionCustomOverlay(state: acquisition.acquisitionState);
    context.loaderOverlay.show();
  } else if (acquisition.acquisitionState == 'reconnecting') {
    if (context.loaderOverlay.visible) context.loaderOverlay.hide();
    errorHandler.overlayMessage =
        AcquisitionCustomOverlay(state: acquisition.acquisitionState);
    context.loaderOverlay.show();
  } else if (acquisition.acquisitionState == 'paused') {
    if (context.loaderOverlay.visible) context.loaderOverlay.hide();
    errorHandler.overlayMessage =
        AcquisitionCustomOverlay(state: acquisition.acquisitionState);
    context.loaderOverlay.show();
    Future.delayed(const Duration(seconds: 3), () {
      context.loaderOverlay.hide();
    });
  } else if (acquisition.acquisitionState == 'stopped') {
    if (context.loaderOverlay.visible) context.loaderOverlay.hide();
    errorHandler.overlayMessage =
        AcquisitionCustomOverlay(state: acquisition.acquisitionState);
    context.loaderOverlay.show();
    Future.delayed(const Duration(seconds: 3), () {
      context.loaderOverlay.hide();
    });
  } else if (acquisition.acquisitionState == 'off') {
    print('do nothing');
  } else {
    if (context.loaderOverlay.visible) context.loaderOverlay.hide();
  }
}
