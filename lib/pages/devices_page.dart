import 'package:barcode_scan/barcode_scan.dart';
import 'package:epibox/classes/devices.dart';
import 'package:epibox/classes/error_handler.dart';
import 'package:epibox/costum_overlays/devices_overlay.dart';
import 'package:epibox/decor/default_colors.dart';
import 'package:epibox/decor/text_styles.dart';
import 'package:epibox/utils/masked_text.dart';
import 'package:epibox/mqtt/mqtt_states.dart';
import 'package:epibox/mqtt/mqtt_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:property_change_notifier/property_change_notifier.dart';

class DevicesPage extends StatefulWidget {
  final Devices devices;
  final ErrorHandler errorHandler;

  final ValueNotifier<MqttCurrentConnectionState> connectionNotifier;
  final MQTTClientWrapper mqttClientWrapper;
  final MqttCurrentConnectionState connectionState;

  final ValueNotifier<String> patientNotifier;

  final ValueNotifier<List<String>> historyMAC;

  final ValueNotifier<List<String>> driveListNotifier;
  final ValueNotifier<bool> sentConfigNotifier;

  DevicesPage({
    this.devices,
    this.errorHandler,
    this.mqttClientWrapper,
    this.connectionState,
    this.connectionNotifier,
    this.patientNotifier,
    this.driveListNotifier,
    this.sentConfigNotifier,
    this.historyMAC,
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

    print('rebuilding DevicesPage');

    return PropertyChangeProvider(
      value: widget.devices,
      child: ListView(children: <Widget>[
        SizedBox(
          height: verticalSpacing,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalSpacing),
          child: Column(children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                child: Text(
                  'Selecionar dispositivo(s) de aquisição',
                  textAlign: TextAlign.left,
                  style: MyTextStyle(
                    color: DefaultColors.textColorOnLight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: verticalSpacing,
            ),
            SelectDevicesBlock(
              controller1: controller1,
              controller2: controller2,
              historyMAC: widget.historyMAC,
            ),
            SizedBox(
              height: verticalSpacing,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
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

                    widget.mqttClientWrapper.publishMessage(
                        "['NEW MAC',{'MAC1':'${widget.devices.macAddress1}','MAC2':'${widget.devices.macAddress2}'}]");
                  },
                  child: new Text(
                    "Definir novo default",
                    style: MyTextStyle(),
                  ),
                ),
              ],
            ),
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
  final TextEditingController controller1;
  final TextEditingController controller2;
  final ValueNotifier<List<String>> historyMAC;

  SelectDevicesBlock({this.controller1, this.controller2, this.historyMAC});

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
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.arrow_drop_down),
                  onSelected: (String value) {
                    entry.value.text = value;
                  },
                  itemBuilder: (BuildContext context) {
                    return historyMAC.value
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
                    onPressed: () => scan(entry.value))
              ]),
            );
          }).toList(),
        ),
      ),
    );
  }

  Future scan(TextEditingController controller) async {
    try {
      var scan = (await BarcodeScanner.scan());
      String scanString = scan.rawContent;
      controller.text = scanString;
    } on PlatformException catch (e) {
      print(e);
    }
  }
}

class DeviceStateConnectionBlock extends StatelessWidget {
  final MQTTClientWrapper mqttClientWrapper;
  final Devices devices;
  final int deviceID;
  final TextEditingController controller;
  final double verticalSpacing;
  final ErrorHandler errorHandler;
  final ValueNotifier<MqttCurrentConnectionState> connectionNotifier;

  DeviceStateConnectionBlock({
    this.mqttClientWrapper,
    this.devices,
    this.deviceID,
    this.controller,
    this.verticalSpacing,
    this.errorHandler,
    this.connectionNotifier,
  });

  @override
  Widget build(BuildContext context) {
    final bodyWidth = MediaQuery.of(context).size.width -
        MediaQuery.of(context).viewInsets.left -
        MediaQuery.of(context).viewInsets.right;

    const Map<String, String> _connectionStateText = {
      'connected': 'Dispositivo conectado!',
      'connecting': 'A conectar...',
      'failed': 'Falha na conexão',
      'other': 'Dispositivo desconectado',
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
                    child: InkWell(
                      key: Key('connectDeviceButton$deviceID'),
                      onTap: () {
                        if (connectionNotifier.value !=
                            MqttCurrentConnectionState.CONNECTED) {
                          errorHandler.overlayInfo = {
                            'overlayMessage': DevicesCustomOverlay(),
                            'timer': 2,
                            'showOverlay': true
                          };
                        } else {
                          deviceID == 1
                              ? devices.macAddress1Connection = 'connecting'
                              : devices.macAddress2Connection = 'connecting';
                          mqttClientWrapper.publishMessage(
                              "['CONNECT', '${devices.macAddress1}', '${devices.type}']");
                        }
                      },
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
                              _connectionStateText.containsKey(devices
                                      .get('macAddress${deviceID}Connection'))
                                  ? _connectionStateText[devices
                                      .get('macAddress${deviceID}Connection')]
                                  : _connectionStateText['other'],
                              key: Key('connectionStateText$deviceID'),
                              style: MyTextStyle(
                                  color: DefaultColors.textColorOnLight)),
                        ),
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }
}
