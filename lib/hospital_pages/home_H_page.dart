import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:rPiInterface/common_pages/real_time.dart';
import 'package:rPiInterface/hospital_pages/config_page.dart';
import 'package:rPiInterface/common_pages/rpi_setup.dart';
import 'package:rPiInterface/hospital_pages/devices_H_setup.dart';
import 'package:rPiInterface/utils/battery_indicator.dart';
import 'package:rPiInterface/utils/models.dart';
import 'package:rPiInterface/utils/mqtt_wrapper.dart';

class HomeHPage extends StatefulWidget {
  ValueNotifier<String> patientNotifier;
  HomeHPage({this.patientNotifier});

  @override
  _HomeHPageState createState() => _HomeHPageState();
}

class _HomeHPageState extends State<HomeHPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  ValueNotifier<MqttCurrentConnectionState> connectionNotifier =
      ValueNotifier(MqttCurrentConnectionState.DISCONNECTED);

  ValueNotifier<String> macAddress1Notifier = ValueNotifier('Endereço MAC');
  ValueNotifier<String> macAddress2Notifier = ValueNotifier('Endereço MAC');

  ValueNotifier<String> defaultMacAddress1Notifier =
      ValueNotifier('Endereço MAC');
  ValueNotifier<String> defaultMacAddress2Notifier =
      ValueNotifier('Endereço MAC');

  ValueNotifier<List<String>> driveListNotifier =
      ValueNotifier(['Armazenamento interno']);

  ValueNotifier<String> hostnameNotifier = ValueNotifier('192.168.2.107');

  ValueNotifier<String> acquisitionNotifier = ValueNotifier('off');

  ValueNotifier<bool> receivedMACNotifier = ValueNotifier(false);
  ValueNotifier<bool> sentMACNotifier = ValueNotifier(false);
  ValueNotifier<bool> sentConfigNotifier = ValueNotifier(false);

  ValueNotifier<bool> isBit1Enabled = ValueNotifier(false);
  ValueNotifier<bool> isBit2Enabled = ValueNotifier(false);

  ValueNotifier<double> batteryBit1Notifier = ValueNotifier(null);
  ValueNotifier<double> batteryBit2Notifier = ValueNotifier(null);

  ValueNotifier<List<String>> sensorsNotifier = ValueNotifier([]);

  final firestoreInstance = Firestore.instance;

  String message;

  ValueNotifier<bool> dialogNotifier = ValueNotifier(false);

  // dataNotifier: list of lists, each sublist corresponds to a channel acquired
  ValueNotifier<List> dataNotifier = ValueNotifier([]);
  ValueNotifier<List> dataChannelsNotifier = ValueNotifier([]);
  ValueNotifier<List> dataSensorsNotifier = ValueNotifier([]);

  MqttCurrentConnectionState connectionState;
  MQTTClientWrapper mqttClientWrapper;
  MqttClient client;

  final TextEditingController _nameController = TextEditingController();

  FlutterLocalNotificationsPlugin batteryNotification =
    FlutterLocalNotificationsPlugin();

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
    var initializationSettingsAndroid =
      AndroidInitializationSettings('seizure_icon');
    var initializationSettingsIOs = IOSInitializationSettings();
    var initSetttings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOs);
    batteryNotification.initialize(initSetttings);

    acquisitionNotifier.value = 'off';
    setupHome();
    _nameController.text = " ";
  }



  showNotification(device) async {
    var android = AndroidNotificationDetails(
        'id', 'channel ', 'description',
        priority: Priority.high, importance: Importance.max);
    var iOS = IOSNotificationDetails();
    var platform = new NotificationDetails(android: android, iOS: iOS);
    await batteryNotification.show(
        0, 'Bateria fraca', 'Trocar bateria do dispositivo $device', platform); 
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
  }
  

  void gotNewMessage(String newMessage) {
    setState(() => message = newMessage);
    _isMACAddress(message);
    _isDrivesList(message);
    _macReceived(message);
    _configReceived(message);
    _isAcquisitionState(message);
    _isData(message);
    _isBatteryLevel(message);
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


  void _isAcquisitionState(String message) {
    if (message.contains('STARTING')) {
      setState(() => acquisitionNotifier.value = 'starting');
      print('ACQUISITION STARTING');
    } else if (message.contains('ACQUISITION ON')) {
      setState(() => acquisitionNotifier.value = 'acquiring');
      print('ACQUIRING');
      } else if (message.contains('TRYING')) {
      setState(() => acquisitionNotifier.value = 'trying');
      print('TRYING TO CONNECT TO DEVICES');
    } else if (message.contains('RECONNECTING')) {
      setState(() => acquisitionNotifier.value = 'reconnecting');
      print('RECONNECTING ACQUISITION');
    } else if (message.contains('STOPPED')) {
      setState(() => acquisitionNotifier.value = 'stopped');
      print('ACQUISITION STOPPED AND SAVED');
    }
  }

  void _isData(String message) {
    if (message.contains('DATA')) {
      setState(() => acquisitionNotifier.value = 'acquiring'); // if user leaves the app, this will enable the visualization nontheless
      List message2List = json.decode(message);
      setState(() => dataNotifier.value = message2List[1]);
      setState(() => dataChannelsNotifier.value = message2List[2]);
      setState(() => dataSensorsNotifier.value = message2List[3]);
    }
  }

  void _isBatteryLevel(String message) {
    if (message.contains('BATTERY')) {
      List message2List = json.decode(message);
      for (var entry in message2List[1].entries) {
        double _levelRatio = (entry.value - 520.66) /
            (647.4 -
                520.66); //max values alculated assuming 589 is 95% and 527 is 5%
        double _level =
            (_levelRatio > 1) ? 1 : (_levelRatio < 0) ? 0 : _levelRatio;
        if (entry.key == macAddress1Notifier.value) {
          setState(() => batteryBit1Notifier.value = _level);
          if (_level <= 0.1) {showNotification('1');}
        } else if (entry.key == macAddress2Notifier.value) {
          setState(() => batteryBit2Notifier.value = _level);
          if (_level <= 0.1) {showNotification('2');}
        }
      }
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

  Future<DocumentSnapshot> getUserName(uid) {
    return firestoreInstance.collection("users").document(uid).get();
  }

  Future<DocumentSnapshot> _getAvatar(uid) async {
    return firestoreInstance.collection("users").document(uid).get();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

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
                              color: Colors.grey[600],
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
                                    color: Colors.grey[600],
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
              Padding(
                padding: EdgeInsets.fromLTRB(
                    width - 0.9 * width, 50.0, width - 0.9 * width, 50.0),
                child: RaisedButton.icon(
                  label: Text(
                    'Sign out',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  icon: Icon(
                    Icons.person,
                    color: Colors.grey[600],
                  ),
                  onPressed: () {
                    setState(() {
                      widget.patientNotifier.value = null;
                      Navigator.pop(context);
                    });
                  },
                ),
              )
            ]),
      ),
      appBar: new AppBar(title: new Text('PreEpiSeizures'), actions: <Widget>[
        Column(children: [
          ValueListenableBuilder(
            valueListenable: batteryBit1Notifier,
            builder: (BuildContext context, double battery, Widget child) {
              return battery != null
                  ? Row(children: [
                      Text('MAC 1: ',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13)),
                      SizedBox(
                        width: 50.0,
                        height: 27.0,
                        child: new Center(
                          child: BatteryIndicator(
                            style: BatteryIndicatorStyle.skeumorphism,
                            batteryLevel: battery,

                          ),
                        ),
                      ),
                    ])
                  : SizedBox.shrink();
            },
          ),
          ValueListenableBuilder(
            valueListenable: batteryBit2Notifier,
            builder: (BuildContext context, double battery, Widget child) {
              return battery != null
                  ? Row(children: [
                      Text('MAC 2: ',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13)),
                      SizedBox(
                        width: 50.0,
                        height: 27.0,
                        child: new Center(
                          child: BatteryIndicator(
                            style: BatteryIndicatorStyle.skeumorphism,
                            batteryLevel: battery,
                          ),
                        ),
                      ),
                    ])
                  : SizedBox.shrink();
            },
          ),
        ]),
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
                    : (state == 'starting' || state == 'reconnecting' || state == 'trying')
                        ? Colors.yellow[50]
                        : Colors.red[50],
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    child: Text(
                      state == 'starting'
                      ? 'A iniciar aquisição ...'
                      : state == 'acquiring'
                          ? 'A adquirir dados'
                          : state == 'reconnecting'
                              ? 'A retomar aquisição ...'
                              : state == 'trying'
                              ? 'A reconectar aos dispositivos ...'
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
                      batteryBit1Notifier: batteryBit1Notifier,
                      batteryBit2Notifier: batteryBit2Notifier,
                      isBit1Enabled: isBit1Enabled,
                      isBit2Enabled: isBit2Enabled,
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
              //enabled: receivedMACNotifier.value == true,
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
              //enabled: receivedMACNotifier.value == true,
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
                    return RealtimePage(
                      dataNotifier: dataNotifier,
                      dataChannelsNotifier: dataChannelsNotifier,
                      dataSensorsNotifier: dataSensorsNotifier,
                      mqttClientWrapper: mqttClientWrapper,
                      acquisitionNotifier: acquisitionNotifier,
                      batteryBit1Notifier: batteryBit1Notifier,
                      batteryBit2Notifier: batteryBit2Notifier,
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
                    return RealtimePage(
                      dataNotifier: dataNotifier,
                      dataChannelsNotifier: dataChannelsNotifier,
                      dataSensorsNotifier: dataSensorsNotifier,
                      mqttClientWrapper: mqttClientWrapper,
                      acquisitionNotifier: acquisitionNotifier,
                      batteryBit1Notifier: batteryBit1Notifier,
                      batteryBit2Notifier: batteryBit2Notifier,
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


