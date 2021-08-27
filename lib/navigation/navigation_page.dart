import 'package:epibox/classes/acquisition.dart';
import 'package:epibox/classes/configurations.dart';
import 'package:epibox/classes/devices.dart';
import 'package:epibox/classes/error_handler.dart';
import 'package:epibox/classes/visualization.dart';
import 'package:epibox/costum_overlays/acquisition_overlay.dart';
import 'package:epibox/costum_overlays/server_overlay.dart';
import 'package:epibox/mqtt/message_handler.dart';
import 'package:epibox/pages/acquisition_page.dart';
import 'package:epibox/pages/config_page.dart';
import 'package:epibox/pages/profile_drawer.dart';
import 'package:epibox/pages/server_page.dart';
import 'package:epibox/pages/speed_annotation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
import '../pages/devices_page.dart';

class NavigationPage extends StatefulWidget {
  final ValueNotifier<String> patientNotifier;
  NavigationPage({this.patientNotifier});

  @override
  _NavigationPageState createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  ValueNotifier<MqttCurrentConnectionState> connectionNotifier =
      ValueNotifier(MqttCurrentConnectionState.DISCONNECTED);

  Devices devices = Devices();
  Configurations configurations = Configurations();
  Acquisition acquisition = Acquisition();
  Visualization visualizationMAC1 = Visualization();
  Visualization visualizationMAC2 = Visualization();
  ErrorHandler errorHandler = ErrorHandler();

  ValueNotifier<List<String>> driveListNotifier = ValueNotifier([' ']);

  ValueNotifier<bool> receivedMACNotifier = ValueNotifier(false);
  ValueNotifier<bool> sentMACNotifier = ValueNotifier(false);
  ValueNotifier<bool> sentConfigNotifier = ValueNotifier(false);

  ValueNotifier<String> timedOut = ValueNotifier(null);
  ValueNotifier<bool> startupError = ValueNotifier(false);

  String message;
  Timer timer;
  ValueNotifier<bool> dialogNotifier = ValueNotifier(false);

  ValueNotifier<List<String>> historyMAC = ValueNotifier([]);

  ValueNotifier<bool> newAnnotation = ValueNotifier(false);

  MqttCurrentConnectionState connectionState;
  MQTTClientWrapper mqttClientWrapper;
  MqttClient client;

  final TextEditingController nameController = TextEditingController();

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

    connectionNotifier.addListener(() {
      if (connectionNotifier.value == MqttCurrentConnectionState.CONNECTING) {
        if (context.loaderOverlay.visible) context.loaderOverlay.hide();
        setState(() => errorHandler.overlayMessage =
            ServerCustomOverlay(connectionState: connectionNotifier.value));
        context.loaderOverlay.show();
      } else if (connectionNotifier.value ==
          MqttCurrentConnectionState.CONNECTED) {
        if (context.loaderOverlay.visible) context.loaderOverlay.hide();
        setState(() => errorHandler.overlayMessage =
            ServerCustomOverlay(connectionState: connectionNotifier.value));
        context.loaderOverlay.show();
        Future.delayed(const Duration(seconds: 2), () {
          setState(() => context.loaderOverlay.hide());
        });
      } else if (connectionNotifier.value ==
          MqttCurrentConnectionState.ERROR_WHEN_CONNECTING) {
        if (context.loaderOverlay.visible) context.loaderOverlay.hide();
        setState(
          () => errorHandler.overlayMessage =
              ServerCustomOverlay(connectionState: connectionNotifier.value),
        );
        context.loaderOverlay.show();
        Future.delayed(const Duration(seconds: 3), () {
          setState(() => context.loaderOverlay.hide());
        });
      }
    });

    errorHandler.addListener(() {
      print('HERE: ${errorHandler.overlayMessage}');
      if (context.loaderOverlay.visible) context.loaderOverlay.hide();
      setState(() => context.loaderOverlay.show());
      Future.delayed(const Duration(seconds: 3), () {
        setState(() => context.loaderOverlay.hide());
      });
    }, ['overlayMessage']);
    acquisition.addListener(() {
      print(
          '---- change in acquisition state: ${acquisition.acquisitionState}');

      if (acquisition.acquisitionState == 'starting') {
        setState(() => errorHandler.overlayMessage =
            AcquisitionCustomOverlay(state: acquisition.acquisitionState));
        context.loaderOverlay.show();
      } else if (acquisition.acquisitionState == 'reconnecting') {
        if (context.loaderOverlay.visible) context.loaderOverlay.hide();
        setState(() => errorHandler.overlayMessage =
            AcquisitionCustomOverlay(state: acquisition.acquisitionState));
        context.loaderOverlay.show();
      } else if (acquisition.acquisitionState == 'paused') {
        if (context.loaderOverlay.visible) context.loaderOverlay.hide();
        setState(() => errorHandler.overlayMessage =
            AcquisitionCustomOverlay(state: acquisition.acquisitionState));
        context.loaderOverlay.show();
        Future.delayed(const Duration(seconds: 3), () {
          setState(() => context.loaderOverlay.hide());
        });
      } else if (acquisition.acquisitionState == 'stopped') {
        if (context.loaderOverlay.visible) context.loaderOverlay.hide();
        setState(() => errorHandler.overlayMessage =
            AcquisitionCustomOverlay(state: acquisition.acquisitionState));
        context.loaderOverlay.show();
        Future.delayed(const Duration(seconds: 3), () {
          setState(() => context.loaderOverlay.hide());
        });
      } else if (acquisition.acquisitionState == 'off') {
        print('do nothing');
      } else {
        if (context.loaderOverlay.visible) context.loaderOverlay.hide();
      }
    }, ['acquisitionState']);

    acquisition.addListener(() {
      setState(() {
        visualizationMAC1.dataMAC = acquisition.dataMAC1;
      });
      setState(() {
        visualizationMAC2.dataMAC = acquisition.dataMAC2;
      });
    }, ['dataMAC1', 'dataMAC2']);

    timer = Timer.periodic(Duration(seconds: 15), (Timer t) => print('timer'));

    var initializationSettingsAndroid =
        AndroidInitializationSettings('seizure_icon');
    var initializationSettingsIOs = IOSInitializationSettings();
    var initSetttings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOs);
    batteryNotification.initialize(initSetttings);

    setupHome();
    nameController.text = " ";
    getAnnotationTypes();
    getPreviousDevice();
    getLastMAC();
    print('LAST MAC: ${devices.macAddress1}, ${devices.macAddress2}');
    getLastBatteries();
    print(
        'LAST BATTERIES: ${acquisition.batteryBit1}, ${acquisition.batteryBit2}');
    getMACHistory();

    initialized = initialize();
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
      setState(() => devices.type = device);
      print('Device: $device');
    } catch (e) {
      print(e);
    }
  }

  void getLastMAC() async {
    await Future.delayed(Duration.zero);
    Future.delayed(Duration.zero, () async {
      await SharedPreferences.getInstance().then((value) {
        List<String> lastMAC = (value.getStringList('lastMAC').toList() ??
            ['xx:xx:xx:xx:xx:xx', 'xx:xx:xx:xx:xx:xx']);
        print('history; ${lastMAC[0]}');
        setState(() => devices.macAddress1 = lastMAC[0]);
        setState(() => devices.macAddress2 = lastMAC[1]);
      });
      print('LAST MAC1: ${devices.macAddress1}, ${devices.macAddress2}');
    });
  }

  Future<void> saveMAC(mac1, mac2) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      await prefs.setStringList('lastMAC', [mac1, mac2]);
    } catch (e) {
      print(e);
    }
  }


  Future<void> saveMACHistory(mac1, mac2) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      if (mac1 != '' &&
          mac1 != ' ' &&
          mac1 != 'xx:xx:xx:xx:xx:xx' &&
          !historyMAC.value.contains(mac1)) {
        historyMAC.value.add(mac1);
        await prefs.setStringList('historyMAC', historyMAC.value);
      }
    } catch (e) {
      print(e);
    }

    try {
      if (mac2 != '' &&
          mac2 != ' ' &&
          mac2 != 'xx:xx:xx:xx:xx:xx' &&
          !historyMAC.value.contains(mac2)) {
        historyMAC.value.add(mac2);
        await prefs.setStringList('historyMAC', historyMAC.value);
      }
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
        setState(() => acquisition.batteryBit1 =
            num.tryParse(lastBatteries[0])?.toDouble());
      }
      if (lastBatteries[1] != null) {
        setState(() => acquisition.batteryBit2 =
            num.tryParse(lastBatteries[1])?.toDouble());
      }
    });
    print(
        'LAST BATTERY: ${acquisition.batteryBit1}, ${acquisition.batteryBit2}');
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
    isMACAddress(message, devices);
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
      print('This is the new MAC connection state ${messageList[2]}');
      if (messageList[1] == devices.macAddress1) {
        setState(() => devices.macAddress1Connection = messageList[2]);
      } else if (messageList[1] == devices.macAddress2) {
        setState(() => devices.macAddress2Connection = messageList[2]);
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

  /* void _isMACAddress(String message) {
    if (message.contains('DEFAULT MAC')) {
      try {
        final List<String> listMAC = message.split(",");
        setState(() {
          devices.defaultMacAddress1 = listMAC[1].split("'")[1];
          devices.defaultMacAddress2 = listMAC[2].split("'")[1];
          devices.macAddress1 = listMAC[1].split("'")[1];
          devices.macAddress2 = listMAC[2].split("'")[1];

          receivedMACNotifier.value = true;
        });
      } catch (e) {
        print(e);
      }

      if (devices.defaultMacAddress1 == '' ||
          devices.defaultMacAddress1 == ' ') {
        setState(() => devices.isBit1Enabled = false);
      } else {
        setState(() => devices.isBit1Enabled = true);
      }
      if (devices.defaultMacAddress2 == '' ||
          devices.defaultMacAddress2 == ' ') {
        setState(() => devices.isBit2Enabled = false);
      } else {
        setState(() => devices.isBit2Enabled = true);
      }
    }
  } */

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
      setState(() => configurations.configDefault = message2List[1]);
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
      setState(() => acquisition.acquisitionState = 'starting');
      print('ACQUISITION STARTING');
    } else if (message.contains('ACQUISITION ON')) {
      //setState(() => acquisition.acquisitionState = 'acquiring');
      print('ACQUIRING');
    } else if (message.contains('RECONNECTING')) {
      setState(() => acquisition.acquisitionState = 'reconnecting');
      print('RECONNECTING ACQUISITION');
    } else if (message.contains('PAIRING')) {
      setState(() => acquisition.acquisitionState = 'pairing');
      print('PAIRING');
    } else if (message.contains('STOPPED')) {
      setState(() => acquisition.acquisitionState = 'stopped');
      _restart(false);
      print('ACQUISITION STOPPED AND SAVED');
    } else if (message.contains('PAUSED')) {
      setState(() => acquisition.acquisitionState = 'paused');
      print('ACQUISITION PAUSED');
    }
  }

  void _isData(String message) {
    if (message.contains('DATA')) {
      setState(() => acquisition.acquisitionState =
          'acquiring'); // if user leaves the app, this will enable the visualization nontheless
      List message2List = json.decode(message);

      if (devices.macAddress1 == 'xx:xx:xx:xx:xx:xx') {
        getLastMAC();
      }

      List<List> dataMAC1 = [];
      List<List> dataMAC2 = [];

      message2List[2].asMap().forEach((index, channel) {
        if (channel[0] == devices.macAddress1) {
          dataMAC1.add(message2List[1][index]);
        } else {
          dataMAC2.add(message2List[1][index]);
        }
      });

      setState(() => acquisition.dataMAC1 = dataMAC1);
      setState(() => acquisition.dataMAC2 = dataMAC2);
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

        if (entry.key == devices.macAddress1) {
          setState(() => acquisition.batteryBit1 = _level);
          if (entry.value <= 3.4) {
            showNotification('1');
          }
        } else if (entry.key == devices.macAddress2) {
          setState(() => acquisition.batteryBit2 = _level);
          if (entry.value <= 3.4) {
            showNotification('2');
          }
        }
      }
      saveBatteries(acquisition.batteryBit1.toString(),
          acquisition.batteryBit2.toString());
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
        devices.defaultMacAddress1 = 'xx:xx:xx:xx:xx:xx';
        devices.defaultMacAddress2 = 'xx:xx:xx:xx:xx:xx';

        devices.macAddress1 = 'xx:xx:xx:xx:xx:xx';
        devices.macAddress2 = 'xx:xx:xx:xx:xx:xx';

        driveListNotifier.value = [' '];
        configurations.chosenDrive = ' ';
        configurations.controllerFreq.text = ' ';

        devices.isBit1Enabled = false;
        devices.isBit2Enabled = false;
      });
    }

    setState(() {
      devices.macAddress1Connection = 'disconnected';
      devices.macAddress2Connection = 'disconnected';

      acquisition.acquisitionState = 'off';

      acquisition.batteryBit1 = null;
      acquisition.batteryBit2 = null;
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

  List<List> _getChannels() {
    List<List<String>> _channels2Send = [];
    List<List<String>> _channels2Save = [];
    List<String> _sensors2Save = [];

    configurations.bit1Selections.asMap().forEach((channel, value) {
      if (value) {
        _channels2Send.add([
          "'${devices.macAddress1}'",
          "'${(channel + 1).toString()}'",
          "'${configurations.controllerSensors[channel].text}'"
        ]);
        _channels2Save
            .add(["${devices.macAddress1}", "${(channel + 1).toString()}"]);
        _sensors2Save.add("${configurations.controllerSensors[channel].text}");
      }
    });
    configurations.bit2Selections.asMap().forEach((channel, value) {
      if (value) {
        _channels2Send.add([
          "'${devices.macAddress2}'",
          "'${(channel + 1).toString()}'",
          "'${configurations.controllerSensors[channel + 5].text}'"
        ]);
      }
    });
    return [_channels2Send, _channels2Save, _sensors2Save];
  }

  Future<void> _startAcquisition() async {
    if (connectionNotifier.value != MqttCurrentConnectionState.CONNECTED ||
        (devices.isBit1Enabled &&
            devices.macAddress1Connection != 'connected') ||
        (devices.isBit2Enabled &&
            devices.macAddress2Connection != 'connected')) {
      if (context.loaderOverlay.visible) context.loaderOverlay.hide();
      setState(() => errorHandler.overlayMessage = Center(
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
      String _newDrive = configurations.chosenDrive
          .substring(0, configurations.chosenDrive.indexOf('('))
          .trim();
      mqttClientWrapper.publishMessage("['FOLDER', '$_newDrive']");
      mqttClientWrapper
          .publishMessage("['FS', ${configurations.controllerFreq.text}]");
      mqttClientWrapper
          .publishMessage("['ID', '${widget.patientNotifier.value}']");
      mqttClientWrapper
          .publishMessage("['SAVE RAW', '${configurations.saveRaw}']");
      mqttClientWrapper.publishMessage("['EPI SERVICE', '${devices.type}']");

      List<List> _channels = _getChannels();
      List<List<String>> _channels2Send = _channels[0];
      mqttClientWrapper.publishMessage("['CHANNELS', $_channels2Send]");

      setState(() {
        visualizationMAC1.channelsMAC = _channels[1];
        visualizationMAC1.sensorsMAC = _channels[2];

        visualizationMAC2.channelsMAC = _channels[1];
        visualizationMAC2.sensorsMAC = _channels[2];
      });

      mqttClientWrapper.publishMessage("['START']");

      saveMAC(devices.macAddress1, devices.macAddress2);
      saveMACHistory(devices.macAddress1, devices.macAddress2);
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
          devices: devices),
      backgroundColor: Colors.transparent,
      key: _scaffoldKey,
      body: LoaderOverlay(
        overlayOpacity: 0.8,
        overlayColor: Colors.white,
        useDefaultLoading: false,
        overlayWidget: errorHandler.overlayMessage,
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
                  child: IndexedStack(index: _navigationIndex.value, children: [
                    ServerPage(
                      devices: devices,
                      acquisition: acquisition,
                      mqttClientWrapper: mqttClientWrapper,
                      connectionNotifier: connectionNotifier,
                      receivedMACNotifier: receivedMACNotifier,
                      driveListNotifier: driveListNotifier,
                      sentMACNotifier: sentMACNotifier,
                      sentConfigNotifier: sentConfigNotifier,
                      patientNotifier: widget.patientNotifier,
                      annotationTypesD: annotationTypesD,
                      timedOut: timedOut,
                      startupError: startupError,
                    ),
                    DevicesPage(
                      devices: devices,
                      errorHandler: errorHandler,
                      patientNotifier: widget.patientNotifier,
                      mqttClientWrapper: mqttClientWrapper,
                      connectionNotifier: connectionNotifier,
                      receivedMACNotifier: receivedMACNotifier,
                      sentMACNotifier: sentMACNotifier,
                      driveListNotifier: driveListNotifier,
                      sentConfigNotifier: sentConfigNotifier,
                      historyMAC: historyMAC,
                    ),
                    ConfigPage(
                      devices: devices,
                      configurations: configurations,
                      mqttClientWrapper: mqttClientWrapper,
                      connectionNotifier: connectionNotifier,
                      driveListNotifier: driveListNotifier,
                      sentConfigNotifier: sentConfigNotifier,
                    ),
                    AcquisitionPage(
                      devices: devices,
                      configurations: configurations,
                      visualizationMAC1: visualizationMAC1,
                      visualizationMAC2: visualizationMAC2,
                      mqttClientWrapper: mqttClientWrapper,
                      patientNotifier: widget.patientNotifier,
                      annotationTypesD: annotationTypesD,
                      connectionNotifier: connectionNotifier,
                      timedOut: timedOut,
                      startupError: startupError,
                    ),
                  ])),
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
        value: acquisition,
        child: PropertyChangeProvider(
          value: devices,
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
                            return PropertyChangeConsumer<Devices>(
                                properties: [
                                  'macAddress1Connection',
                                  'macAddress2Connection',
                                  'isBit1Enabled',
                                  'isBit2Enabled'
                                ],
                                builder: (context, devices, properties) {
                                  return FloatingActionButton(
                                      backgroundColor: Colors.transparent,
                                      elevation: 0.0,
                                      child: CircleAvatar(
                                          backgroundColor:
                                              ((devices.macAddress1Connection == 'disconnected' &&
                                                          devices.macAddress2Connection ==
                                                              'disconnected') ||
                                                      (devices.isBit1Enabled &&
                                                          devices.macAddress1Connection !=
                                                              'connected') ||
                                                      (devices.isBit2Enabled &&
                                                          devices.macAddress2Connection !=
                                                              'connected'))
                                                  ? Colors.red[800]
                                                  : Colors.green[800],
                                          radius: 20,
                                          child: ((devices.macAddress1Connection == 'disconnected' &&
                                                      devices.macAddress2Connection ==
                                                          'disconnected') ||
                                                  (devices.isBit1Enabled &&
                                                      devices.macAddress1Connection !=
                                                          'connected') ||
                                                  (devices.isBit2Enabled &&
                                                      devices.macAddress2Connection != 'connected'))
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
                            return PropertyChangeConsumer<Devices>(
                                properties: [
                                  'macAddress1Connection',
                                  'macAddress2Connection',
                                  'isBit1Enabled',
                                  'isBit2Enabled'
                                ],
                                builder: (context, devices, properties) {
                                  return FloatingActionButton(
                                      backgroundColor: Colors.transparent,
                                      elevation: 0.0,
                                      child: CircleAvatar(
                                          backgroundColor:
                                              ((devices.macAddress1Connection == 'disconnected' &&
                                                          devices.macAddress2Connection ==
                                                              'disconnected') ||
                                                      (devices.isBit1Enabled &&
                                                          devices.macAddress1Connection !=
                                                              'connected') ||
                                                      (devices.isBit2Enabled &&
                                                          devices.macAddress2Connection !=
                                                              'connected'))
                                                  ? Colors.red[800]
                                                  : Colors.green[800],
                                          radius: 20,
                                          child: ((devices.macAddress1Connection == 'disconnected' &&
                                                      devices.macAddress2Connection ==
                                                          'disconnected') ||
                                                  (devices.isBit1Enabled &&
                                                      devices.macAddress1Connection !=
                                                          'connected') ||
                                                  (devices.isBit2Enabled &&
                                                      devices.macAddress2Connection != 'connected'))
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
                            child: PropertyChangeConsumer<Acquisition>(
                                properties: ['acquisitionState'],
                                builder: (context, acquisition, properties) {
                                  return FloatingActionButton(
                                    mini: true,
                                    onPressed:
                                        acquisition.acquisitionState == 'paused'
                                            ? () => _resumeAcquisition()
                                            : () => _pauseAcquisition(),
                                    child:
                                        acquisition.acquisitionState == 'paused'
                                            ? Icon(Icons.play_arrow)
                                            : Icon(Icons.pause),
                                  );
                                })),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: PropertyChangeConsumer<Acquisition>(
                              properties: ['acquisitionState'],
                              builder: (context, acquisition, properties) {
                                return FloatingActionButton.extended(
                                  onPressed: (acquisition.acquisitionState ==
                                              'stopped' ||
                                          acquisition.acquisitionState == 'off')
                                      ? () => _startAcquisition()
                                      : () => _stopAcquisition(),
                                  label: (acquisition.acquisitionState ==
                                              'stopped' ||
                                          acquisition.acquisitionState == 'off')
                                      ? Text('Iniciar')
                                      : Text('Parar'),
                                  icon: (acquisition.acquisitionState ==
                                              'stopped' ||
                                          acquisition.acquisitionState == 'off')
                                      ? Icon(Icons.play_arrow_rounded)
                                      : Icon(Icons.stop),
                                );
                              }),
                        ),
                      ]);
              }),
        ),
      ),
    );
  }
}
