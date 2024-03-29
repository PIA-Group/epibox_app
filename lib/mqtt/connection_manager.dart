import 'package:epibox/classes/acquisition.dart';
import 'package:epibox/classes/configurations.dart';
import 'package:epibox/classes/devices.dart';
import 'package:epibox/classes/error_handler.dart';
import 'package:epibox/mqtt/message_handler.dart';
import 'package:epibox/mqtt/mqtt_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:epibox/mqtt/mqtt_states.dart';
import 'package:mqtt_client/mqtt_client.dart';

class NewConnectionNotification extends Notification {
  final MqttCurrentConnectionState newConnection;

  const NewConnectionNotification({this.newConnection});
}

void updatedConnection(
    MqttCurrentConnectionState newConnectionState,
    ValueNotifier<MqttCurrentConnectionState> connectionNotifier,
    ValueNotifier<String> shouldRestart) {
  if (newConnectionState == MqttCurrentConnectionState.DISCONNECTED) {
    shouldRestart.value = 'light';
  }
  connectionNotifier.value = newConnectionState;
  print('This is the new connection state ${connectionNotifier.value}');
}

Future<void> setup(
  MQTTClientWrapper mqttClientWrapper,
  ValueNotifier<MqttCurrentConnectionState> connectionNotifier,
) async {
  // connects the client instance to the server and topic
  await mqttClientWrapper.prepareMqttClient().then((value) {
    if (connectionNotifier.value == MqttCurrentConnectionState.CONNECTED) {
      mqttClientWrapper.publishMessage("['Send default']");
      sendActualDatetime(mqttClientWrapper);
    }
  });
}

MQTTClientWrapper setupHome({
  MQTTClientWrapper mqttClientWrapper,
  MqttClient client,
  Devices devices,
  Acquisition acquisition,
  Configurations configurations,
  ValueNotifier<List<String>> driveListNotifier,
  ValueNotifier<String> timedOut,
  ErrorHandler errorHandler,
  ValueNotifier<bool> startupError,
  ValueNotifier<String> shouldRestart,
  ValueNotifier<MqttCurrentConnectionState> connectionNotifier,
  ValueNotifier<String> patientNotifier,
}) {
  // initiate MQTT client and message/state functions
  mqttClientWrapper = MQTTClientWrapper(
    client,
    () => {},
    (newMessage) => gotNewMessage(
      message: newMessage,
      mqttClientWrapper: mqttClientWrapper,
      devices: devices,
      acquisition: acquisition,
      configurations: configurations,
      driveListNotifier: driveListNotifier,
      timedOut: timedOut,
      startupError: startupError,
      errorHandler: errorHandler,
      shouldRestart: shouldRestart,
      patientNotifier: patientNotifier,
    ),
    (newConnectionState) => updatedConnection(
        newConnectionState, connectionNotifier, shouldRestart),
  );
  return mqttClientWrapper;
}
