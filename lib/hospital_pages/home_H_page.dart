import 'dart:async';
import 'dart:convert';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:rPiInterface/common_pages/profile_drawer.dart';
import 'package:rPiInterface/common_pages/real_time_MAC1.dart';
import 'package:rPiInterface/hospital_pages/config_page.dart';
import 'package:rPiInterface/common_pages/rpi_setup.dart';
import 'package:rPiInterface/hospital_pages/devices_H_setup.dart';
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

  ValueNotifier<List<String>> driveListNotifier = ValueNotifier(['RPi']);

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
  ValueNotifier<bool> startupError = ValueNotifier(false);

  ValueNotifier<String> chosenDrive = ValueNotifier(null);
  ValueNotifier<List<bool>> bit1Selections = ValueNotifier(null);
  ValueNotifier<List<bool>> bit2Selections = ValueNotifier(null);
  ValueNotifier<List<TextEditingController>> controllerSensors =
      ValueNotifier(List.generate(12, (i) => TextEditingController()));
  ValueNotifier<TextEditingController> controllerFreq =
      ValueNotifier(TextEditingController());

  String message;
  Timer timer;
  ValueNotifier<bool> dialogNotifier = ValueNotifier(false);

  ValueNotifier<List<String>> historyMAC = ValueNotifier([]);

  ValueNotifier<List<List>> dataMAC1Notifier = ValueNotifier([]);
  ValueNotifier<List<List>> dataMAC2Notifier = ValueNotifier([]);
  ValueNotifier<List<List>> channelsMAC1Notifier = ValueNotifier([]);
  ValueNotifier<List<List>> channelsMAC2Notifier = ValueNotifier([]);
  ValueNotifier<List> sensorsMAC1Notifier = ValueNotifier([]);
  ValueNotifier<List> sensorsMAC2Notifier = ValueNotifier([]);

  MqttCurrentConnectionState connectionState;
  MQTTClientWrapper mqttClientWrapper;
  MqttClient client;

  final TextEditingController nameController = TextEditingController();

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

    timer = Timer.periodic(Duration(seconds: 15), (Timer t) => print('timer'));

    var initializationSettingsAndroid =
        AndroidInitializationSettings('seizure_icon');
    var initializationSettingsIOs = IOSInitializationSettings();
    var initSetttings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOs);
    batteryNotification.initialize(initSetttings);

    acquisitionNotifier.value = 'off';
    setupHome();
    nameController.text = " ";
    _wifiDialog();
    getAnnotationTypes();
    getLastMAC();
    print(
        'LAST MAC: ${macAddress1Notifier.value}, ${macAddress2Notifier.value}');
    getLastBatteries();
    print(
        'LAST BATTERIES: ${batteryBit1Notifier.value}, ${batteryBit2Notifier.value}');
    getMACHistory();
    print('MAC HISTORY: ${historyMAC.value}');
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
      annot = prefs.getStringList('annotationTypes').toList() ?? [];
      setState(() => annotationTypesD.value = annot);
    } catch (e) {
      print(e);
    }
  }

  void getLastMAC() async {
    await Future.delayed(Duration.zero);
    await SharedPreferences.getInstance().then((value) {
      List<String> lastMAC = (value.getStringList('lastMAC').toList() ??
          ['Endereço MAC', 'Endereço MAC']);
      setState(() => macAddress1Notifier.value = lastMAC[0]);
      setState(() => macAddress2Notifier.value = lastMAC[1]);
    });
    print(
        'LAST MAC: ${macAddress1Notifier.value}, ${macAddress2Notifier.value}');
  }

  Future<void> saveMAC(mac1, mac2) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      setState(() => prefs.setStringList('lastMAC', [mac1, mac2]));
    } catch (e) {
      print(e);
    }
  }

  void getLastBatteries() async {
    await Future.delayed(Duration.zero);
    await SharedPreferences.getInstance().then((value) {
      List<String> lastBatteries =
          (value.getStringList('lastBatteries').toList() ?? [null, null]);
      if (lastBatteries[0] != null) {
        print(lastBatteries[0]);
        print(num.tryParse(lastBatteries[0])?.toDouble());
        setState(() => batteryBit1Notifier.value =
            num.tryParse(lastBatteries[0])?.toDouble());
      }
      if (lastBatteries[1] != null) {
        setState(() => batteryBit2Notifier.value =
            num.tryParse(lastBatteries[1])?.toDouble());
      }
    });
    print(
        'LAST BATTERY: ${batteryBit1Notifier.value}, ${batteryBit2Notifier.value}');
  }

  Future<void> saveBatteries(battery1, battery2) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      setState(() => prefs.setStringList('lastBatteries', [
            battery1,
            battery2,
          ]));
    } catch (e) {
      print(e);
    }
  }

  void getMACHistory() async {
    await Future.delayed(Duration.zero);
    List<String> history;
    await SharedPreferences.getInstance().then((value) {
      try {
        setState(() =>
            history = (value.getStringList('historyMAC').toList() ?? [' ']));
      } catch (e) {
        setState(() => history = [' ']);
      }
      setState(() => historyMAC.value = history);
    });
    print('MAC HISTORY: ${historyMAC.value}');
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
    timer?.cancel();
    super.dispose();
    nameController.dispose();
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
    _isStartupError(message);
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
    } else if (message.contains('PAIRING')) {
      setState(() => acquisitionNotifier.value = 'pairing');
      print('PAIRING');
    } else if (message.contains('STOPPED')) {
      setState(() => acquisitionNotifier.value = 'stopped');
      _restart();
      print('ACQUISITION STOPPED AND SAVED');
    } else if (message.contains('PAUSED')) {
      setState(() => acquisitionNotifier.value = 'paused');
      print('ACQUISITION PAUSED');
    }
  }

  void _isData(String message) {
    if (message.contains('DATA')) {
      setState(() => acquisitionNotifier.value =
          'acquiring'); // if user leaves the app, this will enable the visualization nontheless
      List message2List = json.decode(message);

      if (macAddress1Notifier.value == 'Endereço MAC') {
        getLastMAC();
      }

      List<List> dataMAC1 = [];
      List<List> channelsMAC1 = [];
      List sensorsMAC1 = [];
      List<List> dataMAC2 = [];
      List<List> channelsMAC2 = [];
      List sensorsMAC2 = [];

      message2List[2].asMap().forEach((index, channel) {
        if (channel[0] == macAddress1Notifier.value) {
          dataMAC1.add(message2List[1][index]);
          channelsMAC1.add(channel);
          sensorsMAC1.add(message2List[3][index]);
        } else {
          dataMAC2.add(message2List[1][index]);
          channelsMAC2.add(channel);
          sensorsMAC2.add(message2List[3][index]);
        }
      });

      setState(() => dataMAC1Notifier.value = dataMAC1);
      setState(() => channelsMAC1Notifier.value = channelsMAC1);
      setState(() => sensorsMAC1Notifier.value = sensorsMAC1);
      setState(() => dataMAC2Notifier.value = dataMAC2);
      setState(() => channelsMAC2Notifier.value = channelsMAC2);
      setState(() => sensorsMAC2Notifier.value = sensorsMAC2);
    }
  }

  void _isBatteryLevel(String message) {
    if (message.contains('BATTERY')) {
      List message2List = json.decode(message);
      double _levelRatio;
      print('BATTERY: ${message2List[1]}');

      for (var entry in message2List[1].entries) {
        // list of dict [{'MAC1': ABAT in volts}, {'MAC2': ABAT in volts}]

        _levelRatio = (entry.value - 3.4) / (4.2 - 3.4);
        double _level = (_levelRatio > 1)
            ? 1
            : (_levelRatio < 0)
                ? 0
                : _levelRatio;

        if (entry.key == macAddress1Notifier.value) {
          setState(() => batteryBit1Notifier.value = _level);
          if (entry.value <= 3.4) {
            showNotification('1');
          }
        } else if (entry.key == macAddress2Notifier.value) {
          setState(() => batteryBit2Notifier.value = _level);
          if (entry.value <= 3.4) {
            showNotification('2');
          }
        }
      }
      saveBatteries(batteryBit1Notifier.value.toString(),
          batteryBit2Notifier.value.toString());
    }
  }

  void _isTimeout(String message) {
    if (message.contains('TIMEOUT')) {
      List message2List = json.decode(message);
      setState(() => timedOut.value = message2List[1]);
    }
  }

  void _isStartupError(String message) {
    if (message.contains('ERROR')) {
      setState(() => startupError.value = true);
      _restart();
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

      driveListNotifier.value = ['RPi'];

      batteryBit1Notifier.value = null;
      batteryBit2Notifier.value = null;

      isBit1Enabled.value = false;
      isBit1Enabled.value = false;
    });

    saveBatteries(null, null);
    saveMAC('Endereço MAC', 'Endereço MAC');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: ProfileDrawer(
        patientNotifier: widget.patientNotifier,
        nameController: nameController,
        annotationTypesD: annotationTypesD,
        historyMAC: historyMAC,
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
                            state == 'trying' ||
                            state == 'pairing' ||
                            state == 'paused')
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
                                  : state == 'pairing'
                                      ? 'A emparelhar dispositivos ...'
                                      : state == 'paused'
                                          ? 'Aquisição em pausa ...'
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
                      dataMAC1Notifier: dataMAC1Notifier,
                      dataMAC2Notifier: dataMAC2Notifier,
                      channelsMAC1Notifier: channelsMAC1Notifier,
                      channelsMAC2Notifier: channelsMAC2Notifier,
                      sensorsMAC1Notifier: sensorsMAC1Notifier,
                      sensorsMAC2Notifier: sensorsMAC2Notifier,
                      patientNotifier: widget.patientNotifier,
                      annotationTypesD: annotationTypesD,
                      timedOut: timedOut,
                      startupError: startupError,
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
                      isBit1Enabled: isBit1Enabled,
                      isBit2Enabled: isBit2Enabled,
                      receivedMACNotifier: receivedMACNotifier,
                      sentMACNotifier: sentMACNotifier,
                      driveListNotifier: driveListNotifier,
                      sentConfigNotifier: sentConfigNotifier,
                      configDefault: configDefaultNotifier,
                      chosenDrive: chosenDrive,
                      bit1Selections: bit1Selections,
                      bit2Selections: bit2Selections,
                      controllerSensors: controllerSensors,
                      controllerFreq: controllerFreq,
                      historyMAC: historyMAC,
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
                      configDefault: configDefaultNotifier,
                      chosenDrive: chosenDrive,
                      bit1Selections: bit1Selections,
                      bit2Selections: bit2Selections,
                      controllerSensors: controllerSensors,
                      controllerFreq: controllerFreq,
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
                    return RealtimePageMAC1(
                      dataMAC1Notifier: dataMAC1Notifier,
                      dataMAC2Notifier: dataMAC2Notifier,
                      channelsMAC1Notifier: channelsMAC1Notifier,
                      channelsMAC2Notifier: channelsMAC2Notifier,
                      sensorsMAC1Notifier: sensorsMAC1Notifier,
                      sensorsMAC2Notifier: sensorsMAC2Notifier,
                      mqttClientWrapper: mqttClientWrapper,
                      acquisitionNotifier: acquisitionNotifier,
                      batteryBit1Notifier: batteryBit1Notifier,
                      batteryBit2Notifier: batteryBit2Notifier,
                      patientNotifier: widget.patientNotifier,
                      annotationTypesD: annotationTypesD,
                      connectionNotifier: connectionNotifier,
                      timedOut: timedOut,
                      startupError: startupError,
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
                        return RealtimePageMAC1(
                          dataMAC1Notifier: dataMAC1Notifier,
                          dataMAC2Notifier: dataMAC2Notifier,
                          channelsMAC1Notifier: channelsMAC1Notifier,
                          channelsMAC2Notifier: channelsMAC2Notifier,
                          sensorsMAC1Notifier: sensorsMAC1Notifier,
                          sensorsMAC2Notifier: sensorsMAC2Notifier,
                          mqttClientWrapper: mqttClientWrapper,
                          acquisitionNotifier: acquisitionNotifier,
                          batteryBit1Notifier: batteryBit1Notifier,
                          batteryBit2Notifier: batteryBit2Notifier,
                          patientNotifier: widget.patientNotifier,
                          annotationTypesD: annotationTypesD,
                          connectionNotifier: connectionNotifier,
                          timedOut: timedOut,
                          startupError: startupError,
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
