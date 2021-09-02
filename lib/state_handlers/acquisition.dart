import 'package:epibox/classes/acquisition.dart';
import 'package:epibox/classes/error_handler.dart';
import 'package:epibox/costum_overlays/acquisition_overlay.dart';
import 'package:flutter/material.dart';

void acquisitionHandler(
    BuildContext context, Acquisition acquisition, ErrorHandler errorHandler) {
  print('---- change in acquisition state: ${acquisition.acquisitionState}');
  if (acquisition.acquisitionState == 'starting') {
    errorHandler.overlayInfo = {
      'overlayMessage':
          AcquisitionCustomOverlay(state: acquisition.acquisitionState),
      'timer': null,
      'showOverlay': true
    };
  } else if (acquisition.acquisitionState == 'reconnecting') {
    errorHandler.overlayInfo = {
      'overlayMessage':
          AcquisitionCustomOverlay(state: acquisition.acquisitionState),
      'timer': null,
      'showOverlay': true
    };
  } else if (acquisition.acquisitionState == 'paused') {
    errorHandler.overlayInfo = {
      'overlayMessage':
          AcquisitionCustomOverlay(state: acquisition.acquisitionState),
      'timer': 2,
      'showOverlay': true
    };
  } else if (acquisition.acquisitionState == 'stopped') {
    errorHandler.overlayInfo = {
      'overlayMessage':
          AcquisitionCustomOverlay(state: acquisition.acquisitionState),
      'timer': 2,
      'showOverlay': true
    };
  } else if (acquisition.acquisitionState == 'off') {
    print('do nothing');
  } else {
    errorHandler.overlayInfo = {
      'overlayMessage': null,
      'timer': null,
      'showOverlay': false
    };
  }
}
