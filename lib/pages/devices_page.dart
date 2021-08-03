import 'package:barcode_scan/barcode_scan.dart';
import 'package:epibox/classes/mac_devices.dart';
import 'package:epibox/decor/default_colors.dart';
import 'package:epibox/decor/text_styles.dart';
import 'package:epibox/utils/masked_text.dart';
import 'package:epibox/utils/models.dart';
import 'package:epibox/utils/mqtt_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:property_change_notifier/property_change_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DevicesPage extends StatefulWidget {
  MacDevices macDevices;

  final ValueNotifier<MqttCurrentConnectionState> connectionNotifier;
  final MQTTClientWrapper mqttClientWrapper;
  MqttCurrentConnectionState connectionState;

  final ValueNotifier<String> patientNotifier;

  final ValueNotifier<bool> receivedMACNotifier;
  final ValueNotifier<bool> sentMACNotifier;

  final ValueNotifier<List<String>> historyMAC;

  final ValueNotifier<List<String>> driveListNotifier;
  final ValueNotifier<bool> sentConfigNotifier;

  DevicesPage({
    this.macDevices,
    this.mqttClientWrapper,
    this.connectionNotifier,
    this.patientNotifier,
    this.receivedMACNotifier,
    this.sentMACNotifier,
    this.driveListNotifier,
    this.sentConfigNotifier,
    this.historyMAC,
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
      setState(() => widget.macDevices.macAddress1 = _controller1.text);
    });
    _controller2.addListener(() {
      setState(() => widget.macDevices.macAddress2 = _controller2.text);
    });

    if (widget.macDevices.macAddress1 == 'xx:xx:xx:xx:xx:xx') {
      if (widget.macDevices.defaultMacAddress1 == '') {
        _controller1.text = ' ';
      } else {
        _controller1.text = widget.macDevices.defaultMacAddress1;
      }
      if (widget.macDevices.defaultMacAddress2 == '') {
        _controller2.text = ' ';
      } else {
        _controller2.text = widget.macDevices.defaultMacAddress2;
      }
    } else {
      _controller1.text = widget.macDevices.macAddress1 == ''
          ? ' '
          : widget.macDevices.macAddress1;
      _controller2.text = widget.macDevices.macAddress2 == ''
          ? ' '
          : widget.macDevices.macAddress2;
    }

    // show changes in default MAC recieved from the RPi
    widget.macDevices.addListener(() {
      if (widget.macDevices.defaultMacAddress1 == '')
        setState(() => _controller1.text = ' ');
      else
        setState(
            () => _controller1.text = widget.macDevices.defaultMacAddress1);
    }, ['defaultMacAddress1']);
    widget.macDevices.addListener(() {
      if (widget.macDevices.defaultMacAddress2 == '')
        setState(() => _controller2.text = ' ');
      else
        setState(
            () => _controller2.text = widget.macDevices.defaultMacAddress2);
    }, ['defaultMacAddress2']);
  }

  void _setNewDefault1() {
    setState(() => widget.macDevices.defaultMacAddress1 = _controller1.text);
  }

  void _setNewDefault2() {
    setState(() => widget.macDevices.defaultMacAddress2 = _controller2.text);
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

    return PropertyChangeProvider(
      value: widget.macDevices,
      child: ListView(children: <Widget>[
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
                      setState(() => widget.macDevices.macAddress1 =
                          _controller1.text.replaceAll(new RegExp(r"\s+"), ""));
                      setState(() => widget.macDevices.macAddress2 =
                          _controller2.text.replaceAll(new RegExp(r"\s+"), ""));

                      _setNewDefault1();
                      _setNewDefault2();

                      widget.mqttClientWrapper.publishMessage(
                          "['NEW MAC',{'MAC1':'${widget.macDevices.macAddress1}','MAC2':'${widget.macDevices.macAddress2}'}]");
                    },
                    child: new Text(
                      "Definir novo default",
                      style: MyTextStyle(),
                    ),
                  ),
                ],
              ),
            ),
            PropertyChangeConsumer<MacDevices>(
                properties: ['macAddress1', 'macAddress1Connection'],
                builder: (context, model, properties) {
                  return Padding(
                    padding: EdgeInsets.fromLTRB(5, 20, 5, 0),
                    child: (model.macAddress1 == 'xx:xx:xx:xx:xx:xx' ||
                            model.macAddress1.trim() == '')
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
                                  model.macAddress1Connection = 'connecting';
                                  widget.mqttClientWrapper.publishMessage(
                                      "['CONNECT', '${model.macAddress1}', '${widget.macDevices.type}']");

                                  _saveMAC(
                                      model.macAddress1, model.macAddress2);
                                  _saveMACHistory(
                                      model.macAddress1, model.macAddress2);
                                },
                                child: Container(
                                  child: ListTile(
                                    leading: model.macAddress1Connection ==
                                            'connected'
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
                                        : model.macAddress1Connection ==
                                                'connecting'
                                            ? Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
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
                                                    MainAxisAlignment.center,
                                                children: [
                                                    CircleAvatar(
                                                      backgroundColor:
                                                          Colors.red[800],
                                                      radius: 15,
                                                      child: Icon(
                                                          Icons
                                                              .bluetooth_disabled_rounded,
                                                          color: Colors.white),
                                                    ),
                                                  ]),
                                    title: Text(_controller1.text,
                                        style: MyTextStyle(
                                            color:
                                                DefaultColors.textColorOnLight,
                                            fontWeight: FontWeight.bold)),
                                    subtitle: model.macAddress1Connection ==
                                            'connected'
                                        ? Text('Dispositivo conectado!',
                                            style: MyTextStyle(
                                                color: DefaultColors
                                                    .textColorOnLight))
                                        : model.macAddress1Connection ==
                                                'connecting'
                                            ? Text('A conectar...',
                                                style: MyTextStyle(
                                                    color: DefaultColors
                                                        .textColorOnLight))
                                            : model.macAddress1Connection ==
                                                    'failed'
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
                                  ),
                                ),
                              ),
                            ),
                          ),
                  );
                }),
            PropertyChangeConsumer<MacDevices>(
                properties: ['macAddress2', 'macAddress2Connection'],
                builder: (context, model, properties) {
                  return Padding(
                    padding: EdgeInsets.fromLTRB(5, 20, 5, 0),
                    child: (model.macAddress2 == 'xx:xx:xx:xx:xx:xx' ||
                            model.macAddress2.trim() == '')
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
                                  model.macAddress2Connection = 'connecting';
                                  widget.mqttClientWrapper.publishMessage(
                                      "['CONNECT', '${model.macAddress2}', '${widget.macDevices.type}']");

                                  _saveMAC(
                                      model.macAddress1, model.macAddress2);
                                  _saveMACHistory(
                                      model.macAddress1, model.macAddress2);
                                },
                                child: Container(
                                  child: ListTile(
                                    leading: model.macAddress2Connection ==
                                            'connected'
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
                                        : model.macAddress2Connection ==
                                                'connecting'
                                            ? Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
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
                                                    MainAxisAlignment.center,
                                                children: [
                                                    CircleAvatar(
                                                      backgroundColor:
                                                          Colors.red[800],
                                                      radius: 15,
                                                      child: Icon(
                                                          Icons
                                                              .bluetooth_disabled_rounded,
                                                          color: Colors.white),
                                                    ),
                                                  ]),
                                    title: Text(_controller1.text,
                                        style: MyTextStyle(
                                            color:
                                                DefaultColors.textColorOnLight,
                                            fontWeight: FontWeight.bold)),
                                    subtitle: model.macAddress2Connection ==
                                            'connected'
                                        ? Text('Dispositivo conectado!',
                                            style: MyTextStyle(
                                                color: DefaultColors
                                                    .textColorOnLight))
                                        : model.macAddress2Connection ==
                                                'connecting'
                                            ? Text('A conectar...',
                                                style: MyTextStyle(
                                                    color: DefaultColors
                                                        .textColorOnLight))
                                            : model.macAddress2Connection ==
                                                    'failed'
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
                                  ),
                                ),
                              ),
                            ),
                          ),
                  );
                }),
          ]),
        ),
      ]),
    );
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
