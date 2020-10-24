import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:rPiInterface/common_pages/config_page.dart';
import 'package:rPiInterface/patient_pages/devices_setup.dart';
import 'package:rPiInterface/common_pages/rpi_setup.dart';
import 'package:rPiInterface/common_pages/webview_page.dart';
import 'package:rPiInterface/utils/models.dart';
import 'package:rPiInterface/utils/mqtt_wrapper.dart';


class HomeHPage extends StatefulWidget {
  ValueNotifier<String> patientNotifier;
  HomeHPage({this.patientNotifier});

  @override
  _HomeHPageState createState() => _HomeHPageState();
}

class _HomeHPageState extends State<HomeHPage> {

  ValueNotifier<MqttCurrentConnectionState> connectionNotifier =
      ValueNotifier(MqttCurrentConnectionState.DISCONNECTED);

  ValueNotifier<String> macAddress1Notifier = ValueNotifier('Endereço MAC');
  ValueNotifier<String> macAddress2Notifier = ValueNotifier('Endereço MAC');

  ValueNotifier<List<String>> driveListNotifier = ValueNotifier(['Armazenamento interno']);

  ValueNotifier<String> acquisitionNotifier = ValueNotifier('off');
  ValueNotifier<String> acquisitionNotifierAux = ValueNotifier('off');

  ValueNotifier<bool> receivedMACNotifier = ValueNotifier(false);

  final firestoreInstance = Firestore.instance;

  String message;

  //String acquisitionState = 'NO';

  MqttCurrentConnectionState connectionState;
  MQTTClientWrapper mqttClientWrapper;
  MqttClient client;

  final TextEditingController _nameController = TextEditingController();

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
    acquisitionNotifier.value = 'off';
    setupHome();
    _nameController.text = " ";
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    _nameController.dispose();
    super.dispose();
  }

  void gotNewMessage(String newMessage) {
    setState(() => message = newMessage);
    print('This is the new message: $message');
    _isMACAddress(message);
    _isDrivesList(message);
    _isAcquisitionStarting(message);
  }

  void updatedConnection(MqttCurrentConnectionState newConnectionState) {
    setState(() => connectionState = newConnectionState);
    connectionNotifier.value = newConnectionState;
    if (newConnectionState == MqttCurrentConnectionState.DISCONNECTED) {
      receivedMACNotifier.value = false;
    }
    print('This is the new connection state $connectionState');
  }

  void _isMACAddress(String message) {
    if (message.contains('DEFAULT')) {
      try {
        final List<String> listMAC = message.split(",");
        setState(() {
          macAddress1Notifier.value = listMAC[1].split("'")[1];
          macAddress2Notifier.value = listMAC[2].split("'")[1];
          receivedMACNotifier.value = true;
          /* macAddress1Notifier.value = listMAC[1];
          macAddress2Notifier.value = listMAC[2]; */
        });
      } catch (e) {
        print(e);
      }
    }
  }

  void _isDrivesList(String message) {
    if (message.contains('DRIVES')) {
      try {
        List<String> listDrives = message.split(",");
        listDrives.removeAt(0);
        listDrives = listDrives.map((drive) => drive.split("'")[1]).toList();
        setState(() => driveListNotifier.value = listDrives); // CONFIRMAR ISTO!!!
      } catch (e) {
        print(e);
      }
    }
  }

  void _isAcquisitionStarting(String message) {
    if (message.contains('STARTING')) {
      setState(() => acquisitionNotifier.value = 'acquiring');
      print('ACQUISITION STARTING');
    } else if (message.contains('RECONNECTING')) {
      setState(() => acquisitionNotifier.value = 'reconnecting');
      print('RECONNECTING ACQUISITION');
    } else if (message.contains('STOPPED')) {
      setState(() => acquisitionNotifier.value = 'stopped');
      print('ACQUISITION STOPPED AND SAVED');
    } else if (message.contains('OFF')) {
      setState(() => acquisitionNotifier.value = 'off');
      print('ACQUISITION OFF');
    }
  }

  Future<DocumentSnapshot> getUserName(uid) {
    return firestoreInstance.collection("users").document(uid).get();
  }


  Future<DocumentSnapshot> _getAvatar(uid) async {
    return firestoreInstance.collection("users").document(uid).get();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    FutureBuilder(
                        future: _getAvatar(widget.patientNotifier.value),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return CircleAvatar(
                                radius: 40.0,
                                backgroundImage:
                                    AssetImage(snapshot.data["avatar"]));
                          } else {
                            return CircularProgressIndicator();
                          }
                        }),
                    Text('ID:',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          decoration: TextDecoration.underline,
                        )),
                    Text(widget.patientNotifier.value,
                        style: TextStyle(color: Colors.white, fontSize: 14)),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Nome: ',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          FutureBuilder(
                            future: getUserName(widget.patientNotifier.value),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                return Text(
                                  '${snapshot.data["userName"]}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                );
                              } else {
                                return CircularProgressIndicator();
                              }
                            },
                          ),
                        ]),
                  ),
                ),
              ),
            ]),
      ),
      appBar: new AppBar(title: new Text('PreEpiSeizures'), actions: <Widget>[
        FlatButton.icon(
          label: Text(
            'Sign out',
            style: TextStyle(color: Colors.white),
          ),
          icon: Icon(
            Icons.person,
            color: Colors.white,
          ),
          onPressed: () {
            setState(() {
              widget.patientNotifier.value = null;
              Navigator.pop(context);
            });
          },
        )
      ]),
      body: ListView(children: <Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(10, 20, 10, 10),
          child: Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue[300],
                child: Text(
                  '1',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              title: Text('Conectividade'),
              onTap: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return RPiPage(
                          mqttClientWrapper: mqttClientWrapper,
                          connectionState: connectionState,
                          connectionNotifier: connectionNotifier,
                          receivedMACNotifier: receivedMACNotifier,
                          acquisitionNotifier: acquisitionNotifier,
                        );
                  }),
                );
              },
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue[300],
                child: Text(
                  '2',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              title: Text('Configurações'),
              //enabled: connectionState == MqttCurrentConnectionState.CONNECTED,
              onTap: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return ConfigPage(
                      mqttClientWrapper: mqttClientWrapper,
                      connectionNotifier: connectionNotifier,
                      driveListNotifier: driveListNotifier,
                    );
                  }),
                );
              },
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue[300],
                child: Text(
                  '3',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              title: Text('Selecionar dispositivos'),
              //enabled: connectionState == MqttCurrentConnectionState.CONNECTED,
              onTap: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return DevicesPage(
                          mqttClientWrapper: mqttClientWrapper,
                          macAddress1Notifier: macAddress1Notifier,
                          macAddress2Notifier: macAddress2Notifier,
                          connectionNotifier: connectionNotifier,
                          acquisitionNotifier: acquisitionNotifier,
                        );
                  }),
                );
              },
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue[300],
                child: Text(
                  '4',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              title: Text('Iniciar visualização'),
              //enabled: acquisitionNotifier.value == 'acquiring',
              onTap: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return WebviewPage(
                          mqttClientWrapper: mqttClientWrapper,
                          acquisitionNotifier: acquisitionNotifier,
                        );
                  }),
                );
              },
            ),
          ),
        ),
      ]),
    );
  }
}
