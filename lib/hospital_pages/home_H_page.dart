import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:rPiInterface/common_pages/real_time.dart';
import 'package:rPiInterface/hospital_pages/config_page.dart';
import 'package:rPiInterface/common_pages/rpi_setup.dart';
import 'package:rPiInterface/common_pages/webview_page.dart';
import 'package:rPiInterface/hospital_pages/devices_H_setup.dart';
import 'package:rPiInterface/utils/models.dart';
import 'package:rPiInterface/utils/mqtt_wrapper.dart';

class HomeHPage extends StatefulWidget {

  ValueNotifier<String> patientNotifier;
  HomeHPage({this.patientNotifier});

  @override
  _HomeHPageState createState() => _HomeHPageState();
}

class _HomeHPageState extends State<HomeHPage> {

  ValueNotifier<double> value1 = ValueNotifier(0);
  ValueNotifier<double> value2 = ValueNotifier(0);
  double radians = 0.0;
  Timer _timer;

  /// method to generate a Test  Wave Pattern Sets
  /// this gives us a value between +1  & -1 for sine & cosine
  _generateTrace(Timer t) {
    // generate our  values
    setState(() {
      value1.value = sin((radians * pi));
      value2.value = cos((radians * pi));
    });
    
    // adjust to recyle the radian value ( as 0 = 2Pi RADS)
    radians += 0.05;
    if (radians >= 2.0) {
      radians = 0.0;
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  ValueNotifier<MqttCurrentConnectionState> connectionNotifier =
      ValueNotifier(MqttCurrentConnectionState.DISCONNECTED);

  ValueNotifier<String> macAddress1Notifier = ValueNotifier('Endereço MAC');
  ValueNotifier<String> macAddress2Notifier = ValueNotifier('Endereço MAC');

  ValueNotifier<String> defaultMacAddress1Notifier = ValueNotifier('Endereço MAC');
  ValueNotifier<String> defaultMacAddress2Notifier = ValueNotifier('Endereço MAC');

  ValueNotifier<List<String>> driveListNotifier =
      ValueNotifier(['Armazenamento interno']);

  ValueNotifier<String> hostnameNotifier = ValueNotifier('192.168.1.8');

  ValueNotifier<String> acquisitionNotifier = ValueNotifier('off');

  ValueNotifier<bool> receivedMACNotifier = ValueNotifier(false);
  ValueNotifier<bool> sentMACNotifier = ValueNotifier(false);
  ValueNotifier<bool> sentConfigNotifier = ValueNotifier(false);

  ValueNotifier<bool> isBit1Enabled = ValueNotifier(false);
  ValueNotifier<bool> isBit2Enabled = ValueNotifier(false);

  final firestoreInstance = Firestore.instance;

  String message;

  ValueNotifier<bool> dialogNotifier = ValueNotifier(false);

  //var _wifiSubscription;

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
    _timer = Timer.periodic(Duration(milliseconds: 10), _generateTrace);
    acquisitionNotifier.value = 'off';
    setupHome();
    _nameController.text = " ";
    /* dialogNotifier.addListener(() => dialogNotifier.value == true ? _showWifiDialog() : {});
    dialogNotifier.value = true; */
    /* acquisitionNotifier.addListener(() {
      _showSnackBar(
        acquisitionNotifier.value == 'acquiring'
            ? 'A adquirir dados'
            : acquisitionNotifier.value == 'reconnecting'
                ? 'A retomar aquisição ...'
                : acquisitionNotifier.value == 'stopped'
                    ? 'Aquisição terminada e dados gravados'
                    : 'Aquisição desligada',
      );
    }); */
    /* _wifiSubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      print('Connectivity status' + result.toString());
    }); */
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    super.dispose();
    _timer.cancel();
    _nameController.dispose();
    //_wifiSubscription.cancel();
  }

  void gotNewMessage(String newMessage) {
    setState(() => message = newMessage);
    print('This is the new message: $message');
    _isMACAddress(message);
    _isDrivesList(message);
    _macReceived(message);
    _configReceived(message);
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
          defaultMacAddress1Notifier.value = listMAC[1].split("'")[1];
          defaultMacAddress2Notifier.value = listMAC[2].split("'")[1];
          receivedMACNotifier.value = true;
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
        setState(
            () => driveListNotifier.value = listDrives); // CONFIRMAR ISTO!!!
        mqttClientWrapper.publishMessage("['GO TO DEVICES']");
      } catch (e) {
        print(e);
      }
    }
  }

  void _macReceived(String message) {
    if (message.contains('RECEIVED MAC')) {
      sentMACNotifier.value = true;
    }
  }

  void _configReceived(String message) {
    if (message.contains('RECEIVED CONFIG')) {
      sentConfigNotifier.value = true;
    }
  }

  /* void _isHostname(String message) {
    if (message.contains('HOSTNAME')) {
      setState(() => hostnameNotifier.value = message.split("'")[3]);
    }
  } */

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

  void _showSnackBar(String _message) {
    try {
      _scaffoldKey.currentState.showSnackBar(new SnackBar(
        content: new Text(_message),
        backgroundColor: Colors.blue,
      ));
    } catch (e) {
      print(e);
    }
  }

  /* Future<void> _showWifiDialog() async {
    setState(() => dialogNotifier.value = false);
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('AlertDialog Title'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('This is a demo alert dialog.'),
                Text('Would you like to approve of this message?'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Close me!'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            )
          ],
        );
      },
    );
  } */

  Future<DocumentSnapshot> getUserName(uid) {
    return firestoreInstance.collection("users").document(uid).get();
  }

  Future<DocumentSnapshot> _getAvatar(uid) async {
    return firestoreInstance.collection("users").document(uid).get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
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
        ValueListenableBuilder(
            valueListenable: receivedMACNotifier,
            builder: (BuildContext context, bool state, Widget child) {
              return Container(
                height: 20,
                color: state ? Colors.green[50] : Colors.red[50],
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    child: Text(
                      state
                          // && _conn == MqttCurrentConnectionState.CONNECTED)
                          ? 'Conectado ao RPi'
                          : 'Disconectado do RPi',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        //fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              );
            }),
        ValueListenableBuilder(
            valueListenable: acquisitionNotifier,
            builder: (BuildContext context, String state, Widget child) {
              return Container(
                height: 20,
                color: state == 'acquiring'
                    ? Colors.green[50]
                    : state == 'reconnecting'
                        ? Colors.yellow[50]
                        : Colors.red[50],
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    child: Text(
                      state == 'acquiring'
                          ? 'A adquirir dados'
                          : state == 'reconnecting'
                              ? 'A retomar aquisição ...'
                              : state == 'stopped'
                                  ? 'Aquisição terminada e dados gravados'
                                  : 'Aquisição desligada',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        //fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              );
            }),
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
                      connectionNotifier: connectionNotifier,
                      defaultMacAddress1Notifier: defaultMacAddress1Notifier,
                      defaultMacAddress2Notifier: defaultMacAddress2Notifier,
                      macAddress1Notifier: macAddress1Notifier,
                      macAddress2Notifier: macAddress2Notifier,
                      receivedMACNotifier: receivedMACNotifier,
                      driveListNotifier: driveListNotifier,
                      acquisitionNotifier: acquisitionNotifier,
                      hostnameNotifier: hostnameNotifier,
                      sentMACNotifier: sentMACNotifier,
                      sentConfigNotifier: sentConfigNotifier,
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
              title: Text('Selecionar dispositivos'),
              enabled: receivedMACNotifier.value == true,
              onTap: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return DevicesPage(
                        patientNotifier: widget.patientNotifier,
                        mqttClientWrapper: mqttClientWrapper,
                        defaultMacAddress1Notifier: defaultMacAddress1Notifier,
                        defaultMacAddress2Notifier: defaultMacAddress2Notifier,
                        macAddress1Notifier: macAddress1Notifier,
                        macAddress2Notifier: macAddress2Notifier,
                        connectionNotifier: connectionNotifier,
                        acquisitionNotifier: acquisitionNotifier,
                        isBit1Enabled: isBit1Enabled,
                        isBit2Enabled: isBit2Enabled,
                        receivedMACNotifier: receivedMACNotifier,
                        sentMACNotifier: sentMACNotifier);
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
              title: Text('Configurações'),
              enabled: receivedMACNotifier.value == true,
              onTap: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return ConfigPage(
                      mqttClientWrapper: mqttClientWrapper,
                      connectionNotifier: connectionNotifier,
                      driveListNotifier: driveListNotifier,
                      isBit1Enabled: isBit1Enabled,
                      isBit2Enabled: isBit2Enabled,
                      macAddress1Notifier: macAddress1Notifier,
                      macAddress2Notifier: macAddress2Notifier,
                      sentConfigNotifier: sentConfigNotifier,
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
                    /* return WebviewPage(
                      mqttClientWrapper: mqttClientWrapper,
                      acquisitionNotifier: acquisitionNotifier,
                      hostnameNotifier: hostnameNotifier,
                    ); */
                    return RealtimePage(
                      value1: value1,
                      value2: value2,
                    );
                  }),
                );
              },
            ),
          ),
        ),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: sentMACNotifier.value
            ? () async {
                mqttClientWrapper.publishMessage("['START']");
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return WebviewPage(
                      mqttClientWrapper: mqttClientWrapper,
                      acquisitionNotifier: acquisitionNotifier,
                      hostnameNotifier: hostnameNotifier,
                    );
                  }),
                );
              }
            : () => {
                  connectionState != MqttCurrentConnectionState.CONNECTED
                      ? _showSnackBar('Erro: disconectado do RPi')
                      : _showSnackBar(
                          'Erro: dispositivo(s) ainda não selecionado(s)'),
                },
        label: Text('Start'),
        icon: Icon(Icons.play_circle_outline),
      ),
    );
  }
}
