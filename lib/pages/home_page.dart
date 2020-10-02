import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:rPiInterface/pages/devices_setup.dart';
import 'package:rPiInterface/pages/profile_page.dart';
import 'package:rPiInterface/pages/rpi_setup.dart';
import 'package:provider/provider.dart';
import 'package:rPiInterface/pages/webview_page.dart';
import 'package:rPiInterface/utils/authentication.dart';
import 'package:rPiInterface/utils/models.dart';
import '../mqtt_wrapper.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ValueNotifier<MqttCurrentConnectionState> connectionNotifier =
      ValueNotifier(MqttCurrentConnectionState.DISCONNECTED);
  ValueNotifier<String> macAddress1Notifier = ValueNotifier('Endereço MAC');
  ValueNotifier<String> macAddress2Notifier = ValueNotifier('Endereço MAC');
  ValueNotifier<String> acquisitionNotifier = ValueNotifier('off');
  ValueNotifier<String> acquisitionNotifierAux = ValueNotifier('off');
  ValueNotifier<bool> receivedMACNotifier = ValueNotifier(false);

  final Auth _auth = Auth();
  final firestoreInstance = Firestore.instance;

  String macAddress1;
  String macAddress2;
  String message;

  //String acquisitionState = 'NO';

  MqttCurrentConnectionState connectionState;
  MQTTClientWrapper mqttClientWrapper;
  MqttClient client;

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
    macAddress1 = 'Endereço MAC';
    macAddress2 = 'Endereço MAC';
    setupHome();
  }

  void gotNewMessage(String newMessage) {
    setState(() => message = newMessage);
    print('This is the new message: $message');
    _isMACAddress(message);
    _isAcquisitionStarting(message);
  }

  void updatedConnection(MqttCurrentConnectionState newConnectionState) {
    setState(() => connectionState = newConnectionState);
    connectionNotifier.value = newConnectionState;
    if (newConnectionState == MqttCurrentConnectionState.DISCONNECTED) {
      receivedMACNotifier.value = false;}
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
        print('Default MAC: $macAddress1, $macAddress2');
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
    } else if (message.contains('OFF')){
      setState(() => acquisitionNotifier.value = 'off');
      print('ACQUISITION OFF');
    }
  }

  Future<String> currentUserID() async {
    var firebaseUser = await FirebaseAuth.instance.currentUser();
    return firebaseUser.uid;
  }

  Future<DocumentSnapshot> getUserName(uid) async {
    var userName = firestoreInstance.collection("users").document(uid).get();
    return userName;
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
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Text('PACIENTE:',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          decoration: TextDecoration.underline,
                        )),
                    FutureBuilder(
                        future: currentUserID(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return FutureBuilder(
                                future: getUserName(snapshot.data),
                                builder: (context, snapshot2) {
                                  if (snapshot2.connectionState ==
                                      ConnectionState.done) {
                                    return Text(
                                        '${snapshot2.data.data["userName"]}',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 16));
                                  } else {
                                    return CircularProgressIndicator();
                                  }
                                });
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
                    FutureBuilder(
                        future: _auth.getCurrentUserStr(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return Text('${snapshot.data}',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16));
                          } else {
                            return CircularProgressIndicator();
                          }
                        })
                  ],
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  child: FlatButton.icon(
                    label:
                        Text('Editar perfil', style: TextStyle(fontSize: 16)),
                    icon: Icon(
                      Icons.settings,
                      color: Colors.black,
                    ),
                    onPressed: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) {
                          return StreamProvider<User>.value(
                              value: Auth().user, child: ProfilePage());
                        }),
                      );
                    },
                  ),
                ),
              )
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
          onPressed: () async {
            await _auth.signOut();
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
              title: Text('Conectar a RaspberryPi'),
              onTap: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return StreamProvider<User>.value(
                        value: Auth().user,
                        child: RPiPage(
                          mqttClientWrapper: mqttClientWrapper,
                          connectionState: connectionState,
                          connectionNotifier: connectionNotifier,
                          receivedMACNotifier: receivedMACNotifier,
                          acquisitionNotifier: acquisitionNotifier,
                        ));
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
              title: Text('Selecionar dispositivos'),
              enabled: connectionState == MqttCurrentConnectionState.CONNECTED,
              onTap: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return StreamProvider<User>.value(
                        value: Auth().user,
                        child: DevicesPage(
                          mqttClientWrapper: mqttClientWrapper,
                          macAddress1Notifier: macAddress1Notifier,
                          macAddress2Notifier: macAddress2Notifier,
                          connectionNotifier: connectionNotifier,
                          acquisitionNotifier: acquisitionNotifier,
                        ));
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
              title: Text('Iniciar visualização'),
              //enabled: acquisitionNotifier.value == 'acquiring',
              onTap: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return StreamProvider<User>.value(
                        value: Auth().user,
                        child: WebviewPage(mqttClientWrapper: mqttClientWrapper));
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
