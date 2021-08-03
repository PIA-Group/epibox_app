import 'package:epibox/acquisition_navbar/destinations.dart';
import 'package:epibox/classes/configurations.dart';
import 'package:epibox/classes/mac_devices.dart';
import 'package:epibox/costum_overlays/acquisition_overlay.dart';
import 'package:epibox/costum_overlays/server_overlay.dart';
import 'package:epibox/pages/acquisition_page.dart';
import 'package:epibox/pages/config_page.dart';
import 'package:epibox/pages/profile_drawer.dart';
import 'package:epibox/pages/server_page.dart';
import 'package:epibox/pages/speed_annotation.dart';
import 'package:epibox/utils/multiple_value_listnable.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:epibox/decor/text_styles.dart';
import 'package:epibox/decor/default_colors.dart';
import 'package:epibox/utils/models.dart';
import 'package:epibox/utils/mqtt_wrapper.dart';
import 'package:property_change_notifier/property_change_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:epibox/decor/custom_icons.dart';
import 'devices_page.dart';

class NavigationPage extends StatefulWidget {
  final ValueNotifier<String> patientNotifier;
  NavigationPage({this.patientNotifier});

  @override
  _NavigationPageState createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  ValueNotifier<Widget> overlayMessage = ValueNotifier(
    Center(
      child: SpinKitFoldingCube(
        color: DefaultColors.mainColor,
        size: 70.0,
      ),
    ),
  );

  ValueNotifier<MqttCurrentConnectionState> connectionNotifier =
      ValueNotifier(MqttCurrentConnectionState.DISCONNECTED);

  MacDevices macDevices = MacDevices();

  Configurations configurations = Configurations();

  ValueNotifier<List<String>> driveListNotifier = ValueNotifier([' ']);

  ValueNotifier<String> acquisitionNotifier = ValueNotifier('off');

  ValueNotifier<bool> receivedMACNotifier = ValueNotifier(false);
  ValueNotifier<bool> sentMACNotifier = ValueNotifier(false);
  ValueNotifier<bool> sentConfigNotifier = ValueNotifier(false);

  ValueNotifier<Map<String, dynamic>> configDefaultNotifier = ValueNotifier({});


  ValueNotifier<double> batteryBit1Notifier = ValueNotifier(null);
  ValueNotifier<double> batteryBit2Notifier = ValueNotifier(null);

  ValueNotifier<String> timedOut = ValueNotifier(null);
  ValueNotifier<bool> startupError = ValueNotifier(false);

  ValueNotifier<String> chosenDrive = ValueNotifier(' ');
  ValueNotifier<List<bool>> bit1Selections = ValueNotifier(null);
  ValueNotifier<List<bool>> bit2Selections = ValueNotifier(null);
  ValueNotifier<List<TextEditingController>> controllerSensors =
      ValueNotifier(List.generate(12, (i) => TextEditingController()));
  ValueNotifier<TextEditingController> controllerFreq =
      ValueNotifier(TextEditingController(text: ' '));
  ValueNotifier<bool> saveRaw = ValueNotifier(true);

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

  ValueNotifier<bool> newAnnotation = ValueNotifier(false);

  MqttCurrentConnectionState connectionState;
  MQTTClientWrapper mqttClientWrapper;
  MqttClient client;

  ValueNotifier<List<Destination>> allDestinations = ValueNotifier(null);

  final TextEditingController nameController = TextEditingController();

  final ValueNotifier<String> isBitalino = ValueNotifier('');

  FlutterLocalNotificationsPlugin batteryNotification =
      FlutterLocalNotificationsPlugin();

  ValueNotifier<List> annotationTypesD = ValueNotifier([]);

  void setupHome() {
    // initiate MQTT client and message/state functions
    mqttClientWrapper = MQTTClientWrapper(
      client,
      () => {},
      (newMessage) => gotNewMessage(newMessage),
      (newConnectionState) => updatedConnection(newConnectionState),
    );
  }

  Future<bool> initialized;
  Future<bool> initialize() async {
    return Future.delayed(const Duration(milliseconds: 500), () {
      return (true);
    });
  }

  @override
  void initState() {
    super.initState();

    macDevices.addListener(() {
      print('MAC DEVICES CHANGED: ${macDevices.macAddress1}');
    });

    connectionNotifier.addListener(() {
      if (connectionNotifier.value == MqttCurrentConnectionState.CONNECTING) {
        setState(() => overlayMessage.value =
            ServerCustomOverlay(connectionState: connectionNotifier.value));
        context.loaderOverlay.show();
      } else if (connectionNotifier.value ==
          MqttCurrentConnectionState.CONNECTED) {
        if (context.loaderOverlay.visible) context.loaderOverlay.hide();
        setState(() => overlayMessage.value =
            ServerCustomOverlay(connectionState: connectionNotifier.value));
        context.loaderOverlay.show();
        Future.delayed(const Duration(seconds: 2), () {
          setState(() => context.loaderOverlay.hide());
        });
      } else if (connectionNotifier.value ==
          MqttCurrentConnectionState.ERROR_WHEN_CONNECTING) {
        if (context.loaderOverlay.visible) context.loaderOverlay.hide();

        setState(
          () => overlayMessage.value =
              ServerCustomOverlay(connectionState: connectionNotifier.value),
        );

        context.loaderOverlay.show();

        Future.delayed(const Duration(seconds: 3), () {
          setState(() => context.loaderOverlay.hide());
        });
      }
    });

    acquisitionNotifier.addListener(() {
      print('---- change in acquisition state: ${acquisitionNotifier.value}');

      if (acquisitionNotifier.value == 'starting') {
        setState(() => overlayMessage.value =
            AcquisitionCustomOverlay(state: acquisitionNotifier.value));
        context.loaderOverlay.show();
      } else if (acquisitionNotifier.value == 'reconnecting') {
        if (context.loaderOverlay.visible) context.loaderOverlay.hide();
        setState(() => overlayMessage.value =
            AcquisitionCustomOverlay(state: acquisitionNotifier.value));
        context.loaderOverlay.show();
      } else if (acquisitionNotifier.value == 'paused') {
        if (context.loaderOverlay.visible) context.loaderOverlay.hide();
        setState(() => overlayMessage.value =
            AcquisitionCustomOverlay(state: acquisitionNotifier.value));
        context.loaderOverlay.show();
        Future.delayed(const Duration(seconds: 3), () {
          setState(() => context.loaderOverlay.hide());
        });
      } else if (acquisitionNotifier.value == 'stopped') {
        if (context.loaderOverlay.visible) context.loaderOverlay.hide();
        setState(() => overlayMessage.value =
            AcquisitionCustomOverlay(state: acquisitionNotifier.value));
        context.loaderOverlay.show();
        Future.delayed(const Duration(seconds: 3), () {
          setState(() => context.loaderOverlay.hide());
        });
      } else if (acquisitionNotifier.value == 'off') {
        print('do nothing');
      } else {
        if (context.loaderOverlay.visible) context.loaderOverlay.hide();
      }
    });

    timer = Timer.periodic(Duration(seconds: 15), (Timer t) => print('timer'));

    var initializationSettingsAndroid =
        AndroidInitializationSettings('seizure_icon');
    var initializationSettingsIOs = IOSInitializationSettings();
    var initSetttings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOs);
    batteryNotification.initialize(initSetttings);

    //acquisitionNotifier.value = 'off';
    setupHome();
    nameController.text = " ";
    getAnnotationTypes();
    getPreviousDevice();
    getLastMAC();
    /* print(
        'LAST MAC: ${macAddress1Notifier.value}, ${macAddress2Notifier.value}'); */
    print('LAST MAC: ${macDevices.macAddress1}, ${macDevices.macAddress2}');
    getLastBatteries();
    print(
        'LAST BATTERIES: ${batteryBit1Notifier.value}, ${batteryBit2Notifier.value}');
    getMACHistory();

    allDestinations = ValueNotifier(<Destination>[
      Destination(Icons.looks_one_outlined, LightColors.kRed, dataMAC1Notifier,
          sensorsMAC1Notifier, channelsMAC1Notifier),
      Destination(Icons.looks_two_outlined, LightColors.kBlue, dataMAC2Notifier,
          sensorsMAC2Notifier, channelsMAC2Notifier),
    ]);

    initialized = initialize();

    print('TEST ------');
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

  void getPreviousDevice() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String device;
    try {
      device = prefs.getString('deviceType') ?? 'Bitalino';
      setState(() => isBitalino.value = device);
      print('Device: $device');
    } catch (e) {
      print(e);
    }
  }

  void getLastMAC() async {
    /* await Future.delayed(Duration.zero);
    Future.delayed(Duration.zero, () async {
      await SharedPreferences.getInstance().then((value) {
        List<String> lastMAC = (value.getStringList('lastMAC').toList() ??
            ['xx:xx:xx:xx:xx:xx', 'xx:xx:xx:xx:xx:xx']);
        print('history; ${lastMAC[0]}');
        setState(() => macDevices.macAddress1 = lastMAC[0]);
        setState(() => macDevices.macAddress2 = lastMAC[1]);
      });
      print('LAST MAC1: ${macDevices.macAddress1}, ${macDevices.macAddress2}');
    }); */
  }

  Future<void> saveMAC(mac1, mac2) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      await prefs.setStringList('lastMAC', [mac1, mac2]);
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
      await prefs.setStringList('lastBatteries', [
        battery1,
        battery2,
      ]);
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
    // runs functions based on the received message
    print('NEW MESSAGE: $message');
    setState(() => message = newMessage);
    _isMACAddress(message);
    _isMACState(message);
    _isDrivesList(message);
    _isDefaultConfig(message);
    _macReceived(message);
    _configReceived(message);
    _isAcquisitionState(message);
    _isData(message);
    _isBatteryLevel(message);
    _isTimeout(message);
    _isStartupError(message);
    _isTurnedOff(message);
  }

  void _isMACState(String message) {
    if (message.contains('MAC STATE')) {
      List messageList = json.decode(message.replaceAll('\'', '\"'));
      if (messageList[1] == macDevices.macAddress1) {
        setState(() => macDevices.macAddress1Connection = messageList[2]);
      } else if (messageList[1] == macDevices.macAddress2) {
        setState(() => macDevices.macAddress2Connection = messageList[2]);
      } else {
        print('Not valid MAC address');
      }
    }
  }

  void updatedConnection(MqttCurrentConnectionState newConnectionState) {
    connectionNotifier.value = newConnectionState;
    if (newConnectionState == MqttCurrentConnectionState.DISCONNECTED) {
      receivedMACNotifier.value = false;
    }
    print('This is the new connection state ${connectionNotifier.value}');
  }

  void _isMACAddress(String message) {
    if (message.contains('DEFAULT MAC')) {
      try {
        final List<String> listMAC = message.split(",");
        setState(() {

          macDevices.defaultMacAddress1 = listMAC[1].split("'")[1];
          macDevices.defaultMacAddress2 = listMAC[2].split("'")[1];
          macDevices.macAddress1 = listMAC[1].split("'")[1];
          macDevices.macAddress2 = listMAC[2].split("'")[1];

          receivedMACNotifier.value = true;
        });
      } catch (e) {
        print(e);
      }

      if (macDevices.defaultMacAddress1 == '' ||
          macDevices.defaultMacAddress1 == ' ') {
        setState(() => macDevices.isBit1Enabled = false);
      } else {
        setState(() => macDevices.isBit1Enabled = true);
      }
      if (macDevices.defaultMacAddress2 == '' ||
          macDevices.defaultMacAddress2 == ' ') {
        setState(() => macDevices.isBit2Enabled = false);
      } else {
        setState(() => macDevices.isBit2Enabled = true);
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
        print(driveListNotifier);
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
      //setState(() => acquisitionNotifier.value = 'acquiring');
      print('ACQUIRING');
    } else if (message.contains('RECONNECTING')) {
      setState(() => acquisitionNotifier.value = 'reconnecting');
      print('RECONNECTING ACQUISITION');
    } else if (message.contains('PAIRING')) {
      setState(() => acquisitionNotifier.value = 'pairing');
      print('PAIRING');
    } else if (message.contains('STOPPED')) {
      setState(() => acquisitionNotifier.value = 'stopped');
      _restart(false);
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

      if (macDevices.macAddress1 == 'xx:xx:xx:xx:xx:xx') {
        getLastMAC();
      }

      List<List> dataMAC1 = [];
      List<List> channelsMAC1 = [];
      List sensorsMAC1 = [];
      List<List> dataMAC2 = [];
      List<List> channelsMAC2 = [];
      List sensorsMAC2 = [];

      message2List[2].asMap().forEach((index, channel) {
        if (channel[0] == macDevices.macAddress1) {
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

        if (entry.key == macDevices.macAddress1) {
          setState(() => batteryBit1Notifier.value = _level);
          if (entry.value <= 3.4) {
            showNotification('1');
          }
        } else if (entry.key == macDevices.macAddress2) {
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
      _restart(false);
    }
  }

  void _isTurnedOff(String message) {
    if (message.contains('TURNED OFF')) {
      print(message);
      _restart(false);
      _showTurnedOffDialog();
    }
  }

  Future<void> _showTurnedOffDialog() async {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'RPi desligado corretamente!',
            textAlign: TextAlign.center,
            style: MyTextStyle(
                color: DefaultColors.textColorOnLight, fontSize: 22),
          ),
          content: SingleChildScrollView(
            child: ListBody(children: <Widget>[
              Padding(
                padding: EdgeInsets.only(right: 15.0, left: 15.0, top: 10.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: DefaultColors.mainLColor, // background
                    onPrimary: DefaultColors.textColorOnDark, // foreground
                  ),
                  child: Text(
                    "OK",
                    style: MyTextStyle(),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ]),
          ),
        );
      },
    );
  }

  Future<void> _restart(bool restart) async {
    mqttClientWrapper.publishMessage("['RESTART']");

    if (restart) {
      await mqttClientWrapper.diconnectClient();
      setState(() {
        /* defaultMacAddress1Notifier.value = 'xx:xx:xx:xx:xx:xx';
        defaultMacAddress2Notifier.value = 'xx:xx:xx:xx:xx:xx';

        macAddress1Notifier.value = 'xx:xx:xx:xx:xx:xx';
        macAddress2Notifier.value = 'xx:xx:xx:xx:xx:xx'; */

        macDevices.defaultMacAddress1 = 'xx:xx:xx:xx:xx:xx';
        macDevices.defaultMacAddress2 = 'xx:xx:xx:xx:xx:xx';

        macDevices.macAddress1 = 'xx:xx:xx:xx:xx:xx';
        macDevices.macAddress2 = 'xx:xx:xx:xx:xx:xx';

        driveListNotifier.value = [' '];
        chosenDrive.value = ' ';
        controllerFreq.value.text = ' ';

        macDevices.isBit1Enabled = false;
        macDevices.isBit2Enabled = false;
      });
    }

    setState(() {
      /* macAddress1ConnectionNotifier.value = 'disconnected';
      macAddress2ConnectionNotifier.value = 'disconnected'; */

      macDevices.macAddress1Connection = 'disconnected';
      macDevices.macAddress2Connection = 'disconnected';

      acquisitionNotifier.value = 'off';

      batteryBit1Notifier.value = null;
      batteryBit2Notifier.value = null;
    });

    saveBatteries(null, null);
    saveMAC('xx:xx:xx:xx:xx:xx', 'xx:xx:xx:xx:xx:xx');
  }

  double appBarHeight = 100;
  ValueNotifier<int> _navigationIndex = ValueNotifier(0);

  void _onNavigationTap(int index) {
    setState(() {
      _navigationIndex.value = index;
    });
  }

  List _headerIcon = [
    CircleAvatar(
      backgroundColor: Colors.white,
      radius: 15,
      child: Icon(Icons.home, color: DefaultColors.mainColor),
    ),
    CircleAvatar(
      backgroundColor: Colors.white,
      radius: 15,
      child: Icon(Icons.device_hub_rounded, color: DefaultColors.mainColor),
    ),
    CircleAvatar(
      backgroundColor: Colors.white,
      radius: 15,
      child: Icon(Icons.settings, color: DefaultColors.mainColor),
    ),
    CircleAvatar(
      backgroundColor: Colors.white,
      radius: 15,
      child: Icon(Custom.ecg, color: DefaultColors.mainColor),
    ),
  ];

  List _headerLabel = [
    Text('Início',
        style: MyTextStyle(color: DefaultColors.textColorOnDark, fontSize: 18)),
    Text('Dispositivos',
        style: MyTextStyle(color: DefaultColors.textColorOnDark, fontSize: 18)),
    Text('Configurações',
        style: MyTextStyle(color: DefaultColors.textColorOnDark, fontSize: 18)),
    Text('Aquisição',
        style: MyTextStyle(color: DefaultColors.textColorOnDark, fontSize: 18)),
  ];

  Future<void> _speedAnnotation() async {
    List<String> annotationTypes = List<String>.from(annotationTypesD.value);
    Navigator.of(context).push(new MaterialPageRoute<Null>(
        builder: (BuildContext context) {
          return SpeedAnnotationDialog(
            annotationTypesD: annotationTypesD,
            annotationTypes: annotationTypes,
            patientNotifier: widget.patientNotifier,
            newAnnotation: newAnnotation,
            mqttClientWrapper: mqttClientWrapper,
          );
        },
        fullscreenDialog: true));
  }

  void _stopAcquisition() {
    mqttClientWrapper.publishMessage("['INTERRUPT']");
  }

  void _resumeAcquisition() {
    mqttClientWrapper.publishMessage("['RESUME ACQ']");
  }

  void _pauseAcquisition() {
    mqttClientWrapper.publishMessage("['PAUSE ACQ']");
  }

  List<List<String>> _getChannels2Send() {
    List<List<String>> _channels2Send = [];
    bit1Selections.value.asMap().forEach((channel, value) {
      if (value) {
        _channels2Send.add([
          "'${macDevices.macAddress1}'",
          "'${(channel + 1).toString()}'",
          "'${controllerSensors.value[channel].text}'"
        ]);
      }
    });
    bit2Selections.value.asMap().forEach((channel, value) {
      if (value) {
        _channels2Send.add([
          "'${macDevices.macAddress2}'",
          "'${(channel + 1).toString()}'",
          "'${controllerSensors.value[channel + 5].text}'"
        ]);
      }
    });
    print('chn: $_channels2Send');
    return _channels2Send;
  }

  Future<void> _startAcquisition() async {
    if (connectionNotifier.value != MqttCurrentConnectionState.CONNECTED ||
        (macDevices.isBit1Enabled &&
            macDevices.macAddress1Connection != 'connected') ||
        (macDevices.isBit2Enabled &&
            macDevices.macAddress2Connection != 'connected')) {
      if (context.loaderOverlay.visible) context.loaderOverlay.hide();
      setState(() => overlayMessage.value = Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(
                  'Não foi possível iniciar',
                  textAlign: TextAlign.center,
                  style: MyTextStyle(
                      color: DefaultColors.textColorOnLight, fontSize: 20),
                ),
                SizedBox(height: 20),
                Text(
                  'Verifique a conexão ao servidor e aos dispositivos de aquisição!',
                  textAlign: TextAlign.center,
                  style: MyTextStyle(
                      color: DefaultColors.textColorOnLight, fontSize: 20),
                ),
                SizedBox(height: 20),
              ]),
            ),
          ));
      context.loaderOverlay.show();
      Future.delayed(const Duration(seconds: 3), () {
        setState(() => context.loaderOverlay.hide());
      });
    } else {
      String _newDrive =
          chosenDrive.value.substring(0, chosenDrive.value.indexOf('(')).trim();
      mqttClientWrapper.publishMessage("['FOLDER', '$_newDrive']");
      mqttClientWrapper.publishMessage("['FS', ${controllerFreq.value.text}]");
      mqttClientWrapper
          .publishMessage("['ID', '${widget.patientNotifier.value}']");
      mqttClientWrapper.publishMessage("['SAVE RAW', '${saveRaw.value}']");
      mqttClientWrapper
          .publishMessage("['EPI SERVICE', '${isBitalino.value}']");

      List<List<String>> _channels2Send = _getChannels2Send();
      mqttClientWrapper.publishMessage("['CHANNELS', $_channels2Send]");

      mqttClientWrapper.publishMessage("['START']");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: ProfileDrawer(
        mqttClientWrapper: mqttClientWrapper,
        patientNotifier: widget.patientNotifier,
        annotationTypesD: annotationTypesD,
        historyMAC: historyMAC,
        isBitalino: isBitalino,
      ),
      backgroundColor: Colors.transparent,
      key: _scaffoldKey,
      body: LoaderOverlay(
        overlayOpacity: 0.8,
        overlayColor: Colors.white,
        useDefaultLoading: false,
        overlayWidget: overlayMessage.value,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: appBarHeight * 2,
                color: DefaultColors.mainColor,
                child: Center(
                  child: Column(children: [
                    SizedBox(
                      height: 37,
                    ),
                    ValueListenableBuilder(
                        valueListenable: _navigationIndex,
                        builder:
                            (BuildContext context, int value, Widget child) {
                          return _headerIcon[value];
                        }),
                    ValueListenableBuilder(
                        valueListenable: _navigationIndex,
                        builder:
                            (BuildContext context, int value, Widget child) {
                          return _headerLabel[value];
                        })
                  ]),
                ),
              ),
            ),
            Positioned(
              top: appBarHeight,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                  decoration: BoxDecoration(
                      color: DefaultColors.backgroundColor,
                      borderRadius: new BorderRadius.only(
                        topLeft: const Radius.circular(30.0),
                        topRight: const Radius.circular(30.0),
                      )),
                  child:
                      /* FutureBuilder<bool>(
                        future: initialized,
                        builder: (BuildContext context,
                            AsyncSnapshot<bool> snapshot) {
                          if (!snapshot.hasData) {
                            return Container();
                          } else {
                            return */ /*  */ IndexedStack(
                          index: _navigationIndex.value,
                          children: [
                        ServerPage(
                          macDevices: macDevices,
                          mqttClientWrapper: mqttClientWrapper,
                          connectionNotifier: connectionNotifier,
                          receivedMACNotifier: receivedMACNotifier,
                          driveListNotifier: driveListNotifier,
                          acquisitionNotifier: acquisitionNotifier,
                          sentMACNotifier: sentMACNotifier,
                          sentConfigNotifier: sentConfigNotifier,
                          batteryBit1Notifier: batteryBit1Notifier,
                          batteryBit2Notifier: batteryBit2Notifier,
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
                          allDestinations: allDestinations.value,
                          saveRaw: saveRaw,
                        ),
                        DevicesPage(
                          macDevices: macDevices,
                          patientNotifier: widget.patientNotifier,
                          mqttClientWrapper: mqttClientWrapper,
                          connectionNotifier: connectionNotifier,
                          receivedMACNotifier: receivedMACNotifier,
                          sentMACNotifier: sentMACNotifier,
                          driveListNotifier: driveListNotifier,
                          sentConfigNotifier: sentConfigNotifier,
                          chosenDrive: chosenDrive,
                          bit1Selections: bit1Selections,
                          bit2Selections: bit2Selections,
                          controllerSensors: controllerSensors,
                          controllerFreq: controllerFreq,
                          historyMAC: historyMAC,
                          saveRaw: saveRaw,
                          isBitalino: isBitalino,
                        ),
                        ConfigPage(
                          macDevices: macDevices,
                          configurations: configurations,
                          mqttClientWrapper: mqttClientWrapper,
                          connectionNotifier: connectionNotifier,
                          driveListNotifier: driveListNotifier,
                          sentConfigNotifier: sentConfigNotifier,
                          configDefault: configDefaultNotifier,
                          chosenDrive: chosenDrive,
                          controllerSensors: controllerSensors,
                          controllerFreq: controllerFreq,
                          saveRaw: saveRaw,
                          isBitalino: isBitalino,
                        ),
                        AcquisitionPage(
                          macDevices: macDevices,
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
                          allDestinations: allDestinations.value,
                          saveRaw: saveRaw,
                        ),
                      ])
                  /* }
                        }), */
                  ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey[500],
        showUnselectedLabels: true,
        currentIndex: _navigationIndex.value, //New
        onTap: _onNavigationTap,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.device_hub_rounded),
            label: 'Dispositivos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Configurações',
          ),
          BottomNavigationBarItem(
            icon: Icon(Custom.ecg),
            label: 'Aquisição',
          ),
        ],
      ),
      floatingActionButton: PropertyChangeProvider(
        value: macDevices,
        child: ValueListenableBuilder(
            valueListenable: _navigationIndex,
            builder: (BuildContext context, int index, Widget child) {
              return index != 3
                  ? Stack(children: [
                      Align(
                        alignment: Alignment(-0.9, -0.65),
                        child: Builder(builder: (context) {
                          return FloatingActionButton(
                              backgroundColor: Colors.transparent,
                              elevation: 0.0,
                              //mini: true,
                              //heroTag: null,
                              child: Icon(Icons.more_vert),
                              onPressed: () {
                                Scaffold.of(context).openDrawer();
                              });
                        }),
                      ),
                      Align(
                        alignment: Alignment(0.7, -0.65),
                        child: Builder(builder: (context) {
                          return ValueListenableBuilder(
                              valueListenable: connectionNotifier,
                              builder: (BuildContext context,
                                  MqttCurrentConnectionState state,
                                  Widget child) {
                                return FloatingActionButton(
                                    backgroundColor: Colors.transparent,
                                    elevation: 0.0,
                                    child: CircleAvatar(
                                      backgroundColor: state ==
                                              MqttCurrentConnectionState
                                                  .CONNECTED
                                          ? Colors.green[800]
                                          : state ==
                                                  MqttCurrentConnectionState
                                                      .CONNECTING
                                              ? Colors.yellow[800]
                                              : Colors.red[800],
                                      radius: 20,
                                      child: Icon(Icons.wifi_tethering,
                                          color: Colors.white),
                                    ),
                                    onPressed: null);
                              });
                        }),
                      ),
                      Align(
                        alignment: Alignment(1.1, -0.65),
                        child: Builder(builder: (context) {
                          return PropertyChangeConsumer<MacDevices>(
                              properties: [
                                'macAddress1Connection',
                                'macAddress2Connection',
                                'isBit1Enabled',
                                'isBit2Enabled'
                              ],
                              builder: (context, model, properties) {
                                return FloatingActionButton(
                                    backgroundColor: Colors.transparent,
                                    elevation: 0.0,
                                    child: CircleAvatar(
                                        backgroundColor: ((model.macAddress1Connection == 'disconnected' &&
                                                    model.macAddress2Connection ==
                                                        'disconnected') ||
                                                (model.isBit1Enabled &&
                                                    model.macAddress1Connection !=
                                                        'connected') ||
                                                (model.isBit2Enabled &&
                                                    model.macAddress2Connection !=
                                                        'connected'))
                                            ? Colors.red[800]
                                            : Colors.green[800],
                                        radius: 20,
                                        child: ((model.macAddress1Connection == 'disconnected' &&
                                                    model.macAddress2Connection ==
                                                        'disconnected') ||
                                                (model.isBit1Enabled &&
                                                    model.macAddress1Connection !=
                                                        'connected') ||
                                                (model.isBit2Enabled &&
                                                    model.macAddress2Connection != 'connected'))
                                            ? Icon(Icons.bluetooth_disabled_rounded, color: Colors.white)
                                            : Icon(Icons.bluetooth_connected_rounded, color: Colors.white)),
                                    onPressed: null);
                              });
                        }),
                      )
                    ])
                  : Stack(children: [
                      Align(
                        alignment: Alignment(-0.9, -0.65),
                        child: Builder(builder: (context) {
                          return FloatingActionButton(
                              backgroundColor: Colors.transparent,
                              elevation: 0.0,
                              child: Icon(Icons.more_vert),
                              onPressed: () {
                                Scaffold.of(context).openDrawer();
                              });
                        }),
                      ),
                      Align(
                        alignment: Alignment(0.7, -0.65),
                        child: Builder(builder: (context) {
                          return ValueListenableBuilder(
                              valueListenable: connectionNotifier,
                              builder: (BuildContext context,
                                  MqttCurrentConnectionState state,
                                  Widget child) {
                                return FloatingActionButton(
                                    backgroundColor: Colors.transparent,
                                    elevation: 0.0,
                                    child: CircleAvatar(
                                      backgroundColor: state ==
                                              MqttCurrentConnectionState
                                                  .CONNECTED
                                          ? Colors.green[800]
                                          : state ==
                                                  MqttCurrentConnectionState
                                                      .CONNECTING
                                              ? Colors.yellow[800]
                                              : Colors.red[800],
                                      radius: 20,
                                      child: Icon(Icons.wifi_tethering,
                                          color: Colors.white),
                                    ),
                                    onPressed: null);
                              });
                        }),
                      ),
                      Align(
                        alignment: Alignment(1.1, -0.65),
                        child: Builder(builder: (context) {
                          return PropertyChangeConsumer<MacDevices>(
                              properties: [
                                'macAddress1Connection',
                                'macAddress2Connection',
                                'isBit1Enabled',
                                'isBit2Enabled'
                              ],
                              builder: (context, model, properties) {
                                return FloatingActionButton(
                                    backgroundColor: Colors.transparent,
                                    elevation: 0.0,
                                    child: CircleAvatar(
                                        backgroundColor: ((model.macAddress1Connection == 'disconnected' &&
                                                    model.macAddress2Connection ==
                                                        'disconnected') ||
                                                (model.isBit1Enabled &&
                                                    model.macAddress1Connection !=
                                                        'connected') ||
                                                (model.isBit2Enabled &&
                                                    model.macAddress2Connection !=
                                                        'connected'))
                                            ? Colors.red[800]
                                            : Colors.green[800],
                                        radius: 20,
                                        child: ((model.macAddress1Connection == 'disconnected' &&
                                                    model.macAddress2Connection ==
                                                        'disconnected') ||
                                                (model.isBit1Enabled &&
                                                    model.macAddress1Connection !=
                                                        'connected') ||
                                                (model.isBit2Enabled &&
                                                    model.macAddress2Connection != 'connected'))
                                            ? Icon(Icons.bluetooth_disabled_rounded, color: Colors.white)
                                            : Icon(Icons.bluetooth_connected_rounded, color: Colors.white)),
                                    onPressed: null);
                              });
                        }),
                      ),
                      Align(
                        alignment: Alignment(-0.8, 1.0),
                        child: FloatingActionButton(
                          mini: true,
                          heroTag: null,
                          onPressed: () => _speedAnnotation(),
                          child: Icon(MdiIcons.lightningBolt),
                        ),
                      ),
                      Align(
                          alignment: Alignment(0.2, 1.0),
                          child: ValueListenableBuilder(
                              valueListenable: acquisitionNotifier,
                              builder: (BuildContext context, String state,
                                  Widget child) {
                                return FloatingActionButton(
                                  mini: true,
                                  onPressed: state == 'paused'
                                      ? () => _resumeAcquisition()
                                      : () => _pauseAcquisition(),
                                  child: state == 'paused'
                                      ? Icon(Icons.play_arrow)
                                      : Icon(Icons.pause),
                                );
                              })),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: ValueListenableBuilder(
                            valueListenable: acquisitionNotifier,
                            builder: (BuildContext context, String state,
                                Widget child) {
                              return FloatingActionButton.extended(
                                onPressed:
                                    (state == 'stopped' || state == 'off')
                                        ? () => _startAcquisition()
                                        : () => _stopAcquisition(),
                                label: (state == 'stopped' || state == 'off')
                                    ? Text('Iniciar')
                                    : Text('Parar'),
                                icon: (state == 'stopped' || state == 'off')
                                    ? Icon(Icons.play_arrow_rounded)
                                    : Icon(Icons.stop),
                              );
                            }),
                      ),
                    ]);
            }),
      ),
    );
  }
}
