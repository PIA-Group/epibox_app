import 'package:epibox/classes/configurations.dart';
import 'package:epibox/classes/mac_devices.dart';
import 'package:epibox/decor/default_colors.dart';
import 'package:epibox/decor/text_styles.dart';
import 'package:epibox/utils/models.dart';
import 'package:epibox/utils/mqtt_wrapper.dart';
import 'package:epibox/utils/multiple_value_listnable.dart';
import 'package:flutter/material.dart';
import 'package:property_change_notifier/property_change_notifier.dart';

class ConfigPage extends StatefulWidget {
  MacDevices macDevices;
  Configurations configurations;

  final MQTTClientWrapper mqttClientWrapper;
  final ValueNotifier<MqttCurrentConnectionState> connectionNotifier;
  final ValueNotifier<List<String>> driveListNotifier;

  final ValueNotifier<bool> sentConfigNotifier;

  final ValueNotifier<Map<String, dynamic>> configDefault;

  final ValueNotifier<String> chosenDrive;
  final ValueNotifier<List<TextEditingController>> controllerSensors;
  final ValueNotifier<TextEditingController> controllerFreq;

  final ValueNotifier<bool> saveRaw;
  final ValueNotifier<String> isBitalino;

  ConfigPage({
    this.configurations,
    this.macDevices,
    this.mqttClientWrapper,
    this.connectionNotifier,
    this.driveListNotifier,
    this.sentConfigNotifier,
    this.configDefault,
    this.chosenDrive,
    this.controllerSensors,
    this.controllerFreq,
    this.saveRaw,
    this.isBitalino,
  });

  @override
  _ConfigPageState createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
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
          style: MyTextStyle(color: DefaultColors.textColorOnLight),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }).toList();

  bool _isDefaultDriveInList() {
    bool _isInList = false;
    widget.driveListNotifier.value.forEach((element) {
      if (element.contains(widget.configDefault.value['initial_dir'])) {
        _isInList = true;
      }
    });
    return _isInList;
  }

  @override
  void initState() {
    super.initState();

    if (widget.configurations.bit1Selections == null &&
        widget.configurations.bit2Selections == null) {
      try {
        _getDefaultChannels(widget.configDefault.value['channels']);
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

      // update values upon receiving default configurations from RPi

      widget.configDefault.addListener(() {
        // Storage
        // if the currently available drives doesn't include the previous default drive:
        if (!_isDefaultDriveInList()) {
          widget.chosenDrive.value = widget.driveListNotifier.value[0];
        } else {
          // if it does, include the available space in that drive:
          widget.driveListNotifier.value.forEach((element) {
            if (element.contains(widget.configDefault.value['initial_dir'])) {
              widget.chosenDrive.value = element;
            }
          });
        }
        //
        // Sampling frequency
        setState(() => widget.controllerFreq.value.text =
            widget.configDefault.value['fs'].toString());
        //
        // Save raw
        setState(() => widget.saveRaw.value =
            widget.configDefault.value['saveRaw'] == 'true');

        // Channels & sensors
        _getDefaultChannels(widget.configDefault.value['channels']);
        _getDefaultSensors(widget.configDefault.value['channels']);
      });
    }

    widget.macDevices.addListener(() {
      if (widget.macDevices.macAddress1 == '' ||
          widget.macDevices.macAddress1 == ' ') {
        setState(() => widget.macDevices.isBit1Enabled = false);
      } else {
        setState(() => widget.macDevices.isBit1Enabled = true);
      }
    }, ['macAddress1']);

    widget.macDevices.addListener(() {
      if (widget.macDevices.macAddress2 == '' ||
          widget.macDevices.macAddress2 == ' ') {
        setState(() => widget.macDevices.isBit2Enabled = false);
      } else {
        setState(() => widget.macDevices.isBit2Enabled = true);
      }
    }, ['macAddress2']);

    widget.driveListNotifier.addListener(() {
      if (!widget.driveListNotifier.value.contains(widget.chosenDrive.value))
        setState(
            () => widget.chosenDrive.value = widget.driveListNotifier.value[0]);
    });
  }

  void _getDefaultChannels(List channels) {
    List<bool> _aux1Selections = List.generate(6, (_) => false);
    List<bool> _aux2Selections = List.generate(6, (_) => false);

    channels.asMap().forEach((i, triplet) {
      if (triplet[0] == widget.macDevices.defaultMacAddress1) {
        _aux1Selections[int.parse(triplet[1]) - 1] = true;
      }
      if (triplet[0] == widget.macDevices.defaultMacAddress2) {
        _aux2Selections[int.parse(triplet[1]) - 1] = true;
      }
    });
    setState(() => widget.configurations.bit1Selections = _aux1Selections);
    setState(() => widget.configurations.bit2Selections = _aux2Selections);
  }

  void _getDefaultSensors(List channels) {
    //List<String>

    channels.asMap().forEach((i, triplet) {
      if (triplet[0] == widget.macDevices.defaultMacAddress1) {
        widget.controllerSensors.value[int.parse(triplet[1]) - 1].text =
            triplet[2];
      }
      if (triplet[0] == widget.macDevices.defaultMacAddress2) {
        widget.controllerSensors.value[int.parse(triplet[1]) + 5].text =
            triplet[2];
      }
    });
  }

  List<List<String>> _getChannels2Send() {
    List<List<String>> _channels2Send = [];
    widget.configurations.bit1Selections.asMap().forEach((channel, value) {
      if (value) {
        _channels2Send.add([
          "'${widget.macDevices.macAddress1}'",
          "'${(channel + 1).toString()}'",
          "'${widget.controllerSensors.value[channel].text}'"
        ]);
      }
    });
    widget.configurations.bit2Selections.asMap().forEach((channel, value) {
      if (value) {
        _channels2Send.add([
          "'${widget.macDevices.macAddress2}'",
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
        "['NEW CONFIG DEFAULT', ['$_newDefaultDrive', ${widget.controllerFreq.value.text}, $_channels2Send, '${widget.saveRaw.value}']]");
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width -
        MediaQuery.of(context).viewInsets.left -
        MediaQuery.of(context).viewInsets.right;

    final height = MediaQuery.of(context).size.height -
        MediaQuery.of(context).viewInsets.top -
        MediaQuery.of(context).viewInsets.bottom;

    return PropertyChangeProvider(
      value: widget.macDevices,
      child: ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 0),
            child: Column(children: [
              Padding(
                padding: EdgeInsets.fromLTRB(20.0, 0.0, 0.0, 10.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    child: Text(
                      'Pasta para armazenamento',
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
                padding: EdgeInsets.only(top: 0, bottom: 0),
                height: height * 0.07,
                width: width * 0.9,
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
                  child: ListView(
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 0.0),
                        child: ValueListenableBuilder2(
                            widget.driveListNotifier, widget.chosenDrive,
                            builder: (context, driveList, chosenDrive, child) {
                          return DropdownButton(
                            value: chosenDrive,
                            items: driveList
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: MyTextStyle(
                                      color: DefaultColors.textColorOnLight),
                                ),
                              );
                            }).toList(),
                            onChanged: (newDrive) => setState(
                                () => widget.chosenDrive.value = newDrive),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ]),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Padding(
                padding: EdgeInsets.fromLTRB(20.0, 0.0, 0.0, 10.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    child: Text(
                      'Configurações de aquisição',
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
                padding: EdgeInsets.only(top: 0, bottom: 0),
                width: width * 0.9,
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
                  child: ListView(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 0.0),
                          child: Row(
                            children: [
                              Text(
                                'Freq.amostragem [Hz]:',
                                style: MyTextStyle(
                                    color: DefaultColors.textColorOnLight),
                              ),
                              Expanded(
                                child: Container(
                                  margin:
                                      EdgeInsets.fromLTRB(20.0, 0.0, 10.0, 0.0),
                                  child: DropdownButton(
                                    value: widget.controllerFreq.value.text,
                                    items: [
                                      ' ',
                                      '17000',
                                      '16000',
                                      '10000',
                                      '9000',
                                      '7000',
                                      '6000',
                                      '5000',
                                      '4000',
                                      '3000',
                                      '1000',
                                      '100',
                                      '10',
                                      '1'
                                    ].map<DropdownMenuItem<String>>(
                                        (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(
                                          value,
                                          style: MyTextStyle(
                                              color: DefaultColors
                                                  .textColorOnLight),
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
                          padding: EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 0.0),
                          child: Row(
                            children: [
                              Text(
                                'Guardar dados em bruto?',
                                style: MyTextStyle(
                                    color: DefaultColors.textColorOnLight),
                              ),
                              ValueListenableBuilder(
                                  valueListenable: widget.saveRaw,
                                  builder: (BuildContext context, bool saveRaw,
                                      Widget child) {
                                    return Checkbox(
                                      value: saveRaw,
                                      onChanged: (bool value) {
                                        setState(
                                            () => widget.saveRaw.value = value);
                                      },
                                    );
                                  })
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 5.0),
                          child: Text(
                            'Canais dispositivo 1:',
                            style: MyTextStyle(
                                color: DefaultColors.textColorOnLight),
                          ),
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              PropertyChangeConsumer<Configurations>(
                                  properties: ['bit1Selections'],
                                  builder:
                                      (context, configurations, properties) {
                                    return PropertyChangeConsumer<MacDevices>(
                                        properties: ['isBit1Enabled'],
                                        builder:
                                            (context, macdevices, properties) {
                                          return ToggleButtons(
                                            constraints: BoxConstraints(
                                                maxHeight: 25.0,
                                                minHeight: 25.0,
                                                maxWidth: 40.0,
                                                minWidth: 40.0),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(25)),
                                            renderBorder: true,
                                            children: <Widget>[
                                              Text('A1'),
                                              Text('A2'),
                                              Text('A3'),
                                              Text('A4'),
                                              Text('A5'),
                                              Text('A6'),
                                            ],
                                            isSelected:
                                                configurations.bit1Selections ??
                                                    [
                                                      false,
                                                      false,
                                                      false,
                                                      false,
                                                      false,
                                                      false
                                                    ],
                                            onPressed: macdevices.isBit1Enabled
                                                ? (int index) {
                                                    setState(() {
                                                      widget.configurations
                                                              .bit1Selections[
                                                          index] = !widget
                                                              .configurations
                                                              .bit1Selections[
                                                          index];
                                                    });
                                                  }
                                                : null,
                                          );
                                        });
                                  }),
                            ]),
                        Padding(
                          padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 5.0),
                          child: Text(
                            'Canais dispositivo 2:',
                            style: MyTextStyle(
                                color: DefaultColors.textColorOnLight),
                          ),
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              PropertyChangeConsumer<Configurations>(
                                  properties: ['bit2Selections'],
                                  builder:
                                      (context, configurations, properties) {
                                    return PropertyChangeConsumer<MacDevices>(
                                        properties: ['isBit2Enabled'],
                                        builder:
                                            (context, macdevices, properties) {
                                          return ToggleButtons(
                                            constraints: BoxConstraints(
                                                maxHeight: 25.0,
                                                minHeight: 25.0,
                                                maxWidth: 40.0,
                                                minWidth: 40.0),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(25)),
                                            renderBorder: true,
                                            children: <Widget>[
                                              Text('A1'),
                                              Text('A2'),
                                              Text('A3'),
                                              Text('A4'),
                                              Text('A5'),
                                              Text('A6'),
                                            ],
                                            isSelected:
                                                configurations.bit2Selections ??
                                                    [
                                                      false,
                                                      false,
                                                      false,
                                                      false,
                                                      false,
                                                      false
                                                    ],
                                            onPressed: macdevices.isBit2Enabled
                                                ? (int index) {
                                                    setState(() {
                                                      widget.configurations
                                                              .bit2Selections[
                                                          index] = !widget
                                                              .configurations
                                                              .bit2Selections[
                                                          index];
                                                    });
                                                  }
                                                : null,
                                          );
                                        });
                                  }),
                            ]),
                        Padding(
                          padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 5.0),
                          child: Text(
                            'Sensores dispositivo 1:',
                            style: MyTextStyle(
                                color: DefaultColors.textColorOnLight),
                          ),
                        ),
                        PropertyChangeConsumer<MacDevices>(
                            properties: ['isBit1Enabled'],
                            builder: (context, macdevices, properties) {
                              return ValueListenableBuilder(
                                  valueListenable: widget.controllerSensors,
                                  builder: (BuildContext context,
                                      List<TextEditingController>
                                          controllerSensors,
                                      Widget child) {
                                    return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          SensorContainer(
                                              controller: controllerSensors[0],
                                              sensorItems: sensorItems,
                                              position: 'cornerL',
                                              isBitEnabled:
                                                  macdevices.isBit1Enabled),
                                          SensorContainer(
                                              controller: controllerSensors[1],
                                              sensorItems: sensorItems,
                                              position: 'secondL',
                                              isBitEnabled:
                                                  macdevices.isBit1Enabled),
                                          SensorContainer(
                                              controller: controllerSensors[2],
                                              sensorItems: sensorItems,
                                              position: 'middle',
                                              isBitEnabled:
                                                  macdevices.isBit1Enabled),
                                          SensorContainer(
                                              controller: controllerSensors[3],
                                              sensorItems: sensorItems,
                                              position: 'middle',
                                              isBitEnabled:
                                                  macdevices.isBit1Enabled),
                                          SensorContainer(
                                              controller: controllerSensors[4],
                                              sensorItems: sensorItems,
                                              position: 'middle',
                                              isBitEnabled:
                                                  macdevices.isBit1Enabled),
                                          SensorContainer(
                                              controller: controllerSensors[5],
                                              sensorItems: sensorItems,
                                              position: 'cornerR',
                                              isBitEnabled:
                                                  macdevices.isBit1Enabled),
                                        ]);
                                  });
                            }),
                        Padding(
                          padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 5.0),
                          child: Text(
                            'Sensores dispositivo 2:',
                            style: MyTextStyle(
                                color: DefaultColors.textColorOnLight),
                          ),
                        ),
                        PropertyChangeConsumer<MacDevices>(
                            properties: ['isBit2Enabled'],
                            builder: (context, macdevices, properties) {
                              return ValueListenableBuilder(
                                  valueListenable: widget.controllerSensors,
                                  builder: (BuildContext context,
                                      List<TextEditingController>
                                          controllerSensors,
                                      Widget child) {
                                    return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          SensorContainer(
                                              controller: controllerSensors[6],
                                              sensorItems: sensorItems,
                                              position: 'cornerL',
                                              isBitEnabled:
                                                  macdevices.isBit2Enabled),
                                          SensorContainer(
                                              controller: controllerSensors[7],
                                              sensorItems: sensorItems,
                                              position: 'secondL',
                                              isBitEnabled:
                                                  macdevices.isBit2Enabled),
                                          SensorContainer(
                                              controller: controllerSensors[8],
                                              sensorItems: sensorItems,
                                              position: 'middle',
                                              isBitEnabled:
                                                  macdevices.isBit2Enabled),
                                          SensorContainer(
                                              controller: controllerSensors[9],
                                              sensorItems: sensorItems,
                                              position: 'middle',
                                              isBitEnabled:
                                                  macdevices.isBit2Enabled),
                                          SensorContainer(
                                              controller: controllerSensors[10],
                                              sensorItems: sensorItems,
                                              position: 'middle',
                                              isBitEnabled:
                                                  macdevices.isBit2Enabled),
                                          SensorContainer(
                                              controller: controllerSensors[11],
                                              sensorItems: sensorItems,
                                              position: 'cornerR',
                                              isBitEnabled:
                                                  macdevices.isBit2Enabled),
                                        ]);
                                  });
                            }),
                        SizedBox(
                          height: 10,
                        ),
                      ]),
                ),
              ),
            ]),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: DefaultColors.mainLColor, // background
                      //onPrimary: Colors.white, // foreground
                    ),
                    onPressed: () {
                      _newDefault();
                    },
                    child: new Text(
                      "Definir novo default",
                      style: MyTextStyle(),
                    ),
                  ),
                ]),
          ),
        ],
      ),
    );
  }
}

class SensorContainer extends StatefulWidget {
  final TextEditingController controller;
  final List<DropdownMenuItem<String>> sensorItems;
  final String position;
  final bool isBitEnabled;

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
              style: MyTextStyle(color: DefaultColors.textColorOnLight),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
