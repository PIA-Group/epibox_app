import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'constants.dart' as Constants;
import 'package:mqtt_client/mqtt_client.dart';
import 'models.dart';

class MQTTClientWrapper {


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
    //_subscribeToTopic(Constants.topicName);
  }
  
  Future<void> _connectClient() async {
    try {
      print('MQTTClientWrapper::Mosquitto client connecting....');
      connectionState = MqttCurrentConnectionState.CONNECTING;
      onNewConnection(connectionState);
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

  Future<void> diconnectClient() async {
    try {
      print('MQTTClientWrapper::Mosquitto client disconnecting....');
      client.disconnect();
      print('DISCONNECTION DONE');
    } on Exception catch (e) {
      print('MQTTClientWrapper::client exception - $e');
    }
  }

  void _setupMqttClient(_hostAddress) {
    print('host: $_hostAddress');
    //client = MqttServerClient.withPort('test.mosquitto.org', '#1', Constants.port);
    client = MqttServerClient.withPort(_hostAddress, '#1', 1883);
    client.logging(on: false);
    //client.keepAlivePeriod = 64800;
    //client.secure = true;
    client.autoReconnect = true;
    client.onAutoReconnected = _onReconnected;
    client.onDisconnected = _onDisconnected;
    client.onConnected = _onConnected;
    client.onSubscribed = _onSubscribed;
    print('SETUP DONE');
  }

  Future<void> _subscribeToTopic(String topicName) async {

    print('MQTTClientWrapper::Subscribing to the $topicName topic');
    client.subscribe(topicName, MqttQos.exactlyOnce);
    print('SUBSCRIPTION DONE TO TOPIC $topicName');

    /* await publishMessage("['Send MAC Addresses']");
    await publishMessage("['Send drives']"); */

    client.updates.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage recMess = c[0].payload;
      final String newMessage =
      MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      //print("MQTTClientWrapper::GOT A NEW MESSAGE $newMessage");
      onNewMessage(newMessage);
    });

  }

  Future<void> _reSubscribeToTopic(String topicName) async {

    client.resubscribe();
    print('RESUBSCRIPTION DONE TO TOPIC $topicName');

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
    
    connectionState = MqttCurrentConnectionState.DISCONNECTED;
    onNewConnection(connectionState);
  }

  void _onConnected() {
    connectionState = MqttCurrentConnectionState.CONNECTED;
    print(
        'MQTTClientWrapper::OnConnected client callback - Client connection was sucessful');
    _subscribeToTopic(Constants.topicName);
    onConnectedCallback();
    onNewConnection(connectionState);
  }

  void _onReconnected() {
    connectionState = MqttCurrentConnectionState.CONNECTED;
    print(
        'MQTTClientWrapper::OnRconnected client callback - Client connection was sucessful');
    _reSubscribeToTopic(Constants.topicName);
    onConnectedCallback();
    onNewConnection(connectionState);
  }

}