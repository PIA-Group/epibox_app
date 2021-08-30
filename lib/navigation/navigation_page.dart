import 'package:epibox/acquisition/acquisition_management.dart';
import 'package:epibox/classes/acquisition.dart';
import 'package:epibox/classes/configurations.dart';
import 'package:epibox/classes/devices.dart';
import 'package:epibox/classes/error_handler.dart';
import 'package:epibox/classes/visualization.dart';
import 'package:epibox/mqtt/connection.dart';
import 'package:epibox/pages/acquisition_page.dart';
import 'package:epibox/pages/config_page.dart';
import 'package:epibox/pages/devices_page.dart';
import 'package:epibox/pages/profile_drawer.dart';
import 'package:epibox/pages/server_page.dart';
import 'package:epibox/shared_pref/pref_handler.dart';
import 'package:epibox/state_handlers/acquisition.dart';
import 'package:epibox/state_handlers/server_connection.dart';
import 'package:epibox/state_handlers/system.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:epibox/decor/text_styles.dart';
import 'package:epibox/decor/default_colors.dart';
import 'package:epibox/mqtt/mqtt_states.dart';
import 'package:epibox/mqtt/mqtt_wrapper.dart';
import 'package:property_change_notifier/property_change_notifier.dart';
import 'package:epibox/decor/custom_icons.dart';

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

  ValueNotifier<bool> shouldRestart = ValueNotifier(null);

  ValueNotifier<bool> receivedMACNotifier = ValueNotifier(false);
  ValueNotifier<bool> sentMACNotifier = ValueNotifier(false);

  ValueNotifier<String> timedOut = ValueNotifier(null);
  ValueNotifier<bool> startupError = ValueNotifier(false);

  Timer timer;

  ValueNotifier<List<String>> historyMAC = ValueNotifier([]);

  MqttCurrentConnectionState connectionState;
  MQTTClientWrapper mqttClientWrapper;
  MqttClient client;

  FlutterLocalNotificationsPlugin batteryNotification =
      FlutterLocalNotificationsPlugin();

  ValueNotifier<List> annotationTypesD = ValueNotifier([]);

  double appBarHeight = 100;
  ValueNotifier<int> _navigationIndex = ValueNotifier(0);

  Future<bool> initialized;

  Map<String, Function> listeners = {
    'connectionNotifier': null,
    'shouldRestart': null,
    'acquisitionState': null,
    'overlayMessage': null,
    'dataMAC': null,
  };

  @override
  void initState() {
    super.initState();

    listeners['connectionNotifier'] = () {
      serverConnectionHandler(context, connectionNotifier, errorHandler);
    };
    listeners['shouldRestart'] = () {
      if (shouldRestart.value != null)
        restart(shouldRestart.value, mqttClientWrapper, devices, acquisition,
            configurations, driveListNotifier);
    };
    listeners['acquisitionState'] = () {
      acquisitionHandler(context, acquisition, errorHandler);
    };
    listeners['overlayMessage'] = () {
      if (context.loaderOverlay.visible) context.loaderOverlay.hide();
      context.loaderOverlay.show();
      Future.delayed(const Duration(seconds: 3), () {
        context.loaderOverlay.hide();
      });
    };
    listeners['dataMAC'] = () {
      visualizationMAC1.dataMAC = acquisition.dataMAC1;
      visualizationMAC2.dataMAC = acquisition.dataMAC2;
    };

    connectionNotifier.addListener(listeners['connectionNotifier']);
    shouldRestart.addListener(listeners['shouldRestart']);
    acquisition
        .addListener(listeners['acquisitionState'], ['acquisitionState']);
    errorHandler.addListener(listeners['overlayMessage'], ['overlayMessage']);
    acquisition.addListener(listeners['dataMAC'], ['dataMAC1', 'dataMAC2']);

    timer = Timer.periodic(Duration(seconds: 15), (Timer t) => print('timer'));

    var initializationSettingsAndroid =
        AndroidInitializationSettings('seizure_icon');
    var initializationSettingsIOs = IOSInitializationSettings();
    var initSetttings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOs);
    batteryNotification.initialize(initSetttings);

    mqttClientWrapper = setupHome(
      mqttClientWrapper: mqttClientWrapper,
      client: client,
      devices: devices,
      acquisition: acquisition,
      configurations: configurations,
      driveListNotifier: driveListNotifier,
      timedOut: timedOut,
      errorHandler: errorHandler,
      shouldRestart: shouldRestart,
      connectionNotifier: connectionNotifier,
    );

    getAnnotationTypes(annotationTypesD);
    getPreviousDeviceType(devices);
    getLastMAC(devices);
    //getLastBatteries(acquisition);
    getMACHistory(historyMAC);

    initialized = initialize();
  }

  @override
  void dispose() {
    timer?.cancel();
    connectionNotifier.removeListener(listeners['connectionNotifier']);
    shouldRestart.removeListener(listeners['shouldRestart']);
    acquisition
        .removeListener(listeners['acquisitionState'], ['acquisitionState']);
    errorHandler.removeListener(listeners['overlayMessage'], ['overlayMessage']);
    acquisition.removeListener(listeners['dataMAC'], ['dataMAC1', 'dataMAC2']);
    super.dispose();
  }

  Future<bool> initialize() async {
    return Future.delayed(const Duration(milliseconds: 500), () {
      return (true);
    });
  }

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
                      patientNotifier: widget.patientNotifier,
                      annotationTypesD: annotationTypesD,
                      timedOut: timedOut,
                      startupError: startupError,
                      shouldRestart: shouldRestart,
                    ),
                    DevicesPage(
                      devices: devices,
                      errorHandler: errorHandler,
                      patientNotifier: widget.patientNotifier,
                      mqttClientWrapper: mqttClientWrapper,
                      connectionNotifier: connectionNotifier,
                      driveListNotifier: driveListNotifier,
                      historyMAC: historyMAC,
                    ),
                    ConfigPage(
                      devices: devices,
                      configurations: configurations,
                      mqttClientWrapper: mqttClientWrapper,
                      connectionNotifier: connectionNotifier,
                      driveListNotifier: driveListNotifier,
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
                bool btState =
                    ((devices.macAddress1Connection == 'disconnected' &&
                            devices.macAddress2Connection == 'disconnected') ||
                        (devices.isBit1Enabled &&
                            devices.macAddress1Connection != 'connected') ||
                        (devices.isBit2Enabled &&
                            devices.macAddress2Connection != 'connected'));
                return index != 3
                    ? Stack(children: [
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
                                          backgroundColor: btState
                                              ? Colors.red[800]
                                              : Colors.green[800],
                                          radius: 20,
                                          child: btState
                                              ? Icon(
                                                  Icons
                                                      .bluetooth_disabled_rounded,
                                                  color: Colors.white)
                                              : Icon(
                                                  Icons
                                                      .bluetooth_connected_rounded,
                                                  color: Colors.white)),
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
                                          backgroundColor: btState
                                              ? Colors.red[800]
                                              : Colors.green[800],
                                          radius: 20,
                                          child: btState
                                              ? Icon(
                                                  Icons
                                                      .bluetooth_disabled_rounded,
                                                  color: Colors.white)
                                              : Icon(
                                                  Icons
                                                      .bluetooth_connected_rounded,
                                                  color: Colors.white)),
                                      onPressed: null);
                                });
                          }),
                        ),
                        Align(
                          alignment: Alignment(-0.8, 1.0),
                          child: FloatingActionButton(
                            mini: true,
                            heroTag: null,
                            onPressed: () => speedAnnotation(
                                context,
                                annotationTypesD,
                                widget.patientNotifier,
                                mqttClientWrapper),
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
                                    onPressed: acquisition.acquisitionState ==
                                            'paused'
                                        ? () =>
                                            resumeAcquisition(mqttClientWrapper)
                                        : () =>
                                            pauseAcquisition(mqttClientWrapper),
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
                                      ? () => startAcquisition(
                                          context: context,
                                          connectionNotifier:
                                              connectionNotifier,
                                          devices: devices,
                                          errorHandler: errorHandler,
                                          configurations: configurations,
                                          mqttClientWrapper: mqttClientWrapper,
                                          visualizationMAC1: visualizationMAC1,
                                          visualizationMAC2: visualizationMAC2,
                                          historyMAC: historyMAC,
                                          patientNotifier:
                                              widget.patientNotifier)
                                      : () =>
                                          stopAcquisition(mqttClientWrapper),
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
