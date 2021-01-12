import 'dart:async';
import 'dart:convert';
import 'package:app_settings/app_settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:rPiInterface/common_pages/real_time.dart';
import 'package:rPiInterface/hospital_pages/config_page.dart';
import 'package:rPiInterface/common_pages/rpi_setup.dart';
import 'package:rPiInterface/hospital_pages/devices_H_setup.dart';
import 'package:rPiInterface/hospital_pages/configurations.dart';
import 'package:rPiInterface/hospital_pages/instructions_H.dart';
import 'package:rPiInterface/utils/battery_indicator.dart';
import 'package:rPiInterface/utils/models.dart';
import 'package:rPiInterface/utils/mqtt_wrapper.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  ValueNotifier<String> hostnameNotifier = ValueNotifier('192.168.0.10');

  ValueNotifier<String> acquisitionNotifier = ValueNotifier('off');

  ValueNotifier<bool> receivedMACNotifier = ValueNotifier(false);
  ValueNotifier<bool> sentMACNotifier = ValueNotifier(false);
  ValueNotifier<bool> sentConfigNotifier = ValueNotifier(false);

  ValueNotifier<List> configDefaultNotifier = ValueNotifier([]);

  ValueNotifier<bool> isBit1Enabled = ValueNotifier(false);
  ValueNotifier<bool> isBit2Enabled = ValueNotifier(false);

  ValueNotifier<double> batteryBit1Notifier = ValueNotifier(null);
  ValueNotifier<double> batteryBit2Notifier = ValueNotifier(null);

  ValueNotifier<String> timedOut = ValueNotifier(null);

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

  ValueNotifier<List> annotationTypesD = ValueNotifier([]);

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
    var initSetttings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOs);
    batteryNotification.initialize(initSetttings);

    acquisitionNotifier.value = 'off';
    setupHome();
    _nameController.text = " ";

    /* subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (initiatedWifi && this.mounted)
        _showSnackBar('Conexão à rede alterada.');
    }); */
    _wifiDialog();
    getAnnotationTypes();
  }


  Future<void> _wifiDialog() async {
    await Future.delayed(Duration.zero);
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Conexão wifi',
            textAlign: TextAlign.start,
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(right: 15.0, left: 15.0),
                  child: Text(
                    'Verifique se se encontra conectado à rede "PreEpiSeizures". Caso contrário, por favor conectar com a password "preepiseizures"',
                    textAlign: TextAlign.justify,
                  ),
                ),
                ButtonBar(
                    alignment: MainAxisAlignment.center,
                    children: <Widget>[
                      RaisedButton(
                        child: Text("Está conectado!"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      RaisedButton(
                        child: Text("WIFI"),
                        onPressed: () {
                          AppSettings.openWIFISettings();
                          Navigator.of(context).pop();
                        },
                      ),
                    ]),
              ],
            ),
          ),
        );
      },
    );
  }


  void getAnnotationTypes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List annot;
    try {
      //print(prefs.getStringList('annotationTypes'));
      annot = prefs.getStringList('annotationTypes').toList();
      setState(() => annotationTypesD.value = annot);
      //print('ANNOT: ${annotationTypesD.value}');
    } catch (e) {
      print(e);
    }
  }


  showNotification(device) async {
    print('BATERIA BAIXA: DEVICE $device');
    var android = AndroidNotificationDetails('id', 'channel ', 'description',
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
    //subscription.cancel();
  }

  void gotNewMessage(String newMessage) {
    setState(() => message = newMessage);
    _isMACAddress(message);
    _isDrivesList(message);
    _isDefaultConfig(message);
    _macReceived(message);
    _configReceived(message);
    _isAcquisitionState(message);
    _isData(message);
    _isBatteryLevel(message);
    _isTimeout(message);
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
    if (message.contains('DEFAULT MAC')) {
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
        setState(() => driveListNotifier.value = listDrives);
        mqttClientWrapper.publishMessage("['GO TO DEVICES']");
      } catch (e) {
        print(e);
      }
    }
  }

  void _isDefaultConfig(String message) {
    if (message.contains('DEFAULT CONFIG')) {
      List message2List = json.decode(message);
      //print(message2List[1]);
      setState(() => configDefaultNotifier.value = message2List[1]);
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
      _restart();
      print('ACQUISITION STOPPED AND SAVED');
    }
  }

  void _isData(String message) {
    if (message.contains('DATA')) {
      if (timedOut.value != null) {setState(() => timedOut.value = null);}
      setState(() => acquisitionNotifier.value =
          'acquiring'); // if user leaves the app, this will enable the visualization nontheless
      List message2List = json.decode(message);
      setState(() => dataNotifier.value = message2List[1]);
      setState(() => dataChannelsNotifier.value = message2List[2]);
      setState(() => dataSensorsNotifier.value = message2List[3]);
    }
  }

  void _isBatteryLevel(String message) {
    if (message.contains('BATTERY')) {
      List message2List = json.decode(message);
      print('BATTERY: ${message2List[1]}');
      for (var entry in message2List[1].entries) {
        double _levelRatio = (entry.value - 520.66) /
            (647.4 -
                520.66); //max values calculated assuming 589 is 95% and 527 is 5%
        double _level = (_levelRatio > 1)
            ? 1
            : (_levelRatio < 0)
                ? 0
                : _levelRatio;
        if (entry.key == macAddress1Notifier.value) {
          setState(() => batteryBit1Notifier.value = _level);

          if (_level <= 0.1) {
            showNotification('1');
          }
        } else if (entry.key == macAddress2Notifier.value) {
          setState(() => batteryBit2Notifier.value = _level);
          if (_level <= 0.1) {
            showNotification('2');
          }
        }
      }
    }
  }

  void _isTimeout(String message) {
    if (message.contains('TIMEOUT')) {
      List message2List = json.decode(message);
      setState(() => timedOut.value = message2List[1]);
    }
  }


  Future<void> _restart() async {
    mqttClientWrapper.publishMessage("['RESTART']");
    await mqttClientWrapper.diconnectClient();
    setState(() {
      defaultMacAddress1Notifier.value = 'Endereço MAC';
      defaultMacAddress2Notifier.value = 'Endereço MAC';

      macAddress1Notifier.value = 'Endereço MAC';
      macAddress2Notifier.value = 'Endereço MAC';

      receivedMACNotifier.value = false;
      sentMACNotifier.value = false;
      sentConfigNotifier.value = false;

      acquisitionNotifier.value = 'off';

      driveListNotifier.value = ['Armazenamento interno'];

      batteryBit1Notifier.value = null;
      batteryBit2Notifier.value = null;

      isBit1Enabled.value = false;
      isBit1Enabled.value = false;
    });
  }

  void _showSnackBar(String _message) {
    try {
      _scaffoldKey.currentState.showSnackBar(new SnackBar(
        duration: Duration(seconds: 3),
        content: new Text(_message),
        backgroundColor: Colors.blue,
      ));
    } catch (e) {
      print(e);
    }
  }

  void _submitNewName(String uid, username) async {
    try{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> user = (prefs.getStringList(uid) ?? []);
      setState(() => prefs.setStringList(uid, [username, user[1]]));
    } catch (e) {
      print(e);
    }
  }


  Future<String> getUserName(uid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try{
      List<String> user = (prefs.getStringList(uid) ?? []);
      //print('UserName: ${user[0]}');
      return user[0];
    } catch (e) {
      print(e);
      setState(() => prefs.setStringList(uid, ['Não definido', 'images/owl.jpg']));
      return 'Não definido'; 
    }
  }

  Future<String> _getAvatar(uid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try{
      List<String> user = (prefs.getStringList(uid) ?? []);
      //print('avatar: ${user[1]}');
      return user[1];
    } catch (e) {
      print(e);
      setState(() => prefs.setStringList(uid, ['Não definido', 'images/owl.jpg']));
      return 'images/owl.jpg'; 
    }
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
                                    AssetImage(snapshot.data));
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
                                  '${snapshot.data}',
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
                padding: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 0.0),
                child: Container(
                  height: 130.0,
                  width: 200.0,
                  color: Colors.transparent,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey[200],
                            offset: new Offset(5.0, 5.0))
                      ],
                    ),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
                            child: TextField(
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: "Novo nome",
                                  isDense: true),
                              controller: _nameController,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                            child: RaisedButton(
                              onPressed: () {
                                _submitNewName(widget.patientNotifier.value, _nameController.text.trim());
                                setState(() => _nameController.text = " ");
                                Navigator.pop(context);
                              },
                              child: new Text("Submeter"),
                            ),
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
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    width - 0.9 * width, 0.0, width - 0.9 * width, 0.0),
                child: RaisedButton.icon(
                  label: Text(
                    'Configurações',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  icon: Icon(
                    Icons.settings,
                    color: Colors.grey[600],
                  ),
                  onPressed: () {
                    print(annotationTypesD.value);
                    Navigator.of(context).push(new MaterialPageRoute<Null>(
                        builder: (BuildContext context) {
                          return ConfigurationsDialog(
                            annotationTypesD: annotationTypesD,
                          );
                        },
                        fullscreenDialog: true));
                  },
                ),
              )
            ]),
      ),
      appBar: new AppBar(title: new Text('EpiBox'), actions: <Widget>[
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
            valueListenable: connectionNotifier,
            builder: (BuildContext context, MqttCurrentConnectionState state,
                Widget child) {
              return Container(
                height: 20,
                color: state == MqttCurrentConnectionState.CONNECTED
                    ? Colors.green[50]
                    : state == MqttCurrentConnectionState.CONNECTING
                        ? Colors.yellow[50]
                        : Colors.red[50],
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    child: Text(
                      state == MqttCurrentConnectionState.CONNECTED
                          ? 'Conectado ao servidor'
                          : state == MqttCurrentConnectionState.CONNECTING
                              ? 'A conectar...'
                              : 'Disconectado do servidor',
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
                    : (state == 'starting' ||
                            state == 'reconnecting' ||
                            state == 'trying')
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
                      configDefault: configDefaultNotifier,
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
              enabled: acquisitionNotifier.value == 'acquiring',
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
                      patientNotifier: widget.patientNotifier,
                      annotationTypesD: annotationTypesD,
                      connectionNotifier: connectionNotifier,
                      timedOut: timedOut,
                    );
                  }),
                );
              },
            ),
          ),
        ),
      ]),
      floatingActionButton: Stack(children: [
        Align(
          alignment: Alignment(1.0, 0.8),
          child: FloatingActionButton(
              mini: true,
              heroTag: null,
              child: Icon(Icons.list),
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return InstructionsHPage();
                  }),
                );
              }),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: FloatingActionButton.extended(
            onPressed: sentMACNotifier.value
                ? () async {
                    mqttClientWrapper.publishMessage("['START']");
                    //print(annotationTypesD);
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
                          patientNotifier: widget.patientNotifier,
                          annotationTypesD: annotationTypesD,
                          connectionNotifier: connectionNotifier,
                          timedOut: timedOut,
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
            label: Text('Iniciar'),
            icon: Icon(Icons.play_circle_outline),
          ),
        ),
      ]),
    );
  }
}
