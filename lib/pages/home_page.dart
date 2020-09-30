import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:rPiInterface/pages/devices_setup.dart';
import 'package:rPiInterface/pages/rpi_setup.dart';
import 'package:provider/provider.dart';
import 'package:rPiInterface/utils/authentication.dart';
import 'package:rPiInterface/utils/models.dart';
import '../mqtt_wrapper.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  ValueNotifier<MqttCurrentConnectionState> connectionNotifier = ValueNotifier(MqttCurrentConnectionState.DISCONNECTED);

  final Auth _auth = Auth();

  String macAddress1;
  String macAddress2;
  String message;

  MqttCurrentConnectionState connectionState;
  MQTTClientWrapper mqttClientWrapper;
  MqttClient client;

  Icon rPiTask = Icon(Icons.remove_circle_outline, color: Colors.black);
  Icon devicesTask = Icon(Icons.remove_circle_outline, color: Colors.black);

  void setupHome() {
    mqttClientWrapper = MQTTClientWrapper(
      client,
      () => {},
      (newMessage) => gotNewMessage(newMessage),
      (newConnectionState) => updatedConnection(newConnectionState),
    );
  }

  @override
  void initState() {
    super.initState();
    macAddress1 = 'Endereço MAC';
    macAddress2 = 'Endereço MAC';
    setupHome();
  }

  void gotNewMessage(String newMessage) {
    setState(() => message = newMessage);
    print('This is the new message: $message');
    isMACAddresses(message);
  }


  void updatedConnection(MqttCurrentConnectionState newConnectionState) {
    setState(() => rPiTask = Icon(Icons.check_circle_outline, color: Colors.black));
    setState(() => connectionState = newConnectionState);
    connectionNotifier.value = newConnectionState;
    print('This is the new connection state $connectionState');
  }

  void isMACAddresses(String message) {
    if (message.contains('DEFAULT')) {
      try{
        final List<String> listMAC = message.split(",");
        print(listMAC);
        setState(() {
          macAddress1 = listMAC[1].split("'")[1];
          macAddress2 = listMAC[2].split("'")[1];
        });
      } on Exception catch (e) {
        print('$e');
        setState(() {
          macAddress1 = 'Endereço MAC 1';
          macAddress2 = 'Endereço MAC 2';
        });
      } catch (e) {
        setState(() {
          macAddress1 = 'Endereço MAC 1';
          macAddress2 = 'Endereço MAC 2';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
          title: new Text('Aquisição de biossinais'),
          actions: <Widget>[
            FlatButton.icon(
              label: Text(
                'Sign out',
                style: TextStyle(color: Colors.white),
              ),
              icon: Icon(
                Icons.person,
                color: Colors.white,
              ),
              onPressed: () async {
                await _auth.signOut();
              },
            )
          ]),
      body: Container(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            FlatButton.icon(
              label: Text(
                'Conectar a RaspberyPi',
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
              icon: rPiTask,
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return StreamProvider<User>.value(
                        value: Auth().user,
                        child: RPiPage(
                          mqttClientWrapper: mqttClientWrapper,
                          connectionState: connectionState,
                          connectionNotifier: connectionNotifier,
                        ));
                  }),
                );
              },
            ),
            FlatButton.icon(
              label: Text(
                'Selecionar dispositivos',
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
              icon: devicesTask,
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return StreamProvider<User>.value(
                        value: Auth().user,
                        child: DevicesPage(
                          mqttClientWrapper: mqttClientWrapper,
                          message: message,
                          client: client,
                          macAddress1: macAddress1,
                          macAddress2: macAddress2,
                        ));
                  }),
                );
              },
            ),
          ],
        ),
        // body: WebView(
        //   initialUrl: 'https://en.wikipedia.org/wiki/Kraken',
        //   javascriptMode: JavascriptMode.unrestricted,
        // ),
      ),
    );
  }
}
