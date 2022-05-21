import 'package:epibox/classes/acquisition.dart';
import 'package:epibox/classes/error_handler.dart';
import 'package:epibox/classes/shared_pref.dart';
import 'package:epibox/costum_overlays/error_overlays.dart';
import 'package:epibox/mqtt/mqtt_wrapper.dart';
import 'package:epibox/user-pages/speed_annotation.dart';
import 'package:flutter/material.dart';

void stopAcquisition(MQTTClientWrapper mqttClientWrapper) {
  mqttClientWrapper.publishMessage("['INTERRUPT']");
}

void resumeAcquisition(MQTTClientWrapper mqttClientWrapper) {
  mqttClientWrapper.publishMessage("['RESUME ACQ']");
}

void pauseAcquisition({
  MQTTClientWrapper mqttClientWrapper,
  BuildContext context,
  Acquisition acquisition,
  ErrorHandler errorHandler,
}) {
  if (acquisition.acquisitionState != 'acquiring') {
    errorHandler.overlayInfo = {
      'overlayMessage': NotAcquiringOverlay(),
      'timer': 2,
      'showOverlay': true
    };
  } else {
    mqttClientWrapper.publishMessage("['PAUSE ACQ']");
  }
}

Future<void> speedAnnotation({
  BuildContext context,
  Acquisition acquisition,
  ErrorHandler errorHandler,
  ValueNotifier<String> patientNotifier,
  MQTTClientWrapper mqttClientWrapper,
  Preferences preferences,
}) async {
  List<String> annotationTypes = List<String>.from(preferences.annotationTypes);
  if (acquisition.acquisitionState != 'acquiring') {
    errorHandler.overlayInfo = {
      'overlayMessage': NotAcquiringOverlay(),
      'timer': 2,
      'showOverlay': true
    };
  } else {
    Navigator.of(context).push(new MaterialPageRoute<Null>(
        builder: (BuildContext context) {
          return SpeedAnnotationDialog(
            annotationTypes: annotationTypes,
            patientNotifier: patientNotifier,
            mqttClientWrapper: mqttClientWrapper,
            preferences: preferences,
          );
        },
        fullscreenDialog: true));
  }
}
