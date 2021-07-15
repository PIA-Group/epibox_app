import 'package:barcode_scan/barcode_scan.dart';
import 'package:epibox/decor/default_colors.dart';
import 'package:epibox/decor/text_styles.dart';
import 'package:epibox/utils/masked_text.dart';
import 'package:epibox/utils/models.dart';
import 'package:epibox/utils/mqtt_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DevicesPage extends StatefulWidget {
  final ValueNotifier<MqttCurrentConnectionState> connectionNotifier;
  final MQTTClientWrapper mqttClientWrapper;
  MqttCurrentConnectionState connectionState;

  final ValueNotifier<String> macAddress1ConnectionNotifier;
  final ValueNotifier<String> macAddress2ConnectionNotifier;

  final ValueNotifier<String> defaultMacAddress1Notifier;
  final ValueNotifier<String> defaultMacAddress2Notifier;

  final ValueNotifier<String> macAddress1Notifier;
  final ValueNotifier<String> macAddress2Notifier;

  final ValueNotifier<String> patientNotifier;

  final ValueNotifier<bool> isBit1Enabled;
  final ValueNotifier<bool> isBit2Enabled;

  final ValueNotifier<bool> receivedMACNotifier;
  final ValueNotifier<bool> sentMACNotifier;

  final ValueNotifier<List<String>> historyMAC;

  final ValueNotifier<List<String>> driveListNotifier;
  final ValueNotifier<bool> sentConfigNotifier;
  final ValueNotifier<String> chosenDrive;
  final ValueNotifier<List<bool>> bit1Selections;
  final ValueNotifier<List<bool>> bit2Selections;
  final ValueNotifier<List<TextEditingController>> controllerSensors;
  final ValueNotifier<TextEditingController> controllerFreq;
  final ValueNotifier<bool> saveRaw;
  final ValueNotifier<String> isBitalino;

  DevicesPage({
    this.mqttClientWrapper,
    this.macAddress1ConnectionNotifier,
    this.macAddress2ConnectionNotifier,
    this.defaultMacAddress1Notifier,
    this.defaultMacAddress2Notifier,
    this.macAddress1Notifier,
    this.macAddress2Notifier,
    this.connectionNotifier,
    this.patientNotifier,
    this.isBit1Enabled,
    this.isBit2Enabled,
    this.receivedMACNotifier,
    this.sentMACNotifier,
    this.driveListNotifier,
    this.sentConfigNotifier,
    this.chosenDrive,
    this.bit1Selections,
    this.bit2Selections,
    this.controllerSensors,
    this.controllerFreq,
    this.historyMAC,
    this.saveRaw,
    this.isBitalino,
  });

  @override
  _DevicesPageState createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  TextEditingController _controller1 = TextEditingController();
  TextEditingController _controller2 = TextEditingController();

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _controller1.addListener(() {
      setState(() => widget.macAddress1Notifier.value = _controller1.text);
    });
    _controller2.addListener(() {
      setState(() => widget.macAddress2Notifier.value = _controller2.text);
    });

    if (widget.macAddress1Notifier.value == 'xx:xx:xx:xx:xx:xx') {
      if (widget.defaultMacAddress1Notifier.value == '') {
        _controller1.text = ' ';
      } else {
        _controller1.text = widget.defaultMacAddress1Notifier.value;
      }
      if (widget.defaultMacAddress2Notifier.value == '') {
        _controller2.text = ' ';
      } else {
        _controller2.text = widget.defaultMacAddress2Notifier.value;
      }
    } else {
      _controller1.text = widget.macAddress1Notifier.value == ''
          ? ' '
          : widget.macAddress1Notifier.value;
      _controller2.text = widget.macAddress2Notifier.value == ''
          ? ' '
          : widget.macAddress2Notifier.value;
    }

    // show changes in default MAC recieved from the RPi
    widget.defaultMacAddress1Notifier.addListener(() {
      if (widget.defaultMacAddress1Notifier.value == '')
        setState(() => _controller1.text = ' ');
      else
        setState(
            () => _controller1.text = widget.defaultMacAddress1Notifier.value);
    });
    widget.defaultMacAddress2Notifier.addListener(() {
      if (widget.defaultMacAddress2Notifier.value == '')
        setState(() => _controller2.text = ' ');
      else
        setState(
            () => _controller2.text = widget.defaultMacAddress2Notifier.value);
    });
  }

  void _setNewDefault1() {
    setState(() => widget.defaultMacAddress1Notifier.value = _controller1.text);
  }

  void _setNewDefault2() {
    setState(() => widget.defaultMacAddress2Notifier.value = _controller2.text);
  }

  Future<void> _saveMAC(mac1, mac2) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      await prefs.setStringList('lastMAC', [mac1, mac2]);
    } catch (e) {
      print(e);
    }
  }

  Future<void> _saveMACHistory(mac1, mac2) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      if (mac1 != '' &&
          mac1 != ' ' &&
          mac1 != 'xx:xx:xx:xx:xx:xx' &&
          !widget.historyMAC.value.contains(mac1)) {
        setState(() => widget.historyMAC.value.add(_controller1.text));
        await prefs.setStringList('historyMAC', widget.historyMAC.value);
      }
    } catch (e) {
      print(e);
    }

    try {
      if (mac2 != '' &&
          mac2 != ' ' &&
          mac2 != 'xx:xx:xx:xx:xx:xx' &&
          !widget.historyMAC.value.contains(mac2)) {
        setState(() => widget.historyMAC.value.add(mac2));
        await prefs.setStringList('historyMAC', widget.historyMAC.value);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bodyWidth = MediaQuery.of(context).size.width -
        MediaQuery.of(context).viewInsets.left -
        MediaQuery.of(context).viewInsets.right;

    return ListView(children: <Widget>[
      Padding(
        padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
        child: Column(children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20.0, 0.0, 0.0, 20.0),
            child: Align(
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
          ),
          Container(
            height: 150.0,
            width: 0.95 * bodyWidth,
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey[200], offset: new Offset(5.0, 5.0))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
                    child: Row(children: [
                      Expanded(
                        child: MaskedTextField(
                          maskedTextFieldController: _controller1,
                          mask: 'xx:xx:xx:xx:xx:xx',
                          maxLength: 17,
                          inputDecoration: InputDecoration(
                            border: OutlineInputBorder(),
                            counterText: "",
                            labelText: "MAC 1",
                          ),
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.arrow_drop_down),
                        onSelected: (String value) {
                          _controller1.text = value;
                        },
                        itemBuilder: (BuildContext context) {
                          return widget.historyMAC.value
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
                          onPressed: () => scan(_controller1))
                    ]),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
                    child: Row(children: [
                      Expanded(
                        child: MaskedTextField(
                          maskedTextFieldController: _controller2,
                          mask: 'xx:xx:xx:xx:xx:xx',
                          maxLength: 17,
                          inputDecoration: InputDecoration(
                            border: OutlineInputBorder(),
                            counterText: "",
                            labelText: "MAC 2",
                          ),
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.arrow_drop_down),
                        onSelected: (String value) {
                          _controller2.text = value;
                        },
                        itemBuilder: (BuildContext context) {
                          return widget.historyMAC.value
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
                          onPressed: () => scan(_controller2))
                    ]),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: DefaultColors.mainLColor, // background
                    //onPrimary: Colors.white, // foreground
                  ),
                  onPressed: () {
                    setState(() => widget.macAddress1Notifier.value =
                        _controller1.text.replaceAll(new RegExp(r"\s+"), ""));
                    setState(() => widget.macAddress2Notifier.value =
                        _controller2.text.replaceAll(new RegExp(r"\s+"), ""));
                    _setNewDefault1();
                    _setNewDefault2();
                    widget.mqttClientWrapper.publishMessage(
                        "['NEW MAC',{'MAC1':'${widget.macAddress1Notifier.value}','MAC2':'${widget.macAddress2Notifier.value}'}]");
                  },
                  child: new Text(
                    "Definir novo default",
                    style: MyTextStyle(),
                  ),
                ),
              ],
            ),
          ),
          ValueListenableBuilder(
              valueListenable: widget.macAddress1Notifier,
              builder: (BuildContext context, String macAddress, Widget child) {
                return Padding(
                  padding: EdgeInsets.fromLTRB(5, 20, 5, 0),
                  child: (widget.macAddress1Notifier.value ==
                              'xx:xx:xx:xx:xx:xx' ||
                          widget.macAddress1Notifier.value.trim() == '')
                      ? Container()
                      : Container(
                          width: 0.95 * bodyWidth,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.rectangle,
                            borderRadius:
                                BorderRadius.all(Radius.circular(8.0)),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey[200],
                                  offset: new Offset(5.0, 5.0))
                            ],
                          ),
                          child: Material(
                            color: Colors.white.withOpacity(0.0),
                            child: InkWell(
                              onTap: () {
                                widget.macAddress1ConnectionNotifier.value =
                                    'connecting';
                                widget.mqttClientWrapper.publishMessage(
                                    "['CONNECT', '${widget.macAddress1Notifier.value}', '${widget.isBitalino.value}']");

                                _saveMAC(widget.macAddress1Notifier.value,
                                    widget.macAddress2Notifier.value);
                                _saveMACHistory(
                                    widget.macAddress1Notifier.value,
                                    widget.macAddress2Notifier.value);
                              },
                              child: Container(
                                child: ValueListenableBuilder(
                                    valueListenable:
                                        widget.macAddress1ConnectionNotifier,
                                    builder: (BuildContext context,
                                        String state, Widget child) {
                                      return ListTile(
                                        leading: state == 'connected'
                                            ? Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                    CircleAvatar(
                                                      backgroundColor:
                                                          Colors.green[800],
                                                      radius: 15,
                                                      child: Icon(
                                                          Icons
                                                              .bluetooth_connected_rounded,
                                                          color: Colors.white),
                                                    ),
                                                  ])
                                            : state == 'connecting'
                                                ? Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                        SizedBox(
                                                          width: 40,
                                                          height: 40,
                                                          child:
                                                              SpinKitFadingCircle(
                                                            size: 40,
                                                            color: DefaultColors
                                                                .mainColor,
                                                          ),
                                                        ),
                                                      ])
                                                : Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                        CircleAvatar(
                                                          backgroundColor:
                                                              Colors.red[800],
                                                          radius: 15,
                                                          child: Icon(
                                                              Icons
                                                                  .bluetooth_disabled_rounded,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ]),
                                        title: Text(_controller1.text,
                                            style: MyTextStyle(
                                                color: DefaultColors
                                                    .textColorOnLight,
                                                fontWeight: FontWeight.bold)),
                                        subtitle: state == 'connected'
                                            ? Text('Dispositivo conectado!',
                                                style: MyTextStyle(
                                                    color: DefaultColors
                                                        .textColorOnLight))
                                            : state == 'connecting'
                                                ? Text('A conectar...',
                                                    style: MyTextStyle(
                                                        color: DefaultColors
                                                            .textColorOnLight))
                                                : state == 'failed'
                                                    ? Text('Falha na conexão',
                                                        style: MyTextStyle(
                                                            color: DefaultColors
                                                                .textColorOnLight))
                                                    : Text(
                                                        'Dispositivo desconectado',
                                                        style: MyTextStyle(
                                                            color: DefaultColors
                                                                .textColorOnLight)),
                                        //isThreeLine: true,
                                      );
                                    }),
                              ),
                            ),
                          ),
                        ),
                );
              }),
          ValueListenableBuilder(
              valueListenable: widget.macAddress2Notifier,
              builder: (BuildContext context, String macAddress, Widget child) {
                return Padding(
                  padding: EdgeInsets.fromLTRB(5, 20, 5, 0),
                  child: (widget.macAddress2Notifier.value ==
                              'xx:xx:xx:xx:xx:xx' ||
                          widget.macAddress2Notifier.value.trim() == '')
                      ? Container()
                      : Container(
                          width: 0.95 * bodyWidth,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.rectangle,
                            borderRadius:
                                BorderRadius.all(Radius.circular(8.0)),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey[200],
                                  offset: new Offset(5.0, 5.0))
                            ],
                          ),
                          child: Material(
                            color: Colors.white.withOpacity(0.0),
                            child: InkWell(
                              //splashColor: Colors.green,
                              onTap: () {
                                widget.macAddress1ConnectionNotifier.value =
                                    'connecting';
                                widget.mqttClientWrapper.publishMessage(
                                    "['CONNECT', '${widget.macAddress2Notifier.value}', '${widget.isBitalino.value}']");

                                _saveMAC(widget.macAddress1Notifier.value,
                                    widget.macAddress2Notifier.value);
                                _saveMACHistory(
                                    widget.macAddress1Notifier.value,
                                    widget.macAddress2Notifier.value);
                              },
                              child: Container(
                                child: ValueListenableBuilder(
                                    valueListenable:
                                        widget.macAddress2ConnectionNotifier,
                                    builder: (BuildContext context,
                                        String state, Widget child) {
                                      return ListTile(
                                        leading: state == 'connected'
                                            ? Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                    CircleAvatar(
                                                      backgroundColor:
                                                          Colors.green[800],
                                                      radius: 15,
                                                      child: Icon(
                                                          Icons
                                                              .bluetooth_connected_rounded,
                                                          color: Colors.white),
                                                    ),
                                                  ])
                                            : state == 'connecting'
                                                ? Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                        SizedBox(
                                                          width: 40,
                                                          height: 40,
                                                          child:
                                                              SpinKitFadingCircle(
                                                            size: 40,
                                                            color: DefaultColors
                                                                .mainColor,
                                                          ),
                                                        ),
                                                      ])
                                                : Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                        CircleAvatar(
                                                          backgroundColor:
                                                              Colors.red[800],
                                                          radius: 15,
                                                          child: Icon(
                                                              Icons
                                                                  .bluetooth_disabled_rounded,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ]),
                                        title: Text(macAddress,
                                            style: MyTextStyle(
                                                color: DefaultColors
                                                    .textColorOnLight,
                                                fontWeight: FontWeight.bold)),
                                        subtitle: state == 'connected'
                                            ? Text('Dispositivo conectado!',
                                                style: MyTextStyle(
                                                    color: DefaultColors
                                                        .textColorOnLight))
                                            : state == 'connecting'
                                                ? Text('A conectar...',
                                                    style: MyTextStyle(
                                                        color: DefaultColors
                                                            .textColorOnLight))
                                                : state == 'failed'
                                                    ? Text('Falha na conexão',
                                                        style: MyTextStyle(
                                                            color: DefaultColors
                                                                .textColorOnLight))
                                                    : Text(
                                                        'Dispositivo desconectado',
                                                        style: MyTextStyle(
                                                            color: DefaultColors
                                                                .textColorOnLight)),
                                        //isThreeLine: true,
                                      );
                                    }),
                              ),
                            ),
                          ),
                        ),
                );
              }),
        ]),
      ),
    ]);
  }

  Future scan(TextEditingController controller) async {
    try {
      var scan = (await BarcodeScanner.scan());
      String scanString = scan.rawContent;
      setState(() => controller.text = scanString);
    } on PlatformException catch (e) {
      print(e);
    }
  }
}
