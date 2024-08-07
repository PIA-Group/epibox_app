import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'constants.dart' as Constants;
import 'package:mqtt_client/mqtt_client.dart';
import 'mqtt_states.dart';

class MQTTClientWrapper {
  // MVP of MQTT. Handles all the connection to the server
  MqttCurrentConnectionState connectionState = MqttCurrentConnectionState.IDLE;
  MqttSubscriptionState subscriptionState = MqttSubscriptionState.IDLE;

  final VoidCallback onConnectedCallback;
  final Function(String) onNewMessage;
  final Function(MqttCurrentConnectionState) onNewConnection;
  MqttServerClient client;

  MQTTClientWrapper(this.client, this.onConnectedCallback, this.onNewMessage,
      this.onNewConnection);

  Future<void> prepareMqttClient() async {
    _setupMqttClient();
    await _connectClient();
  }

  Future<void> _connectClient() async {
    try {
      print('MQTTClientWrapper::Mosquitto client connecting....');
      connectionState = MqttCurrentConnectionState.CONNECTING;
      onNewConnection(connectionState);
      await client.connect(Constants.username, Constants.password);
    } on Exception catch (e) {
      print('MQTTClientWrapper::client exception - $e');
      connectionState = MqttCurrentConnectionState.ERROR_WHEN_CONNECTING;
      onNewConnection(connectionState);
      //client.disconnect();
    }
  }

  Future<void> diconnectClient() async {
    try {
      print('MQTTClientWrapper::Mosquitto client disconnecting....');
      client.disconnect();
    } on Exception catch (e) {
      print('MQTTClientWrapper::client exception - $e');
    }
  }

  void _setupMqttClient() {
    client = MqttServerClient.withPort(Constants.hostname, '#1', 1883);
    client.logging(on: false);
    client.autoReconnect = false;
    client.onAutoReconnect = _onReconnect;
    client.onAutoReconnected = _onReconnected;
    client.resubscribeOnAutoReconnect = true;
    client.onDisconnected = _onDisconnected;
    client.onConnected = _onConnected;
    client.onSubscribed = _onSubscribed;
  }

  Future<void> _subscribeToTopic() async {
    print('MQTTClientWrapper::Subscribing to the ${Constants.topicName} topic');

    try {
      client.subscribe(Constants.topicName, MqttQos.exactlyOnce);
      client.updates.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        final MqttPublishMessage recMess = c[0].payload;
        final String newMessage =
            MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

        onNewMessage(newMessage);
      });
    } catch (e) {
      _onSubscribeFail();
    }
  }

  void publishMessage(String message) {
    if (client != null) {
      final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
      builder.addString(message);

      print(
          'MQTTClientWrapper::Publishing message $message to topic ${Constants.topicName}');
      client.publishMessage(
          Constants.topicName, MqttQos.atLeastOnce, builder.payload);
    }
  }

  void _onSubscribed(String topic) {
    print('MQTTClientWrapper::Subscription confirmed for topic $topic');
    subscriptionState = MqttSubscriptionState.SUBSCRIBED;
  }

  void _onDisconnected() {
    print(
        'MQTTClientWrapper::OnDisconnected client callback - Client disconnection');

    connectionState = MqttCurrentConnectionState.DISCONNECTED;
    onNewConnection(connectionState);
  }

  void _onReconnect() {
    print(
        'MQTTClientWrapper::OnReconnect client callback - Client autoReconnection');
    //client.disconnect();
    //connectionState = MqttCurrentConnectionState.DISCONNECTED;
    onNewConnection(connectionState);
  }

  void _onReconnected() {
    connectionState = MqttCurrentConnectionState.CONNECTED;

    print(
        'MQTTClientWrapper::OnConnected client callback - Client connection was sucessful');
    onNewConnection(connectionState);
  }

  void _onConnected() {
    connectionState = MqttCurrentConnectionState.CONNECTED;
    print(
        'MQTTClientWrapper::OnConnected client callback - Client connection was sucessful');
    _subscribeToTopic();
    onConnectedCallback();
    onNewConnection(connectionState);
  }

  void _onSubscribeFail() {
    print(
        'MQTTClientWrapper::Failed to subscribe to topic ${Constants.topicName}');
    _subscribeToTopic();
  }
}
