import 'package:epibox/classes/configurations.dart';
import 'package:epibox/classes/devices.dart';
import 'package:epibox/decor/default_colors.dart';
import 'package:epibox/decor/text_styles.dart';
import 'package:epibox/utils/models.dart';
import 'package:epibox/utils/mqtt_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:property_change_notifier/property_change_notifier.dart';

class ConfigPage extends StatefulWidget {
  final Devices devices;
  final Configurations configurations;

  final MQTTClientWrapper mqttClientWrapper;
  final ValueNotifier<MqttCurrentConnectionState> connectionNotifier;
  final ValueNotifier<List<String>> driveListNotifier;

  final ValueNotifier<bool> sentConfigNotifier;

  ConfigPage({
    this.configurations,
    this.devices,
    this.mqttClientWrapper,
    this.connectionNotifier,
    this.driveListNotifier,
    this.sentConfigNotifier,
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
      if (element
          .contains(widget.configurations.configDefault['initial_dir'])) {
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
        _getDefaultChannels(widget.configurations.configDefault['channels']);
      } catch (e) {
        print(e);
      }
    }

    if (widget.configurations.controllerSensors[0].text == "") {
      try {
        for (int i = 0;
            i < widget.configurations.controllerSensors.length;
            i++) {
          widget.configurations.controllerSensors[i].text = '-';
        }
        _getDefaultSensors(widget.configurations.configDefault[2]);
      } catch (e) {
        print(e);
        for (int i = 0;
            i < widget.configurations.controllerSensors.length;
            i++) {
          widget.configurations.controllerSensors[i].text = '-';
        }
      }

      // update values upon receiving default configurations from RPi

      widget.configurations.addListener(() {
        // Storage
        // if the currently available drives doesn't include the previous default drive:
        if (!_isDefaultDriveInList()) {
          widget.configurations.chosenDrive = widget.driveListNotifier.value[0];
        } else {
          // if it does, include the available space in that drive:
          widget.driveListNotifier.value.forEach((element) {
            if (element
                .contains(widget.configurations.configDefault['initial_dir'])) {
              widget.configurations.chosenDrive = element;
            }
          });
        }
        //
        // Sampling frequency
        setState(() => widget.configurations.controllerFreq.text =
            widget.configurations.configDefault['fs'].toString());
        //
        // Save raw
        setState(() => widget.configurations.saveRaw =
            widget.configurations.configDefault['saveRaw'] == 'true');

        // Channels & sensors
        _getDefaultChannels(widget.configurations.configDefault['channels']);
        _getDefaultSensors(widget.configurations.configDefault['channels']);
      }, ['configDefault']);
    }

    widget.devices.addListener(() {
      if (widget.devices.macAddress1 == '' ||
          widget.devices.macAddress1 == ' ') {
        setState(() => widget.devices.isBit1Enabled = false);
      } else {
        setState(() => widget.devices.isBit1Enabled = true);
      }
    }, ['macAddress1']);

    widget.devices.addListener(() {
      if (widget.devices.macAddress2 == '' ||
          widget.devices.macAddress2 == ' ') {
        setState(() => widget.devices.isBit2Enabled = false);
      } else {
        setState(() => widget.devices.isBit2Enabled = true);
      }
    }, ['macAddress2']);

    widget.driveListNotifier.addListener(() {
      if (!widget.driveListNotifier.value
          .contains(widget.configurations.chosenDrive))
        setState(() => widget.configurations.chosenDrive =
            widget.driveListNotifier.value[0]);
    });
  }

  void _getDefaultChannels(List channels) {
    List<bool> _aux1Selections = List.generate(6, (_) => false);
    List<bool> _aux2Selections = List.generate(6, (_) => false);

    channels.asMap().forEach((i, triplet) {
      if (triplet[0] == widget.devices.defaultMacAddress1) {
        _aux1Selections[int.parse(triplet[1]) - 1] = true;
      }
      if (triplet[0] == widget.devices.defaultMacAddress2) {
        _aux2Selections[int.parse(triplet[1]) - 1] = true;
      }
    });
    setState(() => widget.configurations.bit1Selections = _aux1Selections);
    setState(() => widget.configurations.bit2Selections = _aux2Selections);
  }

  void _getDefaultSensors(List channels) {
    //List<String>

    channels.asMap().forEach((i, triplet) {
      if (triplet[0] == widget.devices.defaultMacAddress1) {
        widget.configurations.controllerSensors[int.parse(triplet[1]) - 1]
            .text = triplet[2];
      }
      if (triplet[0] == widget.devices.defaultMacAddress2) {
        widget.configurations.controllerSensors[int.parse(triplet[1]) + 5]
            .text = triplet[2];
      }
    });
  }

  List<List<String>> _getChannels2Send() {
    List<List<String>> _channels2Send = [];
    widget.configurations.bit1Selections.asMap().forEach((channel, value) {
      if (value) {
        _channels2Send.add([
          "'${widget.devices.macAddress1}'",
          "'${(channel + 1).toString()}'",
          "'${widget.configurations.controllerSensors[channel].text}'"
        ]);
      }
    });
    widget.configurations.bit2Selections.asMap().forEach((channel, value) {
      if (value) {
        _channels2Send.add([
          "'${widget.devices.macAddress2}'",
          "'${(channel + 1).toString()}'",
          "'${widget.configurations.controllerSensors[channel + 5].text}'"
        ]);
      }
    });
    print('chn: $_channels2Send');
    return _channels2Send;
  }

  void _newDefault() {
    List<List<String>> _channels2Send = _getChannels2Send();
    String _newDefaultDrive = widget.configurations.chosenDrive
        .substring(0, widget.configurations.chosenDrive.indexOf('('))
        .trim();
    widget.mqttClientWrapper.publishMessage(
        "['NEW CONFIG DEFAULT', ['$_newDefaultDrive', ${widget.configurations.controllerFreq.text}, $_channels2Send, '${widget.configurations.saveRaw}']]");
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
      value: widget.configurations,
      child: PropertyChangeProvider(
        value: widget.devices,
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
                            color: Colors.grey[200],
                            offset: new Offset(5.0, 5.0))
                      ],
                    ),
                    child: ListView(
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 0.0),
                          child: PropertyChangeConsumer<Configurations>(
                              properties: ['chosenDrive'],
                              builder: (context, configurations, properties) {
                                return ValueListenableBuilder(
                                    valueListenable: widget.driveListNotifier,
                                    builder: (context, driveList, child) {
                                      return DropdownButton(
                                        value: configurations.chosenDrive,
                                        items: driveList
                                            .map<DropdownMenuItem<String>>(
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
                                        onChanged: (newDrive) => setState(() =>
                                            configurations.chosenDrive =
                                                newDrive),
                                      );
                                    });
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
                            color: Colors.grey[200],
                            offset: new Offset(5.0, 5.0))
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
                                    margin: EdgeInsets.fromLTRB(
                                        20.0, 0.0, 10.0, 0.0),
                                    child: DropdownButton(
                                      value: widget
                                          .configurations.controllerFreq.text,
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
                                      onChanged: (fs) => setState(() => widget
                                          .configurations
                                          .controllerFreq
                                          .text = fs),
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
                                PropertyChangeConsumer<Configurations>(
                              properties: ['saveRaw'],
                              builder: (context, configurations, properties) {
                                return Checkbox(
                                        value: configurations.saveRaw,
                                        onChanged: (bool value) {
                                          setState(() =>
                                              configurations.saveRaw = value);
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
                                      return PropertyChangeConsumer<Devices>(
                                          properties: ['isBit1Enabled'],
                                          builder: (context, devices,
                                              properties) {
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
                                              isSelected: configurations
                                                      .bit1Selections ??
                                                  [
                                                    false,
                                                    false,
                                                    false,
                                                    false,
                                                    false,
                                                    false
                                                  ],
                                              onPressed:
                                                  devices.isBit1Enabled
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
                                      return PropertyChangeConsumer<Devices>(
                                          properties: ['isBit2Enabled'],
                                          builder: (context, devices,
                                              properties) {
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
                                              isSelected: configurations
                                                      .bit2Selections ??
                                                  [
                                                    false,
                                                    false,
                                                    false,
                                                    false,
                                                    false,
                                                    false
                                                  ],
                                              onPressed:
                                                  devices.isBit2Enabled
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
                          PropertyChangeConsumer<Devices>(
                              properties: ['isBit1Enabled'],
                              builder: (context, devices, properties) {
                                return PropertyChangeConsumer<Configurations>(
                                    properties: ['controllerSensors'],
                                    builder:
                                        (context, configurations, properties) {
                                      return Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            SensorContainer(
                                                controller: configurations
                                                    .controllerSensors[0],
                                                sensorItems: sensorItems,
                                                position: 'cornerL',
                                                isBitEnabled:
                                                    devices.isBit1Enabled),
                                            SensorContainer(
                                                controller: configurations
                                                    .controllerSensors[1],
                                                sensorItems: sensorItems,
                                                position: 'secondL',
                                                isBitEnabled:
                                                    devices.isBit1Enabled),
                                            SensorContainer(
                                                controller: configurations
                                                    .controllerSensors[2],
                                                sensorItems: sensorItems,
                                                position: 'middle',
                                                isBitEnabled:
                                                    devices.isBit1Enabled),
                                            SensorContainer(
                                                controller: configurations
                                                    .controllerSensors[3],
                                                sensorItems: sensorItems,
                                                position: 'middle',
                                                isBitEnabled:
                                                    devices.isBit1Enabled),
                                            SensorContainer(
                                                controller: configurations
                                                    .controllerSensors[4],
                                                sensorItems: sensorItems,
                                                position: 'middle',
                                                isBitEnabled:
                                                    devices.isBit1Enabled),
                                            SensorContainer(
                                                controller: configurations
                                                    .controllerSensors[5],
                                                sensorItems: sensorItems,
                                                position: 'cornerR',
                                                isBitEnabled:
                                                    devices.isBit1Enabled),
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
                          PropertyChangeConsumer<Devices>(
                              properties: ['isBit2Enabled'],
                              builder: (context, devices, properties) {
                                return PropertyChangeConsumer<Configurations>(
                                    properties: ['controllerSensors'],
                                    builder:
                                        (context, configurations, properties) {
                                      return Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            SensorContainer(
                                                controller: configurations
                                                    .controllerSensors[6],
                                                sensorItems: sensorItems,
                                                position: 'cornerL',
                                                isBitEnabled:
                                                    devices.isBit2Enabled),
                                            SensorContainer(
                                                controller: configurations
                                                    .controllerSensors[7],
                                                sensorItems: sensorItems,
                                                position: 'secondL',
                                                isBitEnabled:
                                                    devices.isBit2Enabled),
                                            SensorContainer(
                                                controller: configurations
                                                    .controllerSensors[8],
                                                sensorItems: sensorItems,
                                                position: 'middle',
                                                isBitEnabled:
                                                    devices.isBit2Enabled),
                                            SensorContainer(
                                                controller: configurations
                                                    .controllerSensors[9],
                                                sensorItems: sensorItems,
                                                position: 'middle',
                                                isBitEnabled:
                                                    devices.isBit2Enabled),
                                            SensorContainer(
                                                controller: configurations
                                                    .controllerSensors[10],
                                                sensorItems: sensorItems,
                                                position: 'middle',
                                                isBitEnabled:
                                                    devices.isBit2Enabled),
                                            SensorContainer(
                                                controller: configurations
                                                    .controllerSensors[11],
                                                sensorItems: sensorItems,
                                                position: 'cornerR',
                                                isBitEnabled:
                                                    devices.isBit2Enabled),
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
          style: new TextStyle(
              color: widget.isBitEnabled
                  ? DefaultColors.textColorOnLight
                  : borderColor),
          disabledHint: Center(
            child: Text(
              '-',
              style: MyTextStyle(color: borderColor),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
