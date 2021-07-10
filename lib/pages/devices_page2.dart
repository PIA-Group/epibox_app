import 'package:barcode_scan/barcode_scan.dart';
import 'package:epibox/decor/default_colors.dart';
import 'package:epibox/decor/text_styles.dart';
import 'package:epibox/utils/masked_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class DevicesPage extends StatefulWidget {
  @override
  _DevicesPageState createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {

  TextEditingController _controller1 = TextEditingController();
  TextEditingController _controller2 = TextEditingController();
  String _histMAC1 = ' ';
  String _histMAC2 = ' ';

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
            padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
            child: Align(
              alignment: Alignment.center,
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
                                  items: [_histMAC1]//widget.historyMAC.value
                                      .map<DropdownMenuItem<String>>(
                                          (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
                                        style: MyTextStyle(
                                            color:
                                                DefaultColors.textColorOnLight),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (hist) => {
                                        setState(() => _histMAC1 = hist),
                                        setState(() => _controller1.text = hist)
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
                                  items: [_histMAC2]//widget.historyMAC.value
                                      .map<DropdownMenuItem<String>>(
                                          (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
                                        style: MyTextStyle(
                                            color:
                                                DefaultColors.textColorOnLight),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (hist) => {
                                        setState(() => _histMAC2 = hist),
                                        setState(() => _controller2.text = hist)
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
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: DefaultColors.mainLColor, // background
                    //onPrimary: Colors.white, // foreground
                  ),
                  /* onPressed: () {
                    setState(() => widget.macAddress1Notifier.value =
                        _controller1.text.replaceAll(new RegExp(r"\s+"), ""));
                    setState(() => widget.macAddress2Notifier.value =
                        _controller2.text.replaceAll(new RegExp(r"\s+"), ""));
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
                          saveRaw: widget.saveRaw,
                          isBitalino: widget.isBitalino,
                        );
                      }),
                    );
                  }, */
                  child: new Text(
                    "Selecionar",
                    style: MyTextStyle(),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: DefaultColors.mainLColor, // background
                    //onPrimary: Colors.white, // foreground
                  ),
                  /* onPressed: () {
                    setState(() => widget.macAddress1Notifier.value =
                        _controller1.text.replaceAll(new RegExp(r"\s+"), ""));
                    setState(() => widget.macAddress2Notifier.value =
                        _controller2.text.replaceAll(new RegExp(r"\s+"), ""));
                    _setNewDefault1();
                    _setNewDefault2();
                    widget.mqttClientWrapper.publishMessage(
                        "['NEW MAC',{'MAC1':'${widget.macAddress1Notifier.value}','MAC2':'${widget.macAddress2Notifier.value}'}]");
                  }, */
                  child: new Text(
                    "Definir novo default",
                    style: MyTextStyle(),
                  ),
                ),
              ],
            ),
          ),
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
