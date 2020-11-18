import 'package:flutter/material.dart';
import 'package:rPiInterface/utils/models.dart';
import 'package:rPiInterface/utils/mqtt_wrapper.dart';

class ConfigPage extends StatefulWidget {
  MQTTClientWrapper mqttClientWrapper;
  ValueNotifier<MqttCurrentConnectionState> connectionNotifier;
  ValueNotifier<List<String>> driveListNotifier;

  ValueNotifier<bool> isBit1Enabled;
  ValueNotifier<bool> isBit2Enabled;

  ValueNotifier<String> macAddress1Notifier;
  ValueNotifier<String> macAddress2Notifier;

  ValueNotifier<bool> sentConfigNotifier;

  ConfigPage(
      {this.mqttClientWrapper,
      this.connectionNotifier,
      this.driveListNotifier,
      this.isBit1Enabled,
      this.isBit2Enabled,
      this.macAddress1Notifier,
      this.macAddress2Notifier,
      this.sentConfigNotifier,
      });

  @override
  _ConfigPageState createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  String _chosenDrive;

  List<bool> _bit1Selections = List.generate(6, (_) => false);
  List<bool> _bit2Selections = List.generate(6, (_) => false);

  List<String> _channels2Send = [];
  List<String> _sensors2Send = [];

  List<DropdownMenuItem<String>> sensorItems =
      ['-', 'ECG', 'EDA', 'EEG', 'EMG', 'ACC'].map((String value) {
    return new DropdownMenuItem<String>(
      value: value,
      child: Center(
        child: Text(
          value,
          style: TextStyle(color: Colors.black),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }).toList();

  final TextEditingController controllerSensorBit1A1 = TextEditingController();
  final TextEditingController controllerSensorBit1A2 = TextEditingController();
  final TextEditingController controllerSensorBit1A3 = TextEditingController();
  final TextEditingController controllerSensorBit1A4 = TextEditingController();
  final TextEditingController controllerSensorBit1A5 = TextEditingController();
  final TextEditingController controllerSensorBit1A6 = TextEditingController();
  final TextEditingController controllerSensorBit2A1 = TextEditingController();
  final TextEditingController controllerSensorBit2A2 = TextEditingController();
  final TextEditingController controllerSensorBit2A3 = TextEditingController();
  final TextEditingController controllerSensorBit2A4 = TextEditingController();
  final TextEditingController controllerSensorBit2A5 = TextEditingController();
  final TextEditingController controllerSensorBit2A6 = TextEditingController();

  final TextEditingController _controllerFreq = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controllerFreq.text = '1000';
    _chosenDrive = widget.driveListNotifier.value[0];
    controllerSensorBit1A1.text = '-';
    controllerSensorBit1A2.text = '-';
    controllerSensorBit1A3.text = '-';
    controllerSensorBit1A4.text = '-';
    controllerSensorBit1A5.text = '-';
    controllerSensorBit1A6.text = '-';
    controllerSensorBit2A1.text = '-';
    controllerSensorBit2A2.text = '-';
    controllerSensorBit2A3.text = '-';
    controllerSensorBit2A4.text = '-';
    controllerSensorBit2A5.text = '-';
    controllerSensorBit2A6.text = '-';
  }

  Future<void> _setup() async {
    print(
        'mac1: ${widget.macAddress1Notifier.value}, mac2: ${widget.macAddress2Notifier.value}');
    widget.mqttClientWrapper.publishMessage("['FOLDER', '$_chosenDrive']");
    widget.mqttClientWrapper.publishMessage("['FS', ${_controllerFreq.text}]");

    _bit1Selections.asMap().forEach((channel, value) {
      if (value) {
        _channels2Send.add(widget.macAddress1Notifier.value);
        _channels2Send.add((channel + 1).toString());
      }
    });
    _bit2Selections.asMap().forEach((channel, value) {
      if (value) {
        _channels2Send.add(widget.macAddress2Notifier.value);
        _channels2Send.add((channel + 1).toString());
      }
    });
    widget.mqttClientWrapper.publishMessage("['CHANNELS', '$_channels2Send']");

    List<String> sensors = [
      controllerSensorBit1A1.text,
      controllerSensorBit1A2.text,
      controllerSensorBit1A3.text,
      controllerSensorBit1A4.text,
      controllerSensorBit1A5.text,
      controllerSensorBit1A6.text
    ];
    _bit1Selections.asMap().forEach((channel, value) {
      if (value) {
        _sensors2Send.add(sensors[channel]);
      }
    });
    sensors = [
      controllerSensorBit2A1.text,
      controllerSensorBit2A2.text,
      controllerSensorBit2A3.text,
      controllerSensorBit2A4.text,
      controllerSensorBit2A5.text,
      controllerSensorBit2A6.text
    ];
    _bit2Selections.asMap().forEach((channel, value) {
      if (value) {
        _sensors2Send.add(sensors[channel]);
      }
    });
    widget.mqttClientWrapper.publishMessage("['SENSORS', '$_sensors2Send']");

    setState(() => _channels2Send = []);
    setState(() => _sensors2Send = []);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width -
        MediaQuery.of(context).viewInsets.left -
        MediaQuery.of(context).viewInsets.right;

    final height = MediaQuery.of(context).size.height -
        MediaQuery.of(context).viewInsets.top -
        MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      appBar: AppBar(
        title: new Text('Configurações'),
      ),
      body: Center(
        child: ListView(
          children: <Widget>[
            ValueListenableBuilder(
                valueListenable: widget.sentConfigNotifier,
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
                              : 'Selecione configurações para proceder',
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
              padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
              child: Column(children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20.0, 20.0, 0.0, 10.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      child: Text(
                        'Pasta para armazenamento',
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
                  height: height * 0.1,
                  width: width * 0.85,
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
                    child: ListView(
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 0.0),
                          child: DropdownButton(
                            value: _chosenDrive,
                            items: widget.driveListNotifier.value
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              );
                            }).toList(),
                            onChanged: (newDrive) =>
                                setState(() => _chosenDrive = newDrive),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ]),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
              child: Column(children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20.0, 20.0, 0.0, 10.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      child: Text(
                        'Configurações de aquisição',
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
                  height: 320.0,
                  width: width * 0.85,
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
                    child: ListView(
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 0.0),
                          child: Row(
                            children: [
                              Text(
                                'Freq. amostragem [Hz]:',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey[600]),
                              ),
                              Expanded(
                                child: Container(
                                  margin:
                                      EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
                                  child: DropdownButton(
                                    value: _controllerFreq.text,
                                    items: ['1000', '100', '10', '1']
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
                                    onChanged: (fs) => setState(
                                        () => _controllerFreq.text = fs),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 5.0),
                          child: Text(
                            'Canais dispositivo 1:',
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[600]),
                          ),
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              ToggleButtons(
                                constraints: BoxConstraints(
                                    maxHeight: 25.0,
                                    minHeight: 25.0,
                                    maxWidth: 40.0,
                                    minWidth: 40.0),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(25)),
                                renderBorder: true,
                                children: <Widget>[
                                  Text('A1'),
                                  Text('A2'),
                                  Text('A3'),
                                  Text('A4'),
                                  Text('A5'),
                                  Text('A6'),
                                ],
                                isSelected: _bit1Selections,
                                onPressed: widget.isBit1Enabled.value
                                    ? (int index) {
                                        setState(() {
                                          _bit1Selections[index] =
                                              !_bit1Selections[index];
                                        });
                                      }
                                    : null,
                              )
                            ]),
                        Padding(
                          padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 5.0),
                          child: Text(
                            'Canais dispositivo 2:',
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[600]),
                          ),
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              ToggleButtons(
                                constraints: BoxConstraints(
                                    maxHeight: 25.0,
                                    minHeight: 25.0,
                                    maxWidth: 40.0,
                                    minWidth: 40.0),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(25)),
                                renderBorder: true,
                                children: <Widget>[
                                  Text('A1'),
                                  Text('A2'),
                                  Text('A3'),
                                  Text('A4'),
                                  Text('A5'),
                                  Text('A6'),
                                ],
                                isSelected: _bit2Selections,
                                onPressed: widget.isBit2Enabled.value
                                    ? (int index) {
                                        setState(() {
                                          _bit2Selections[index] =
                                              !_bit2Selections[index];
                                        });
                                      }
                                    : null,
                              )
                            ]),
                        Padding(
                          padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 5.0),
                          child: Text(
                            'Sensores dispositivo 1:',
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[600]),
                          ),
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              SensorContainer(
                                  controller: controllerSensorBit1A1,
                                  sensorItems: sensorItems,
                                  position: 'cornerL',
                                  isBitEnabled: widget.isBit1Enabled.value),
                              SensorContainer(
                                  controller: controllerSensorBit1A2,
                                  sensorItems: sensorItems,
                                  position: 'secondL',
                                  isBitEnabled: widget.isBit1Enabled.value),
                              SensorContainer(
                                  controller: controllerSensorBit1A3,
                                  sensorItems: sensorItems,
                                  position: 'middle',
                                  isBitEnabled: widget.isBit1Enabled.value),
                              SensorContainer(
                                  controller: controllerSensorBit1A4,
                                  sensorItems: sensorItems,
                                  position: 'middle',
                                  isBitEnabled: widget.isBit1Enabled.value),
                              SensorContainer(
                                  controller: controllerSensorBit1A5,
                                  sensorItems: sensorItems,
                                  position: 'middle',
                                  isBitEnabled: widget.isBit1Enabled.value),
                              SensorContainer(
                                  controller: controllerSensorBit1A6,
                                  sensorItems: sensorItems,
                                  position: 'cornerR',
                                  isBitEnabled: widget.isBit1Enabled.value),
                            ]),
                        Padding(
                          padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 5.0),
                          child: Text(
                            'Sensores dispositivo 2:',
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[600]),
                          ),
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              SensorContainer(
                                  controller: controllerSensorBit2A1,
                                  sensorItems: sensorItems,
                                  position: 'cornerL',
                                  isBitEnabled: widget.isBit2Enabled.value),
                              SensorContainer(
                                  controller: controllerSensorBit2A2,
                                  sensorItems: sensorItems,
                                  position: 'secondL',
                                  isBitEnabled: widget.isBit2Enabled.value),
                              SensorContainer(
                                  controller: controllerSensorBit2A3,
                                  sensorItems: sensorItems,
                                  position: 'middle',
                                  isBitEnabled: widget.isBit2Enabled.value),
                              SensorContainer(
                                  controller: controllerSensorBit2A4,
                                  sensorItems: sensorItems,
                                  position: 'middle',
                                  isBitEnabled: widget.isBit2Enabled.value),
                              SensorContainer(
                                  controller: controllerSensorBit2A5,
                                  sensorItems: sensorItems,
                                  position: 'middle',
                                  isBitEnabled: widget.isBit2Enabled.value),
                              SensorContainer(
                                  controller: controllerSensorBit2A6,
                                  sensorItems: sensorItems,
                                  position: 'cornerR',
                                  isBitEnabled: widget.isBit2Enabled.value),
                            ]),
                      ],
                    ),
                  ),
                ),
              ]),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    RaisedButton(
                      onPressed: () {
                        _setup();
                      },
                      child: new Text("Selecionar"),
                    ),
                  ]),
            ),
          ],
        ),
      ),
    );
  }
}

class SensorContainer extends StatefulWidget {
  TextEditingController controller;
  List<DropdownMenuItem<String>> sensorItems;
  String position;
  bool isBitEnabled;

  SensorContainer(
      {this.controller, this.sensorItems, this.position, this.isBitEnabled});

  @override
  _SensorContainerState createState() => _SensorContainerState();
}

class _SensorContainerState extends State<SensorContainer> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width -
        MediaQuery.of(context).viewInsets.left -
        MediaQuery.of(context).viewInsets.right;

    Color borderColor = Colors.grey[350];

    return Container(
      width: (width * 0.85 - 2 * 30.0) / 6,
      decoration: (widget.position == 'cornerL')
          ? BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  bottomLeft: Radius.circular(25)),
              border: Border.all(color: borderColor),
            )
          : (widget.position == 'cornerR')
              ? BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(25),
                      bottomRight: Radius.circular(25)),
                  border: Border.all(color: borderColor),
                )
              : (widget.position == 'secondL')
                  ? BoxDecoration(
                      border: Border(
                      top: BorderSide(color: borderColor),
                      bottom: BorderSide(color: borderColor),
                    ))
                  : BoxDecoration(
                      border: Border(
                          top: BorderSide(color: borderColor),
                          bottom: BorderSide(color: borderColor),
                          left: BorderSide(color: borderColor))),
      child: DropdownButtonHideUnderline(
        child: DropdownButton(
          iconSize: 0.0,
          value: widget.controller.text,
          items: widget.sensorItems,
          onChanged: widget.isBitEnabled
              ? (sensor) => setState(() => widget.controller.text = sensor)
              : null,
          isDense: true,
          isExpanded: true,
          disabledHint: Center(
            child: Text(
              '-',
              style: TextStyle(color: Colors.grey[400]),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
