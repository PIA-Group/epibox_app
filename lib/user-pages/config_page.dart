import 'package:epibox/app_localizations.dart';
import 'package:epibox/classes/configurations.dart';
import 'package:epibox/classes/devices.dart';
import 'package:epibox/classes/shared_pref.dart';
import 'package:epibox/classes/visualization.dart';
import 'package:epibox/decor/default_colors.dart';
import 'package:epibox/decor/text_styles.dart';
import 'package:epibox/mqtt/mqtt_states.dart';
import 'package:epibox/mqtt/mqtt_wrapper.dart';
import 'package:epibox/utils/tooltips.dart';
import 'package:flutter/material.dart';
import 'package:property_change_notifier/property_change_notifier.dart';
import 'package:epibox/utils/config.dart';

class ConfigPage extends StatefulWidget {
  /* This page allows the user to see the current default acquisition configurations 
  (sent by PyEpiBOX), as well as defining new default configurations. */

  final Devices devices;
  final Configurations configurations;
  final Visualization visualizationMAC1;
  final Visualization visualizationMAC2;
  final MQTTClientWrapper mqttClientWrapper;
  final ValueNotifier<MqttCurrentConnectionState> connectionNotifier;
  final ValueNotifier<List<String>> driveListNotifier;
  final ValueNotifier<String> patientNotifier;
  final Preferences preferences;

  ConfigPage({
    this.configurations,
    this.devices,
    this.visualizationMAC1,
    this.visualizationMAC2,
    this.mqttClientWrapper,
    this.connectionNotifier,
    this.driveListNotifier,
    this.patientNotifier,
    this.preferences,
  });

  @override
  _ConfigPageState createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  List<String> fsOptions = [' ', '1000', '100', '10', '1'];

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
        child: Text(value, textAlign: TextAlign.center),
      ),
    );
  }).toList();

  List<String> channelSensorItems = ['channels device', 'sensors device'];

  Map<String, Function> listeners = {
    'configDefault': null,
    'macAddress1': null,
    'macAddress2': null,
    'driveListNotifier': null,
  };

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

    listeners['configDefault'] = () {
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

      // Sampling frequency
      widget.configurations.controllerFreq.text =
          widget.configurations.configDefault['fs'].toString();

      // Save raw
      widget.configurations.saveRaw =
          widget.configurations.configDefault['save_raw'] == 'true';

      // Channels & sensors
      _getDefaultChannels(widget.configurations.configDefault);
      _getDefaultSensors(widget.configurations.configDefault['channels']);

      List<List> _channels =
          _getChannels(widget.configurations, widget.devices);

      widget.visualizationMAC1.channelsMAC = _channels[1][0];
      widget.visualizationMAC1.sensorsMAC = _channels[2][0];

      widget.visualizationMAC2.channelsMAC = _channels[1][1];
      widget.visualizationMAC2.sensorsMAC = _channels[2][1];
    };
    listeners['macAddress1'] = () {
      if (widget.devices.macAddress1 == '' ||
          widget.devices.macAddress1 == ' ') {
        widget.devices.isBit1Enabled = false;
      } else {
        widget.devices.isBit1Enabled = true;
      }
    };
    listeners['macAddress2'] = () {
      if (widget.devices.macAddress2 == '' ||
          widget.devices.macAddress2 == ' ') {
        widget.devices.isBit2Enabled = false;
      } else {
        widget.devices.isBit2Enabled = true;
      }
    };
    // update values upon receiving default configurations from PyEpiBOX
    widget.configurations
        .addListener(listeners['configDefault'], ['configDefault']);
    widget.devices.addListener(listeners['macAddress1'], ['macAddress1']);
    widget.devices.addListener(listeners['macAddress2'], ['macAddress2']);
    //widget.driveListNotifier.addListener(listeners['driveListNotifier']);
    widget.configurations.addListener(() {}, ['controllerFreq']);
  }

  List<List> _getChannels(Configurations configurations, Devices devices) {
    List<List<String>> _channels2Send = [];
    List<List<List<String>>> _channels2Save = [[], []];
    List<List<String>> _sensors2Save = [[], []];

    print('bit1: ${configurations.bit1Selections}');

    configurations.bit1Selections.asMap().forEach((channel, value) {
      if (value) {
        _channels2Send.add([
          "'${devices.macAddress1}'",
          "'${(channel + 1).toString()}'",
          "'${configurations.controllerSensors[channel].text}'"
        ]);
        _channels2Save[0]
            .add(["${devices.macAddress1}", "${(channel + 1).toString()}"]);
        _sensors2Save[0]
            .add("${configurations.controllerSensors[channel].text}");
      }
    });
    print(_channels2Send);
    configurations.bit2Selections.asMap().forEach((channel, value) {
      if (value) {
        _channels2Send.add([
          "'${devices.macAddress2}'",
          "'${(channel + 1).toString()}'",
          "'${configurations.controllerSensors[channel + 5].text}'"
        ]);
        _channels2Save[1]
            .add(["${devices.macAddress2}", "${(channel + 1).toString()}"]);
        _sensors2Save[1]
            .add("${configurations.controllerSensors[channel + 5].text}");
      }
    });
    return [_channels2Send, _channels2Save, _sensors2Save];
  }

  @override
  void dispose() {
    widget.configurations
        .removeListener(listeners['configDefault'], ['configDefault']);
    widget.devices.removeListener(listeners['macAddress1'], ['macAddress1']);
    widget.devices.removeListener(listeners['macAddress2'], ['macAddress2']);
    //widget.driveListNotifier.removeListener(listeners['driveListNotifier']);
    super.dispose();
  }

  void _getDefaultChannels(Map<String, dynamic> configDefault) {
    List<bool> _aux1Selections = List.generate(6, (_) => false);
    List<bool> _aux2Selections = List.generate(6, (_) => false);

    print('channels ${configDefault.isEmpty}');
    if (configDefault['channels'].isEmpty) {
      if (!configDefault['devices_mac']['MAC1'].isEmpty)
        _aux1Selections = List.generate(6, (_) => true);
      if (!configDefault['devices_mac']['MAC2'].isEmpty)
        _aux2Selections = List.generate(6, (_) => true);
    } else {
      configDefault['channels'].forEach((triplet) {
        if (triplet[0] == 'MAC1') {
          _aux1Selections[int.parse(triplet[1]) - 1] = true;
        }
        if (triplet[0] == 'MAC2') {
          _aux2Selections[int.parse(triplet[1]) - 1] = true;
        }
      });
    }
    widget.configurations.bit1Selections = _aux1Selections;
    widget.configurations.bit2Selections = _aux2Selections;
  }

  void _getDefaultSensors(List channels) {
    channels.forEach((triplet) {
      if (triplet[0] == 'MAC1') {
        widget.configurations.controllerSensors[int.parse(triplet[1]) - 1]
            .text = triplet[2];
      }
      if (triplet[0] == 'MAC2') {
        widget.configurations.controllerSensors[int.parse(triplet[1]) + 5]
            .text = triplet[2];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width -
        MediaQuery.of(context).viewInsets.left -
        MediaQuery.of(context).viewInsets.right;

    final height = MediaQuery.of(context).size.height -
        MediaQuery.of(context).viewInsets.top -
        MediaQuery.of(context).viewInsets.bottom;

    const double horizontalSpacing = 20.0;
    const double verticalSpacing = 10.0;
    const double verticalSpacingWithinGroup = 5.0;

    return PropertyChangeProvider(
      value: widget.configurations,
      child: PropertyChangeProvider(
        value: widget.devices,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalSpacing),
          child: ListView(
            key: Key('configListView'),
            shrinkWrap: true,
            children: <Widget>[
              DriveBlock(
                  driveListNotifier: widget.driveListNotifier,
                  height: height,
                  width: width,
                  verticalSpacing: verticalSpacing),
              SizedBox(height: verticalSpacing),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  child: Text(
                    AppLocalizations.of(context)
                        .translate('acquisition configurations')
                        .inCaps,
                    textAlign: TextAlign.left,
                    style: MyTextStyle(
                      color: DefaultColors.textColorOnLight,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: verticalSpacing),
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
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15.0),
                    child: ListView(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        children: [
                          FrequencyBlock(fsOptions: fsOptions),
                          SaveRawBlock(),
                          ListView(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            children: channelSensorItems
                                .asMap()
                                .keys
                                .map((int titleIndex) {
                                  return [1, 2]
                                      .map((int id) => [
                                            SizedBox(height: verticalSpacing),
                                            Text(
                                                '${AppLocalizations.of(context).translate(channelSensorItems[titleIndex]).inCaps} $id:',
                                                textAlign: TextAlign.start,
                                                style: MyTextStyle(
                                                    color: DefaultColors
                                                        .textColorOnLight)),
                                            SizedBox(
                                                height:
                                                    verticalSpacingWithinGroup),
                                            titleIndex == 0
                                                ? ChannelBlock(deviceID: id)
                                                : SensorBlock(
                                                    deviceID: id,
                                                    sensorItems: sensorItems,
                                                  ),
                                          ])
                                      .toList()
                                      .expand((i) => i)
                                      .toList();
                                })
                                .toList()
                                .expand((i) => i)
                                .toList(),
                          ),
                          SizedBox(height: verticalSpacing),
                        ]),
                  ),
                ),
              ),
              SizedBox(height: 10.0),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: DefaultColors.mainLColor, // background
                    //onPrimary: Colors.white, // foreground
                  ),
                  onPressed: () {
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
                    key: Key('defineNewDefault'),
                    style: MyTextStyle(),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

class DriveBlock extends StatelessWidget {
  /* Widget that displays the current default storage location, as well as 
  other available locations of EpiBOX Core; and allows the user to choose a 
  new default based on the available storage locations. */

  final ValueNotifier<List<String>> driveListNotifier;
  final double height, width, verticalSpacing;
  final configurationKey = GlobalKey<State<Tooltip>>();

  DriveBlock(
      {this.driveListNotifier, this.height, this.width, this.verticalSpacing});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Expanded(
          child: Text(
            AppLocalizations.of(context).translate('storage folder').inCaps,
            textAlign: TextAlign.left,
            style: MyTextStyle(
              color: DefaultColors.textColorOnLight,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        CustomTooltip(
          message: AppLocalizations.of(context)
                  .translate("in case you are")
                  .inCaps +
              ' ' +
              AppLocalizations.of(context)
                  .translate("connected to the server") +
              ' ' +
              AppLocalizations.of(context).translate(
                  "but there are no options in the storage folder, restart") +
              '.',
          tooltipKey: configurationKey,
        ),
      ]),
      SizedBox(height: verticalSpacing),
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
              BoxShadow(color: Colors.grey[200], offset: new Offset(5.0, 5.0))
            ],
          ),
          child: ListView(
            physics: NeverScrollableScrollPhysics(),
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.0),
                child: PropertyChangeConsumer<Configurations>(
                    properties: ['chosenDrive'],
                    builder: (context, configurations, properties) {
                      print('drivelist: ${driveListNotifier.value}');
                      print(configurations.chosenDrive);
                      return ValueListenableBuilder(
                          valueListenable: driveListNotifier,
                          builder: (context, driveList, child) {
                            return DropdownButton(
                              key: Key('driveDropdown'),
                              value: configurations.chosenDrive,
                              items: driveList.map<DropdownMenuItem<String>>(
                                  (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    key: Key(value.split(' (')[0]),
                                    style: MyTextStyle(
                                        color: DefaultColors.textColorOnLight),
                                  ),
                                );
                              }).toList(),
                              onChanged: (newDrive) =>
                                  configurations.chosenDrive = newDrive,
                            );
                          });
                    }),
              ),
            ],
          ),
        ),
      ),
    ]);
  }
}

class FrequencyBlock extends StatelessWidget {
  /* Widget that displays the current default sampling frequency, as well as 
  other available sampling frequencies; and allows the user to choose a 
  new default based on the available options. */

  final List<String> fsOptions;

  FrequencyBlock({this.fsOptions});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          AppLocalizations.of(context).translate('sampling freq.').inCaps +
              ' [Hz]:',
          style: MyTextStyle(color: DefaultColors.textColorOnLight),
        ),
        Expanded(
          child: Container(
            margin: EdgeInsets.only(left: 20.0, right: 10.0),
            child: PropertyChangeConsumer<Configurations>(
                properties: ['controllerFreq'],
                builder: (context, configurations, properties) {
                  return DropdownButton(
                    key: Key('fsDropdown'),
                    value: configurations.controllerFreq.text,
                    items:
                        fsOptions.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: MyTextStyle(
                              color: DefaultColors.textColorOnLight),
                        ),
                      );
                    }).toList(),
                    onChanged: (fs) => configurations.controllerFreq =
                        TextEditingController(text: fs),
                  );
                }),
          ),
        ),
      ],
    );
  }
}

class SaveRawBlock extends StatelessWidget {
  /* Widget that displays the current default option on saving the data raw 
  (digital values) or performing a transformation to physical units. */

  SaveRawBlock();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
            AppLocalizations.of(context).translate('save data raw').inCaps +
                '?',
            style: MyTextStyle(color: DefaultColors.textColorOnLight)),
        PropertyChangeConsumer<Configurations>(
            properties: ['saveRaw'],
            builder: (context, configurations, properties) {
              return Checkbox(
                value: configurations.saveRaw,
                onChanged: (bool value) {
                  configurations.saveRaw = value;
                },
              );
            })
      ],
    );
  }
}

class ChannelBlock extends StatelessWidget {
  /* Widget that displays the current default analog channels for acquisition; 
  and allows the user to choose a new default. */

  final int deviceID;

  ChannelBlock({this.deviceID});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      PropertyChangeConsumer<Configurations>(
          properties: ['bit${deviceID}Selections'],
          builder: (context, configurations, properties) {
            return PropertyChangeConsumer<Devices>(
                properties: ['isBit${deviceID}Enabled'],
                builder: (context, devices, properties) {
                  return ToggleButtons(
                    key: Key('channels${deviceID}Toggle'),
                    constraints: BoxConstraints(
                        maxHeight: 25.0,
                        minHeight: 25.0,
                        maxWidth: 40.0,
                        minWidth: 40.0),
                    borderRadius: BorderRadius.all(Radius.circular(25)),
                    renderBorder: true,
                    children: <Widget>[
                      Text('A1'),
                      Text('A2'),
                      Text('A3'),
                      Text('A4'),
                      Text('A5'),
                      Text('A6'),
                    ],
                    isSelected: configurations.get('bit${deviceID}Selections'),
                    onPressed: devices.get('isBit${deviceID}Enabled')
                        ? (int index) {
                            List<bool> auxList = List.from(
                                configurations.get('bit${deviceID}Selections'));
                            auxList[index] = !auxList[index];
                            deviceID == 1
                                ? configurations.bit1Selections = auxList
                                : configurations.bit2Selections = auxList;
                          }
                        : null,
                  );
                });
          }),
    ]);
  }
}

class SensorBlock extends StatelessWidget {
  /* Widget that displays the current default analog channels for acquisition; 
  and allows the user to choose a new default. */

  final int deviceID;
  final List<DropdownMenuItem<String>> sensorItems;

  SensorBlock({this.deviceID, this.sensorItems});

  @override
  Widget build(BuildContext context) {
    List<String> _sensorContainerPositions = [
      'cornerL',
      'secondL',
      'middle',
      'middle',
      'middle',
      'cornerR'
    ];

    return PropertyChangeConsumer<Devices>(
        properties: ['isBit${deviceID}Enabled'],
        builder: (context, devices, properties) {
          return PropertyChangeConsumer<Configurations>(
              properties: ['controllerSensors'],
              builder: (context, configurations, properties) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _sensorContainerPositions.asMap().keys.map((i) {
                    return SensorContainer(
                      configurations: configurations,
                      index: i + 6 * (deviceID - 1),
                      sensorItems: sensorItems,
                      position: _sensorContainerPositions[i],
                      isBitEnabled: devices.get('isBit${deviceID}Enabled'),
                    );
                  }).toList(),
                );
              });
        });
  }
}

class SensorContainer extends StatelessWidget {
  //final TextEditingController controller;
  final Configurations configurations;
  final int index;
  final List<DropdownMenuItem<String>> sensorItems;
  final String position;
  final bool isBitEnabled;

  SensorContainer(
      {this.configurations,
      this.index,
      this.sensorItems,
      this.position,
      this.isBitEnabled});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width -
        MediaQuery.of(context).viewInsets.left -
        MediaQuery.of(context).viewInsets.right;

    Color borderColor = Colors.grey[350];

    return Container(
      width: (width * 0.85 - 2 * 30.0) / 6,
      decoration: (position == 'cornerL')
          ? BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  bottomLeft: Radius.circular(25)),
              border: Border.all(color: borderColor),
            )
          : (position == 'cornerR')
              ? BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(25),
                      bottomRight: Radius.circular(25)),
                  border: Border.all(color: borderColor),
                )
              : (position == 'secondL')
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
          value: configurations.controllerSensors[index].text,
          items: sensorItems,
          onChanged: isBitEnabled
              ? (sensor) {
                  List auxList = List.from(configurations.controllerSensors);
                  auxList[index] = TextEditingController(text: sensor);
                  configurations.controllerSensors = List.from(auxList);
                }
              : null,
          isDense: true,
          isExpanded: true,
          style: MyTextStyle(
              color:
                  isBitEnabled ? DefaultColors.textColorOnLight : borderColor),
        ),
      ),
    );
  }
}
