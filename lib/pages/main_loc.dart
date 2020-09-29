import 'package:flutter/material.dart';
import 'package:rPiInterface/mqtt_wrapper.dart';

class TestPage extends StatefulWidget {
  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {

  MQTTClientWrapper mqttClientWrapper;

  void setup() {
    mqttClientWrapper = MQTTClientWrapper(()=>{});
    mqttClientWrapper.prepareMqttClient('192.168.2.112');
  }

  @override
  void initState() {
    super.initState();
    setup();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('cenas'),
      ),
      body: Center(
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text('CONNECTING TO MQTT...')
        ],
      ),
    ),);
  }
}