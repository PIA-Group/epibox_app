//import 'dart:convert';

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

  ValueNotifier<List> configDefault;

  ValueNotifier<String> chosenDrive;
  ValueNotifier<List<bool>> bit1Selections;
  ValueNotifier<List<bool>> bit2Selections;
  ValueNotifier<List<TextEditingController>> controllerSensors;
  ValueNotifier<TextEditingController> controllerFreq;

  ConfigPage({
    this.mqttClientWrapper,
    this.connectionNotifier,
    this.driveListNotifier,
    this.isBit1Enabled,
    this.isBit2Enabled,
    this.macAddress1Notifier,
    this.macAddress2Notifier,
    this.sentConfigNotifier,
    this.configDefault,
    this.chosenDrive,
    this.bit1Selections,
    this.bit2Selections,
    this.controllerSensors,
    this.controllerFreq,
  });

  @override
  _ConfigPageState createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  //String widget.chosenDrive;

  /* List<bool> widget.bit1Selections = List.generate(6, (_) => false);
  List<bool> widget.bit2Selections.value = List.generate(6, (_) => false); */

  List<DropdownMenuItem<String>> sensorItems = [
    '-',
    'ECG',
    'EEG',
    'PPG',
    'PZT',
    'ACC',
    'SpO2',
    'EDA',
    'EMG',
    'EOG'
  ].map((String value) {
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


  @override
  void initState() {
    super.initState();

    if (widget.bit1Selections.value == null && widget.bit2Selections.value == null) {
      try {
        _getDefaultChannels(widget.configDefault.value[2]);
      } catch (e) {
        print(e);
      }
    }

    if (widget.controllerSensors.value[0].text == "") {
      try {
        for (int i = 0; i < widget.controllerSensors.value.length; i++) {
          widget.controllerSensors.value[i].text = '-';
        }
        _getDefaultSensors(widget.configDefault.value[2]);
      } catch (e) {
        print(e);
        for (int i = 0; i < widget.controllerSensors.value.length; i++) {
          widget.controllerSensors.value[i].text = '-';
        }
      }
    }

    if (widget.controllerFreq.value.text == '') {
      try {
        widget.controllerFreq.value.text =
            widget.configDefault.value[1].toString();
      } catch (e) {
        print(e);
        widget.controllerFreq.value.text = '1000';
      }
    }

    if (widget.chosenDrive.value == null) {
      try {
        print(widget.driveListNotifier.value.toString());
        if ('${widget.driveListNotifier.value}'
            .contains(widget.configDefault.value[0])) {
          widget.driveListNotifier.value.forEach((element) {
            if (element.contains(widget.configDefault.value[0])) {
              widget.chosenDrive.value = element;
            }
          });
        } else {
          widget.chosenDrive.value = widget.driveListNotifier.value[0];
        }
      } catch (e) {
        print(e);
        widget.chosenDrive.value = widget.driveListNotifier.value[0];
      }
    }
  }

  void _getDefaultChannels(List channels) {
    //List<List<String>>
    setState(() => widget.bit1Selections.value = List.generate(6, (_) => false));
    setState(() => widget.bit2Selections.value = List.generate(6, (_) => false));
    channels.asMap().forEach((i, triplet) {
      if (triplet[0] == widget.macAddress1Notifier.value) {
        widget.bit1Selections.value[int.parse(triplet[1]) - 1] = true;
      }
      if (triplet[0] == widget.macAddress2Notifier.value) {
        widget.bit2Selections.value[int.parse(triplet[1]) - 1] = true;
      }
    });
  }

  void _getDefaultSensors(List channels) {
    //List<String>

    channels.asMap().forEach((i, triplet) {
      if (triplet[0] == widget.macAddress1Notifier.value) {
        widget.controllerSensors.value[int.parse(triplet[1]) - 1].text =
            triplet[2];
      }
      if (triplet[0] == widget.macAddress2Notifier.value) {
        widget.controllerSensors.value[int.parse(triplet[1]) + 5].text =
            triplet[2];
      }
    });
  }

  List<List<String>> _getChannels2Send() {
    List<List<String>> _channels2Send = [];
    widget.bit1Selections.value.asMap().forEach((channel, value) {
      if (value) {
        _channels2Send.add([
          "'${widget.macAddress1Notifier.value}'",
          "'${(channel + 1).toString()}'",
          "'${widget.controllerSensors.value[channel].text}'"
        ]);
      }
    });
    widget.bit2Selections.value.asMap().forEach((channel, value) {
      if (value) {
        _channels2Send.add([
          "'${widget.macAddress2Notifier.value}'",
          "'${(channel + 1).toString()}'",
          "'${widget.controllerSensors.value[channel + 5].text}'"
        ]);
      }
    });
    print('chn: $_channels2Send');
    return _channels2Send;
  }

  void _newDefault() {
    List<List<String>> _channels2Send = _getChannels2Send();
    String _newDefaultDrive = widget.chosenDrive.value
        .substring(0, widget.chosenDrive.value.indexOf('('))
        .trim();
    widget.mqttClientWrapper.publishMessage(
        "['NEW CONFIG DEFAULT', ['$_newDefaultDrive', ${widget.controllerFreq.value.text}, $_channels2Send]]");
  }

  Future<void> _setup() async {
    String _newDrive = widget.chosenDrive.value
        .substring(0, widget.chosenDrive.value.indexOf('('))
        .trim();
    widget.mqttClientWrapper.publishMessage("['FOLDER', '$_newDrive']");
    widget.mqttClientWrapper
        .publishMessage("['FS', ${widget.controllerFreq.value.text}]");

    List<List<String>> _channels2Send = _getChannels2Send();
    widget.mqttClientWrapper.publishMessage("['CHANNELS', $_channels2Send]");

    //List<String> _sensors2Send = _getSensors2Send();
    //widget.mqttClientWrapper.publishMessage("['SENSORS', $_sensors2Send]");

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
                valueListenable: widget.connectionNotifier,
                builder: (BuildContext context,
                    MqttCurrentConnectionState state, Widget child) {
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
              padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
              child: Column(children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20.0, 0.0, 0.0, 10.0),
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
                            value: widget.chosenDrive.value,
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
                            onChanged: (newDrive) => setState(
                                () => widget.chosenDrive.value = newDrive),
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
              child: Column(children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20.0, 0.0, 0.0, 10.0),
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
                                    value: widget.controllerFreq.value.text,
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
                                    onChanged: (fs) => setState(() =>
                                        widget.controllerFreq.value.text = fs),
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
                                isSelected: widget.bit1Selections.value,
                                onPressed: widget.isBit1Enabled.value
                                    ? (int index) {
                                        setState(() {
                                          widget.bit1Selections.value[index] =
                                              !widget
                                                  .bit1Selections.value[index];
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
                                isSelected: widget.bit2Selections.value,
                                onPressed: widget.isBit2Enabled.value
                                    ? (int index) {
                                        setState(() {
                                          widget.bit2Selections.value[index] =
                                              !widget
                                                  .bit2Selections.value[index];
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
                                  controller: widget.controllerSensors.value[0],
                                  sensorItems: sensorItems,
                                  position: 'cornerL',
                                  isBitEnabled: widget.isBit1Enabled.value),
                              SensorContainer(
                                  controller: widget.controllerSensors.value[1],
                                  sensorItems: sensorItems,
                                  position: 'secondL',
                                  isBitEnabled: widget.isBit1Enabled.value),
                              SensorContainer(
                                  controller: widget.controllerSensors.value[2],
                                  sensorItems: sensorItems,
                                  position: 'middle',
                                  isBitEnabled: widget.isBit1Enabled.value),
                              SensorContainer(
                                  controller: widget.controllerSensors.value[3],
                                  sensorItems: sensorItems,
                                  position: 'middle',
                                  isBitEnabled: widget.isBit1Enabled.value),
                              SensorContainer(
                                  controller: widget.controllerSensors.value[4],
                                  sensorItems: sensorItems,
                                  position: 'middle',
                                  isBitEnabled: widget.isBit1Enabled.value),
                              SensorContainer(
                                  controller: widget.controllerSensors.value[5],
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
                                  controller: widget.controllerSensors.value[6],
                                  sensorItems: sensorItems,
                                  position: 'cornerL',
                                  isBitEnabled: widget.isBit2Enabled.value),
                              SensorContainer(
                                  controller: widget.controllerSensors.value[7],
                                  sensorItems: sensorItems,
                                  position: 'secondL',
                                  isBitEnabled: widget.isBit2Enabled.value),
                              SensorContainer(
                                  controller: widget.controllerSensors.value[8],
                                  sensorItems: sensorItems,
                                  position: 'middle',
                                  isBitEnabled: widget.isBit2Enabled.value),
                              SensorContainer(
                                  controller: widget.controllerSensors.value[9],
                                  sensorItems: sensorItems,
                                  position: 'middle',
                                  isBitEnabled: widget.isBit2Enabled.value),
                              SensorContainer(
                                  controller:
                                      widget.controllerSensors.value[10],
                                  sensorItems: sensorItems,
                                  position: 'middle',
                                  isBitEnabled: widget.isBit2Enabled.value),
                              SensorContainer(
                                  controller:
                                      widget.controllerSensors.value[11],
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
                    RaisedButton(
                      onPressed: () {
                        _newDefault();
                      },
                      child: new Text("Definir novo default"),
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
