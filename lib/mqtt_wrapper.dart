import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'utils/constants.dart' as Constants;
import 'package:mqtt_client/mqtt_client.dart';
import 'utils/models.dart';

class MQTTClientWrapper {

  MqttClient client;

  MqttCurrentConnectionState connectionState = MqttCurrentConnectionState.IDLE;
  MqttSubscriptionState subscriptionState = MqttSubscriptionState.IDLE;

  final VoidCallback onConnectedCallback;
  //final Function(LocationData) onLocationReceivedCallback;

  MQTTClientWrapper(this.onConnectedCallback);

  Future<void> prepareMqttClient(hostAddress) async {
    _setupMqttClient(hostAddress);
    await _connectClient();
    _subscribeToTopic(Constants.topicName);
  }


  Future<void> _connectClient() async {
    try {
      print('MQTTClientWrapper::Mosquitto client connecting....');
      connectionState = MqttCurrentConnectionState.CONNECTING;
      await client.connect(Constants.username, Constants.password);
      print('CONNECTION DONE');
    } on Exception catch (e) {
      print('MQTTClientWrapper::client exception - $e');
      connectionState = MqttCurrentConnectionState.ERROR_WHEN_CONNECTING;
      client.disconnect();
    }

    if (client.connectionStatus.state == MqttConnectionState.connected) {
      connectionState = MqttCurrentConnectionState.CONNECTED;
      print('MQTTClientWrapper::Mosquitto client connected');
    } else {
      print(
          'MQTTClientWrapper::ERROR Mosquitto client connection failed - disconnecting, status is ${client.connectionStatus}');
      connectionState = MqttCurrentConnectionState.ERROR_WHEN_CONNECTING;
      client.disconnect();
    }
  }

  void _setupMqttClient(_hostAddress) {
    client = MqttServerClient.withPort(_hostAddress, '#1', Constants.port);
    client.logging(on: false);
    client.keepAlivePeriod = 20;
    client.onDisconnected = _onDisconnected;
    client.onConnected = _onConnected;
    client.onSubscribed = _onSubscribed;
    print('SETUP DONE');
  }

  void _subscribeToTopic(String topicName) {
    print('MQTTClientWrapper::Subscribing to the $topicName topic');
    client.subscribe(topicName, MqttQos.atMostOnce);
    print('SUBSCRIPTION DONE');
    publishMessage("heyy");
    client.updates.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage recMess = c[0].payload;
      final String newMessage =
      MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      print("MQTTClientWrapper::GOT A NEW MESSAGE $newMessage");
      
    });
  }


  void publishMessage(String message) {
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(message);

    print('MQTTClientWrapper::Publishing message $message to topic ${Constants.topicName}');
    client.publishMessage(Constants.topicName, MqttQos.exactlyOnce, builder.payload);
  }

  void _onSubscribed(String topic) {
    print('MQTTClientWrapper::Subscription confirmed for topic $topic');
    subscriptionState = MqttSubscriptionState.SUBSCRIBED;
  }

  void _onDisconnected() {
    print('MQTTClientWrapper::OnDisconnected client callback - Client disconnection');
    /* if (client.connectionStatus.returnCode == MqttConnectReturnCode.solicited) {
      print('MQTTClientWrapper::OnDisconnected callback is solicited, this is correct');
    } */
    connectionState = MqttCurrentConnectionState.DISCONNECTED;
  }

  void _onConnected() {
    connectionState = MqttCurrentConnectionState.CONNECTED;
    print(
        'MQTTClientWrapper::OnConnected client callback - Client connection was sucessful');
    onConnectedCallback();
  }

}