import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:rPiInterface/hospital_pages/config_page.dart';
import 'package:rPiInterface/utils/masked_text.dart';
import 'package:rPiInterface/utils/models.dart';
import 'package:rPiInterface/utils/mqtt_wrapper.dart';
import 'package:shared_preferences/shared_preferences.dart';

// programar button "Usar default" e "Usar novo" para enviar MACAddress para RPi e voltar à HomePage
// programar button "Definir novo default" para enviar MACAddress para RPi e mudar "defaultBIT"

class DevicesPage extends StatefulWidget {
  ValueNotifier<MqttCurrentConnectionState> connectionNotifier;
  MQTTClientWrapper mqttClientWrapper;
  MqttCurrentConnectionState connectionState;

  ValueNotifier<String> defaultMacAddress1Notifier;
  ValueNotifier<String> defaultMacAddress2Notifier;

  ValueNotifier<String> macAddress1Notifier;
  ValueNotifier<String> macAddress2Notifier;

  ValueNotifier<String> patientNotifier;

  ValueNotifier<bool> isBit1Enabled;
  ValueNotifier<bool> isBit2Enabled;

  ValueNotifier<bool> receivedMACNotifier;
  ValueNotifier<bool> sentMACNotifier;

  ValueNotifier<List<String>> historyMAC;

  ValueNotifier<List<String>> driveListNotifier;
  ValueNotifier<bool> sentConfigNotifier;
  ValueNotifier<List> configDefault;
  ValueNotifier<String> chosenDrive;
  ValueNotifier<List<bool>> bit1Selections;
  ValueNotifier<List<bool>> bit2Selections;
  ValueNotifier<List<TextEditingController>> controllerSensors;
  ValueNotifier<TextEditingController> controllerFreq;

  DevicesPage({
    this.mqttClientWrapper,
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
    this.configDefault,
    this.chosenDrive,
    this.bit1Selections,
    this.bit2Selections,
    this.controllerSensors,
    this.controllerFreq,
    this.historyMAC,
  });

  @override
  _DevicesPageState createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  TextEditingController _controller1 = TextEditingController();
  TextEditingController _controller2 = TextEditingController();
  String _histMAC1 = ' ';
  String _histMAC2 = ' ';

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.macAddress1Notifier.value == 'Endereço MAC') {
      _controller1.text = widget.defaultMacAddress1Notifier.value;
      _controller2.text = widget.defaultMacAddress2Notifier.value;
    } else {
      _controller1.text = widget.macAddress1Notifier.value;
      _controller2.text = widget.macAddress2Notifier.value;
    }
  }

  Future<void> _saveMAC(mac1, mac2) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      await prefs.setStringList('lastMAC', [mac1, mac2]);
    } catch (e) {
      print(e);
    }
  }

  void _setNewDefault1() {
    setState(() => widget.defaultMacAddress1Notifier.value = _controller1.text);
  }

  void _setNewDefault2() {
    setState(() => widget.defaultMacAddress2Notifier.value = _controller2.text);
  }

  Future<void> _saveMACHistory(mac1, mac2) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      if (mac1 != '' &&
          mac1 != ' ' &&
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

    return Scaffold(
      appBar: new AppBar(
        title: new Text('BITalino(s)'),
      ),
      body: Center(
        child: ListView(children: <Widget>[
          ValueListenableBuilder(
              valueListenable: widget.connectionNotifier,
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
              valueListenable: widget.sentMACNotifier,
              builder: (BuildContext context, bool state, Widget child) {
                return Container(
                  height: 20,
                  color: state ? Colors.green[50] : Colors.red[50],
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      child: Text(
                        state
                            ? 'Enviado'
                            : 'Selecione dispositivos para proceder',
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
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
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
                child: Column(children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.0, 0.0, 0.0, 20.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        child: Text(
                          'Histórico de dispositivos',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
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
                              color: Colors.grey[200],
                              offset: new Offset(5.0, 5.0))
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(5.0, 0.0, 53.0, 0.0),
                            child: Container(
                              padding: EdgeInsets.all(0),
                              height: 60.0,
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'MAC 1',
                                  border: OutlineInputBorder(),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton(
                                      isDense: true,
                                      value: _histMAC1,
                                      items: widget.historyMAC.value
                                          .map<DropdownMenuItem<String>>(
                                              (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(
                                            value,
                                            style: TextStyle(
                                                color: Colors.grey[600]),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (hist) => {
                                            setState(() => _histMAC1 = hist),
                                            setState(
                                                () => _controller1.text = hist)
                                          }),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(5.0, 0.0, 53.0, 0.0),
                            child: Container(
                              padding: EdgeInsets.all(0),
                              height: 60.0,
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'MAC 2',
                                  border: OutlineInputBorder(),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton(
                                      isDense: true,
                                      value: _histMAC2,
                                      items: widget.historyMAC.value
                                          .map<DropdownMenuItem<String>>(
                                              (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(
                                            value,
                                            style: TextStyle(
                                                color: Colors.grey[600]),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (hist) => {
                                            setState(() => _histMAC2 = hist),
                                            setState(
                                                () => _controller2.text = hist)
                                          }),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ]),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    RaisedButton(
                      onPressed: () {
                        setState(() => widget.macAddress1Notifier.value =
                            _controller1.text
                                .replaceAll(new RegExp(r"\s+"), ""));
                        setState(() => widget.macAddress2Notifier.value =
                            _controller2.text
                                .replaceAll(new RegExp(r"\s+"), ""));
                        widget.mqttClientWrapper.publishMessage(
                            "['USE MAC',{'MAC1':'${widget.macAddress1Notifier.value}','MAC2':'${widget.macAddress2Notifier.value}'}]");
                        widget.mqttClientWrapper.publishMessage(
                            "['ID', '${widget.patientNotifier.value}']");
                        if (widget.macAddress1Notifier.value != ' ' &&
                            widget.macAddress1Notifier.value != '') {
                          setState(() => widget.isBit1Enabled.value = true);
                        }
                        if (widget.macAddress2Notifier.value != ' ' &&
                            widget.macAddress2Notifier.value != '') {
                          setState(() => widget.isBit2Enabled.value = true);
                        }
                        _saveMAC(widget.macAddress1Notifier.value,
                            widget.macAddress2Notifier.value);
                        _saveMACHistory(widget.macAddress1Notifier.value,
                            widget.macAddress2Notifier.value);
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) {
                            return ConfigPage(
                              mqttClientWrapper: widget.mqttClientWrapper,
                              connectionNotifier: widget.connectionNotifier,
                              driveListNotifier: widget.driveListNotifier,
                              isBit1Enabled: widget.isBit1Enabled,
                              isBit2Enabled: widget.isBit2Enabled,
                              macAddress1Notifier: widget.macAddress1Notifier,
                              macAddress2Notifier: widget.macAddress2Notifier,
                              sentConfigNotifier: widget.sentConfigNotifier,
                              configDefault: widget.configDefault,
                              chosenDrive: widget.chosenDrive,
                              bit1Selections: widget.bit1Selections,
                              bit2Selections: widget.bit2Selections,
                              controllerSensors: widget.controllerSensors,
                              controllerFreq: widget.controllerFreq,
                            );
                          }),
                        );
                      },
                      child: new Text("Selecionar"),
                    ),
                    RaisedButton(
                      onPressed: () {
                        setState(() => widget.macAddress1Notifier.value =
                            _controller1.text
                                .replaceAll(new RegExp(r"\s+"), ""));
                        setState(() => widget.macAddress2Notifier.value =
                            _controller2.text
                                .replaceAll(new RegExp(r"\s+"), ""));
                        _setNewDefault1();
                        _setNewDefault2();
                        widget.mqttClientWrapper.publishMessage(
                            "['NEW MAC',{'MAC1':'${widget.macAddress1Notifier.value}','MAC2':'${widget.macAddress2Notifier.value}'}]");
                      },
                      child: new Text("Definir novo default"),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ]),
      ),
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
