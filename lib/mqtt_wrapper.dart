import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'utils/constants.dart' as Constants;
import 'package:mqtt_client/mqtt_client.dart';
import 'utils/models.dart';

class MQTTClientWrapper {

  //MqttClient client;

  MqttCurrentConnectionState connectionState = MqttCurrentConnectionState.IDLE;
  MqttSubscriptionState subscriptionState = MqttSubscriptionState.IDLE;

  final VoidCallback onConnectedCallback;
  final Function(String) onNewMessage; 
  final Function(MqttCurrentConnectionState) onNewConnection;
  MqttClient client;

  MQTTClientWrapper(this.client, this.onConnectedCallback, this.onNewMessage, this.onNewConnection);

  Future<void> prepareMqttClient(hostAddress) async {
    _setupMqttClient(hostAddress);
    await _connectClient();
    _subscribeToTopic(Constants.topicName);
  }

  Future<void> _connectClient() async {
    try {
      print('MQTTClientWrapper::Mosquitto client connecting....');
      //connectionState = MqttCurrentConnectionState.CONNECTING;
      //await client.connect();
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
    print('host: $_hostAddress');
    //client = MqttServerClient.withPort('test.mosquitto.org', '#1', Constants.port);
    client = MqttServerClient.withPort(_hostAddress, '#1', Constants.port);
    client.logging(on: false);
    client.keepAlivePeriod = 20;
    //client.secure = true;
    client.onDisconnected = _onDisconnected;
    client.onConnected = _onConnected;
    client.onSubscribed = _onSubscribed;
    print('SETUP DONE');
  }

  Future<void> _subscribeToTopic(String topicName) async {

    print('MQTTClientWrapper::Subscribing to the $topicName topic');
    client.subscribe(topicName, MqttQos.atMostOnce);
    print('SUBSCRIPTION DONE TO TOPIC $topicName');
    client.subscribe('rpi2', MqttQos.atMostOnce);
    print('SUBSCRIPTION DONE TO TOPIC rpi2');

    await publishMessage("'Send MAC Addresses'");
    print('After subscription: $connectionState');

    client.updates.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage recMess = c[0].payload;
      final String newMessage =
      MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      print("MQTTClientWrapper::GOT A NEW MESSAGE $newMessage");
      onNewMessage(newMessage);
    });

  }


  void publishMessage(String message) {
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(message);

    print('MQTTClientWrapper::Publishing message $message to topic ${Constants.topicName}');
    client.publishMessage(Constants.topicName, MqttQos.atLeastOnce, builder.payload);
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
    onNewConnection(connectionState);
  }

  void _onConnected() {
    connectionState = MqttCurrentConnectionState.CONNECTED;
    print(
        'MQTTClientWrapper::OnConnected client callback - Client connection was sucessful');
    onConnectedCallback();
    onNewConnection(connectionState);
  }

}