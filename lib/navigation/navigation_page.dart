import 'package:epibox/app_localizations.dart';
import 'package:epibox/classes/acquisition.dart';
import 'package:epibox/classes/configurations.dart';
import 'package:epibox/classes/devices.dart';
import 'package:epibox/classes/error_handler.dart';
import 'package:epibox/classes/shared_pref.dart';
import 'package:epibox/classes/visualization.dart';
import 'package:epibox/mqtt/connection_manager.dart';
import 'package:epibox/navigation/floating_action_buttons.dart';
import 'package:epibox/navigation/visualization_navbar.dart';
import 'package:epibox/user-pages/config_page.dart';
import 'package:epibox/user-pages/devices_page.dart';
import 'package:epibox/user-pages/profile_drawer.dart';
import 'package:epibox/user-pages/server_page.dart';
import 'package:epibox/shared_pref/pref_handler.dart';
import 'package:epibox/costum_overlays/acquisition_state_handler.dart';
import 'package:epibox/costum_overlays/server_connection_handler.dart';
import 'package:epibox/costum_overlays/system_handler.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:epibox/decor/text_styles.dart';
import 'package:epibox/decor/default_colors.dart';
import 'package:epibox/mqtt/mqtt_states.dart';
import 'package:epibox/mqtt/mqtt_wrapper.dart';
import 'package:property_change_notifier/property_change_notifier.dart';
import 'package:epibox/decor/custom_icons.dart';

class NavigationPage extends StatefulWidget {
  /* This page controls navigation through the four main user pages. The 
  variables that are shared across the main pages are all initiated here. 
  Navigation is performed via an IndexedStack within a ValueListenableBuilder. */

  final ValueNotifier<String> patientNotifier;
  NavigationPage({this.patientNotifier});

  @override
  _NavigationPageState createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // ---------------------------------------------------------------------------
  // Initiate variables that are shared across the four main user pages
  ValueNotifier<MqttCurrentConnectionState> connectionNotifier =
      ValueNotifier(MqttCurrentConnectionState.DISCONNECTED);

  // MQTT-related variables
  MqttCurrentConnectionState connectionState;
  MQTTClientWrapper mqttClientWrapper;
  MqttClient client;

  // Variables that hold information/data received from PyEpiBOX via MQTT
  ValueNotifier<bool> receivedMACNotifier = ValueNotifier(false);
  ValueNotifier<bool> sentMACNotifier = ValueNotifier(false);
  ValueNotifier<List<String>> driveListNotifier = ValueNotifier([' ']);
  ValueNotifier<String> timedOut = ValueNotifier(null);
  ValueNotifier<bool> startupError = ValueNotifier(false);

  // App-related variables
  Timer timer;
  double appBarHeight = 100;
  ValueNotifier<int> _navigationIndex = ValueNotifier(0);
  Future<bool> initialized;

  // User interface-related variables
  Devices devices = Devices();
  Configurations configurations = Configurations();
  Acquisition acquisition = Acquisition();
  Visualization visualizationMAC1 = Visualization();
  Visualization visualizationMAC2 = Visualization();
  ErrorHandler errorHandler = ErrorHandler();
  Preferences preferences = Preferences();
  ValueNotifier<String> shouldRestart = ValueNotifier(null);

  // The "listeners" variable stores the listeners added to several other variables
  // (see below) and listen to any changes to those variables. Once a change is
  // detected, some action is performed.
  Map<String, Function> listeners = {
    'navigationIndex': null,
    'connectionNotifier': null,
    'shouldRestart': null,
    'acquisitionState': null,
    'dataMAC': null,
    'overlayInfo': null,
  };

  @override
  void initState() {
    super.initState();
    // Define actions for when changes are detected
    listeners['navigationIndex'] = () {
      if (_navigationIndex.value != 3)
        errorHandler.overlayInfo = {
          'overlayMessage': errorHandler.overlayInfo['overlayMessage'],
          'timer': errorHandler.overlayInfo['timer'],
          'showOverlay': false
        };
    };

    listeners['connectionNotifier'] = () {
      serverConnectionHandler(context, connectionNotifier, errorHandler);
    };
    listeners['shouldRestart'] = () {
      if (shouldRestart.value != null)
        restart(shouldRestart.value, mqttClientWrapper, connectionNotifier,
            devices, acquisition, configurations, driveListNotifier);
    };
    listeners['acquisitionState'] = () {
      acquisitionStateHandler(
          context, acquisition, errorHandler, _navigationIndex);
    };
    listeners['dataMAC'] = () {
      visualizationMAC1.dataMAC = acquisition.dataMAC1;
      visualizationMAC2.dataMAC = acquisition.dataMAC2;
    };
    listeners['overlayInfo'] = () {
      if (errorHandler.overlayInfo['showOverlay']) {
        errorHandler.showOverlay = true;
        if (errorHandler.overlayInfo['timer'] != null) {
          Future.delayed(Duration(seconds: errorHandler.overlayInfo['timer']),
              () {
            errorHandler.showOverlay = false;
          });
        }
      } else {
        errorHandler.showOverlay = false;
      }
    };

    // Assign listeners to corresponding variables
    _navigationIndex.addListener(listeners['navigationIndex']);
    connectionNotifier.addListener(listeners['connectionNotifier']);
    shouldRestart.addListener(listeners['shouldRestart']);
    acquisition
        .addListener(listeners['acquisitionState'], ['acquisitionState']);
    acquisition.addListener(listeners['dataMAC'], ['dataMAC1']);
    errorHandler.addListener(listeners['overlayInfo'], ['overlayInfo']);

    timer = Timer.periodic(Duration(seconds: 15), (Timer t) => print('timer'));

    // Set up MQTT client settings
    mqttClientWrapper = setupHome(
      mqttClientWrapper: mqttClientWrapper,
      client: client,
      devices: devices,
      acquisition: acquisition,
      configurations: configurations,
      driveListNotifier: driveListNotifier,
      timedOut: timedOut,
      errorHandler: errorHandler,
      startupError: startupError,
      shouldRestart: shouldRestart,
      connectionNotifier: connectionNotifier,
      patientNotifier: widget.patientNotifier,
    );
    getAnnotationTypes(preferences);
    getLastDeviceType(devices);
    getMACHistory(preferences);
    initialized = initialize();
  }

  @override
  void dispose() {
    timer?.cancel();
    _navigationIndex.removeListener(listeners['navigationIndex']);
    connectionNotifier.removeListener(listeners['connectionNotifier']);
    shouldRestart.removeListener(listeners['shouldRestart']);
    acquisition
        .removeListener(listeners['acquisitionState'], ['acquisitionState']);
    acquisition.removeListener(listeners['dataMAC'], ['dataMAC1', 'dataMAC2']);
    super.dispose();
  }
  // ---------------------------------------------------------------------------

  void _onNavigationTap(int index) {
    _navigationIndex.value = index;
  }

  Future<bool> initialize() async {
    return Future.delayed(const Duration(milliseconds: 500), () {
      return (true);
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
    'home',
    'devices',
    'configurations',
    'acquisition',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: ProfileDrawer(
        mqttClientWrapper: mqttClientWrapper,
        patientNotifier: widget.patientNotifier,
        devices: devices,
        preferences: preferences,
      ),
      backgroundColor: Colors.transparent,
      key: _scaffoldKey,
      body: Stack(
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
                      builder: (BuildContext context, int i, Widget child) {
                        return _headerIcon[i];
                      }),
                  ValueListenableBuilder(
                      valueListenable: _navigationIndex,
                      builder: (BuildContext context, int i, Widget child) {
                        return Text(
                          AppLocalizations.of(context)
                              .translate(_headerLabel[i])
                              .inCaps,
                          style: MyTextStyle(
                              color: DefaultColors.textColorOnDark,
                              fontSize: 18),
                        );
                      }),
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
              child: ValueListenableBuilder(
                  valueListenable: _navigationIndex,
                  builder: (BuildContext context, int i, Widget child) {
                    return IndexedStack(index: i, //_navigationIndex.value,
                        children: [
                          ServerPage(
                            devices: devices,
                            acquisition: acquisition,
                            mqttClientWrapper: mqttClientWrapper,
                            client: client,
                            configurations: configurations,
                            errorHandler: errorHandler,
                            connectionNotifier: connectionNotifier,
                            receivedMACNotifier: receivedMACNotifier,
                            driveListNotifier: driveListNotifier,
                            sentMACNotifier: sentMACNotifier,
                            patientNotifier: widget.patientNotifier,
                            timedOut: timedOut,
                            startupError: startupError,
                            shouldRestart: shouldRestart,
                          ),
                          DevicesPage(
                            devices: devices,
                            errorHandler: errorHandler,
                            configurations: configurations,
                            patientNotifier: widget.patientNotifier,
                            mqttClientWrapper: mqttClientWrapper,
                            connectionNotifier: connectionNotifier,
                            preferences: preferences,
                            driveListNotifier: driveListNotifier,
                          ),
                          ConfigPage(
                            devices: devices,
                            visualizationMAC1: visualizationMAC1,
                            visualizationMAC2: visualizationMAC2,
                            configurations: configurations,
                            mqttClientWrapper: mqttClientWrapper,
                            connectionNotifier: connectionNotifier,
                            driveListNotifier: driveListNotifier,
                            patientNotifier: widget.patientNotifier,
                            preferences: preferences,
                          ),
                          VisualizationNavPage(
                            devices: devices,
                            configurations: configurations,
                            visualizationMAC1: visualizationMAC1,
                            visualizationMAC2: visualizationMAC2,
                            acquisition: acquisition,
                            mqttClientWrapper: mqttClientWrapper,
                            patientNotifier: widget.patientNotifier,
                            connectionNotifier: connectionNotifier,
                            timedOut: timedOut,
                            startupError: startupError,
                          ),
                        ]);
                  }),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: PropertyChangeProvider(
              value: errorHandler,
              child: PropertyChangeConsumer<ErrorHandler>(
                  properties: ['showOverlay'],
                  builder: (context, error, properties) {
                    if (errorHandler.showOverlay) {
                      return Container(
                        height: double.maxFinite,
                        width: double.maxFinite,
                        color: Colors.white.withOpacity(0.8),
                        child: error.overlayInfo['overlayMessage'],
                      );
                    } else {
                      return Container();
                    }
                  }),
            ),
          ),
        ],
      ),
      bottomNavigationBar: ValueListenableBuilder(
          valueListenable: _navigationIndex,
          builder: (BuildContext context, int index, Widget child) {
            return BottomNavigationBar(
              key: Key('bottomNavbar'),
              selectedItemColor: Colors.black,
              unselectedItemColor: Colors.grey[500],
              showUnselectedLabels: true,
              currentIndex: _navigationIndex.value,
              onTap: (index) {
                _onNavigationTap(index);
              },
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home, key: Key('Início')),
                  label: AppLocalizations.of(context).translate('home').inCaps,
                ),
                BottomNavigationBarItem(
                  icon:
                      Icon(Icons.device_hub_rounded, key: Key('Dispositivos')),
                  label:
                      AppLocalizations.of(context).translate('devices').inCaps,
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings, key: Key('Configurações')),
                  label: AppLocalizations.of(context)
                      .translate('configurations')
                      .inCaps,
                ),
                BottomNavigationBarItem(
                  icon: Icon(Custom.ecg, key: Key('Aquisição')),
                  label: AppLocalizations.of(context)
                      .translate('acquisition')
                      .inCaps,
                ),
              ],
            );
          }),
      // Set of floating action buttons. According to the page the user is in,
      // different floating action buttons are displayed.
      floatingActionButton: PropertyChangeProvider(
        value: acquisition,
        child: PropertyChangeProvider(
          value: devices,
          child: ValueListenableBuilder(
              valueListenable: _navigationIndex,
              builder: (BuildContext context, int index, Widget child) {
                return index != 3
                    ? Stack(children: [
                        DrawerFloater(),
                        MQTTStateFloater(
                            connectionNotifier: connectionNotifier),
                        MACAddressConnectionFloater(),
                      ])
                    : Stack(children: [
                        DrawerFloater(),
                        MQTTStateFloater(
                            connectionNotifier: connectionNotifier),
                        MACAddressConnectionFloater(),
                        SpeedAnnotationFloater(
                          mqttClientWrapper: mqttClientWrapper,
                          patientNotifier: widget.patientNotifier,
                          acquisition: acquisition,
                          errorHandler: errorHandler,
                          preferences: preferences,
                        ),
                        ResumePauseButton(
                          mqttClientWrapper: mqttClientWrapper,
                          errorHandler: errorHandler,
                        ),
                        StartStopButton(
                          connectionNotifier: connectionNotifier,
                          devices: devices,
                          errorHandler: errorHandler,
                          configurations: configurations,
                          mqttClientWrapper: mqttClientWrapper,
                          visualizationMAC1: visualizationMAC1,
                          visualizationMAC2: visualizationMAC2,
                          patientNotifier: widget.patientNotifier,
                          driveListNotifier: driveListNotifier,
                        ),
                      ]);
              }),
        ),
      ),
    );
  }
}
