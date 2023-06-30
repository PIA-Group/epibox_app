//import 'package:barcode_scan/barcode_scan.dart';
import 'package:epibox/app_localizations.dart';
import 'package:epibox/classes/configurations.dart';
import 'package:epibox/classes/devices.dart';
import 'package:epibox/classes/error_handler.dart';
import 'package:epibox/classes/shared_pref.dart';
import 'package:epibox/decor/default_colors.dart';
import 'package:epibox/decor/text_styles.dart';
import 'package:epibox/utils/config.dart';
import 'package:epibox/utils/masked_text.dart';
import 'package:epibox/mqtt/mqtt_states.dart';
import 'package:epibox/mqtt/mqtt_wrapper.dart';
import 'package:epibox/utils/tooltips.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:property_change_notifier/property_change_notifier.dart';

class DevicesPage extends StatefulWidget {
  /* This page allows the user to see the current default acquisition devices 
  (sent by PyEpiBOX), as well as defining new default devices */

  final Devices devices;
  final ErrorHandler errorHandler;

  final ValueNotifier<MqttCurrentConnectionState> connectionNotifier;
  final MQTTClientWrapper mqttClientWrapper;
  final MqttCurrentConnectionState connectionState;
  final Preferences preferences;
  final Configurations configurations;

  final ValueNotifier<String> patientNotifier;

  final ValueNotifier<List<String>> driveListNotifier;
  final ValueNotifier<bool> sentConfigNotifier;

  DevicesPage({
    this.devices,
    this.errorHandler,
    this.configurations,
    this.mqttClientWrapper,
    this.connectionState,
    this.preferences,
    this.connectionNotifier,
    this.patientNotifier,
    this.driveListNotifier,
    this.sentConfigNotifier,
  });

  @override
  _DevicesPageState createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  TextEditingController controller1 = TextEditingController();
  TextEditingController controller2 = TextEditingController();

  Map<String, Function> listeners = {
    'defaultMacAddress1': null,
    'defaultMacAddress2': null,
  };

  @override
  void initState() {
    super.initState();

    listeners['defaultMacAddress1'] = () {
      if (widget.devices.defaultMacAddress1 == '')
        controller1.text = ' ';
      else
        controller1.text = widget.devices.defaultMacAddress1;
    };
    listeners['defaultMacAddress2'] = () {
      if (widget.devices.defaultMacAddress2 == '')
        controller2.text = ' ';
      else
        controller2.text = widget.devices.defaultMacAddress2;
    };

    // show changes in default MAC recieved from the RPi
    widget.devices
        .addListener(listeners['defaultMacAddress1'], ['defaultMacAddress1']);
    widget.devices
        .addListener(listeners['defaultMacAddress2'], ['defaultMacAddress2']);

    controller1.addListener(() {
      widget.devices.macAddress1 = controller1.text;
    });
    controller2.addListener(() {
      widget.devices.macAddress2 = controller2.text;
    });

    Future.delayed(Duration.zero).then((value) {
      if (widget.devices.macAddress1 == 'xx:xx:xx:xx:xx:xx') {
        if (widget.devices.defaultMacAddress1 == '') {
          controller1.text = ' ';
        } else {
          controller1.text = widget.devices.defaultMacAddress1;
        }
        if (widget.devices.defaultMacAddress2 == '') {
          controller2.text = ' ';
        } else {
          controller2.text = widget.devices.defaultMacAddress2;
        }
      } else {
        controller1.text =
            widget.devices.macAddress1 == '' ? ' ' : widget.devices.macAddress1;
        controller2.text =
            widget.devices.macAddress2 == '' ? ' ' : widget.devices.macAddress2;
      }
    });
  }

  @override
  void dispose() {
    controller1.dispose();
    controller2.dispose();
    widget.devices.removeListener(
        listeners['defaultMacAddress1'], ['defaultMacAddress1']);
    widget.devices.removeListener(
        listeners['defaultMacAddress2'], ['defaultMacAddress2']);
    super.dispose();
  }

  void _setNewDefault1() {
    widget.devices.defaultMacAddress1 = controller1.text;
  }

  void _setNewDefault2() {
    widget.devices.defaultMacAddress2 = controller2.text;
  }

  @override
  Widget build(BuildContext context) {
    const double horizontalSpacing = 20.0;
    const double verticalSpacing = 20.0;
    final selectDevicesKey = GlobalKey<State<Tooltip>>();
    final connectDevicesKey = GlobalKey<State<Tooltip>>();

    return PropertyChangeProvider(
      value: widget.devices,
      child: ListView(children: <Widget>[
        SizedBox(
          height: verticalSpacing,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalSpacing),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(
                child: Text(
                  AppLocalizations.of(context)
                      .translate('select acquisition device(s)')
                      .inCaps,
                  textAlign: TextAlign.left,
                  style: MyTextStyle(
                    color: DefaultColors.textColorOnLight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              CustomTooltip(
                message: AppLocalizations.of(context)
                        .translate('in case you are')
                        .inCaps +
                    ' ' +
                    AppLocalizations.of(context)
                        .translate('connected to the server') +
                    ' ' +
                    AppLocalizations.of(context).translate(
                        'but the devices show xx:xx:xx:xx:xx:xx, restart') +
                    '.',
                tooltipKey: selectDevicesKey,
              ),
            ]),
            /* ),
            ), */
            SizedBox(
              height: verticalSpacing,
            ),
            SelectDevicesBlock(
              controller1: controller1,
              controller2: controller2,
              preferences: widget.preferences,
            ),
            SizedBox(
              height: verticalSpacing,
            ),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: DefaultColors.mainLColor, // background
                  //onPrimary: Colors.white, // foreground
                ),
                onPressed: () {
                  widget.devices.macAddress1 =
                      controller1.text.replaceAll(new RegExp(r"\s+"), "");
                  widget.devices.macAddress2 =
                      controller2.text.replaceAll(new RegExp(r"\s+"), "");

                  _setNewDefault1();
                  _setNewDefault2();

                  newDefault(
                      widget.mqttClientWrapper,
                      widget.configurations,
                      widget.devices,
                      widget.patientNotifier,
                      widget.preferences);
                },
                child: new Text(
                  AppLocalizations.of(context)
                      .translate('set new default')
                      .inCaps,
                  style: MyTextStyle(),
                ),
              ),
              PropertyChangeConsumer<Devices>(
                  properties: ['macAddress1', 'macAddress2'],
                  builder: (context, devices, properties) {
                    // print(
                    //     'devices: ${devices.macAddress1.trim()} | ${devices.macAddress2.trim()}');
                    if ((devices.macAddress1.trim() != '' &&
                            devices.macAddress1.trim() !=
                                'xx:xx:xx:xx:xx:xx') ||
                        (devices.macAddress2.trim() != '' &&
                            devices.macAddress2.trim() != 'xx:xx:xx:xx:xx:xx'))
                      return CustomTooltip(
                        message: AppLocalizations.of(context)
                                .translate(
                                    'to connect one of the devices, press the corresponding box')
                                .inCaps +
                            '.',
                        tooltipKey: connectDevicesKey,
                      );
                    else
                      return Container();
                  }),
            ]),
            DeviceStateConnectionBlock(
              mqttClientWrapper: widget.mqttClientWrapper,
              devices: widget.devices,
              deviceID: 1,
              controller: controller1,
              verticalSpacing: verticalSpacing,
              errorHandler: widget.errorHandler,
              connectionNotifier: widget.connectionNotifier,
            ),
            DeviceStateConnectionBlock(
              mqttClientWrapper: widget.mqttClientWrapper,
              devices: widget.devices,
              deviceID: 2,
              controller: controller2,
              verticalSpacing: verticalSpacing,
              errorHandler: widget.errorHandler,
              connectionNotifier: widget.connectionNotifier,
            ),
          ]),
        ),
      ]),
    );
  }
}

class SelectDevicesBlock extends StatelessWidget {
  /* Widget that displays the current default acquisition device; allows the 
  user to type a MAC address to become the default; or scan a QR code with the 
  MAC address. */

  final TextEditingController controller1;
  final TextEditingController controller2;
  final Preferences preferences;

  SelectDevicesBlock({
    this.controller1,
    this.controller2,
    this.preferences,
  });

  @override
  Widget build(BuildContext context) {
    final bodyWidth = MediaQuery.of(context).size.width -
        MediaQuery.of(context).viewInsets.left -
        MediaQuery.of(context).viewInsets.right;

    Map<String, TextEditingController> macMap = {
      'MAC 1': controller1,
      'MAC 2': controller2
    };

    return Container(
      height: 150.0,
      width: 0.95 * bodyWidth,
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
          boxShadow: [
            BoxShadow(color: Colors.grey[200], offset: new Offset(5.0, 5.0))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: macMap.entries.map((entry) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.0),
              child: Row(children: [
                Expanded(
                    child: MaskedTextField(
                  key: Key(
                      'device${entry.key.substring(entry.key.length - 1)}TextField'),
                  maskedTextFieldController: entry.value,
                  mask: 'xx:xx:xx:xx:xx:xx',
                  maxLength: 17,
                  inputDecoration: InputDecoration(
                    border: OutlineInputBorder(),
                    counterText: "",
                    labelText: entry.key,
                  ),
                )),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.arrow_drop_down),
                  onSelected: (String value) {
                    entry.value.text = value;
                  },
                  itemBuilder: (BuildContext context) {
                    return preferences.macHistory
                        .map<PopupMenuItem<String>>((String value) {
                      return new PopupMenuItem(
                          child: new Text(value), value: value);
                    }).toList();
                  },
                ),
                IconButton(
                    icon: Icon(
                      MdiIcons.qrcode,
                    ),
                    onPressed: () => {}) //scan(entry.value))
              ]),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class DeviceStateConnectionBlock extends StatelessWidget {
  /* Widget that displays the connection state between the acquisition device 
  and PyEpiBOX. */

  final MQTTClientWrapper mqttClientWrapper;
  final Devices devices;
  final int deviceID;
  final TextEditingController controller;
  final double verticalSpacing;
  final ErrorHandler errorHandler;
  final Preferences preferences;
  final ValueNotifier<MqttCurrentConnectionState> connectionNotifier;

  DeviceStateConnectionBlock({
    this.mqttClientWrapper,
    this.devices,
    this.deviceID,
    this.controller,
    this.verticalSpacing,
    this.errorHandler,
    this.preferences,
    this.connectionNotifier,
  });

  @override
  Widget build(BuildContext context) {
    final bodyWidth = MediaQuery.of(context).size.width -
        MediaQuery.of(context).viewInsets.left -
        MediaQuery.of(context).viewInsets.right;

    const Map<String, String> _connectionStateText = {
      'connected': 'device connected!',
      'connecting': 'connecting...',
      'failed': 'connection failed',
      'other': 'device disconnected',
    };

    const Map<String, Widget> _connectionStateIcon = {
      'connected': CircleAvatar(
        backgroundColor: Color(0xFF2E7D32),
        radius: 15,
        child: Icon(Icons.bluetooth_connected_rounded, color: Colors.white),
      ),
      'connecting': SizedBox(
        width: 40,
        height: 40,
        child: SpinKitFadingCircle(
          size: 40,
          color: DefaultColors.mainColor,
        ),
      ),
      'other': CircleAvatar(
        backgroundColor: Color(0xFFC62828),
        radius: 15,
        child: Icon(Icons.bluetooth_disabled_rounded, color: Colors.white),
      ),
    };

    return PropertyChangeConsumer<Devices>(
      properties: ['macAddress$deviceID', 'macAddress${deviceID}Connection'],
      builder: (context, devices, properties) {
        return Padding(
          padding: EdgeInsets.fromLTRB(5.0, verticalSpacing, 5.0, 0.0),
          child: (devices.get('macAddress$deviceID') == 'xx:xx:xx:xx:xx:xx' ||
                  devices.get('macAddress$deviceID').trim() == '')
              ? Container()
              : Container(
                  width: 0.95 * bodyWidth,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey[200], offset: new Offset(5.0, 5.0))
                    ],
                  ),
                  child: Material(
                    color: Colors.white.withOpacity(0.0),
                    child: Container(
                      child: ListTile(
                        leading: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _connectionStateIcon.containsKey(devices
                                      .get('macAddress${deviceID}Connection'))
                                  ? _connectionStateIcon[devices
                                      .get('macAddress${deviceID}Connection')]
                                  : _connectionStateIcon['other'],
                            ]),
                        title: Text(devices.get('macAddress$deviceID'),
                            style: MyTextStyle(
                                color: DefaultColors.textColorOnLight,
                                fontWeight: FontWeight.bold)),
                        subtitle: Text(
                            AppLocalizations.of(context)
                                .translate(_connectionStateText.containsKey(
                                        devices.get(
                                            'macAddress${deviceID}Connection'))
                                    ? _connectionStateText[devices
                                        .get('macAddress${deviceID}Connection')]
                                    : _connectionStateText['other'])
                                .inCaps,
                            key: Key('connectionStateText$deviceID'),
                            style: MyTextStyle(
                                color: DefaultColors.textColorOnLight)),
                      ),
                    ),
                    // ),
                  ),
                ),
        );
      },
    );
  }
}
