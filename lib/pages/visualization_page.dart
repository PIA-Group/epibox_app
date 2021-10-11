import 'dart:async';
import 'dart:math';

import 'package:epibox/classes/acquisition.dart';
import 'package:epibox/classes/configurations.dart';
import 'package:epibox/classes/visualization.dart';
import 'package:epibox/decor/default_colors.dart';
import 'package:epibox/decor/text_styles.dart';
import 'package:epibox/utils/oscilloscope.dart';
import 'package:flutter/material.dart';
import 'package:epibox/mqtt/mqtt_states.dart';
import 'package:epibox/mqtt/mqtt_wrapper.dart';
import 'package:property_change_notifier/property_change_notifier.dart';

class VisualizationPage extends StatefulWidget {
  final Configurations configurations;
  final Visualization visualizationMAC;
  final Acquisition acquisition;

  final MQTTClientWrapper mqttClientWrapper;

  final ValueNotifier<String> patientNotifier;

  final ValueNotifier<List> annotationTypesD;

  final ValueNotifier<String> timedOut;
  final ValueNotifier<bool> startupError;

  final ValueNotifier<MqttCurrentConnectionState> connectionNotifier;

  VisualizationPage({
    Key key,
    this.visualizationMAC,
    this.acquisition,
    this.configurations,
    this.mqttClientWrapper,
    this.patientNotifier,
    this.annotationTypesD,
    this.timedOut,
    this.startupError,
    this.connectionNotifier,
  }) : super(key: key);

  @override
  _VisualizationPageState createState() => _VisualizationPageState();
}

class _VisualizationPageState extends State<VisualizationPage> {
  List<List<double>> bufferData = [];

  final plotHeight = 160.0;
  int buffer = 100;
  Timer _timer;

  bool _rangeInitiated = false;

  int secondsSinceStart = 0;
  DateTime startTime;
  double screenWidth;

  Map<String, Function> listeners = {
    'startupError': null,
    'timedOut': null,
    'dataMAC': null,
  };

  @override
  void initState() {
    super.initState();

    listeners['dataMAC'] = () {
      if (this.mounted) {
        if (!_rangeInitiated && widget.visualizationMAC.sensorsMAC.isNotEmpty) {
          _initRange(widget.visualizationMAC.sensorsMAC);
          screenWidth = MediaQuery.of(context).size.width;
          startTimer();
        }

        List<List<double>> auxListData =
            List.filled(widget.visualizationMAC.dataMAC.length, []);
        List<List<int>> auxListEvents =
            List.filled(widget.visualizationMAC.dataMAC.length, []);

        widget.visualizationMAC.dataMAC.asMap().forEach((index, newSamples) {
          List<double> auxData;
          List<int> auxEvents;

          if (widget.visualizationMAC.data2Plot.isEmpty) {
            widget.visualizationMAC.data2Plot =
                List.filled(widget.visualizationMAC.dataMAC.length, []);

            auxData = newSamples.map((d) => d as double).toList();
            print('aux data len: ${auxData.length}');
          } else {
            auxData = widget.visualizationMAC.data2Plot[index] +
                newSamples.map((d) => d as double).toList();
            print('aux data len: ${auxData.length}');
          }

          if (widget.visualizationMAC.events2Paint.isEmpty) {
            widget.visualizationMAC.events2Paint =
                List.filled(widget.visualizationMAC.dataMAC.length, []);
            print('annotateCanvas: ${widget.visualizationMAC.annotateCanvas}');
            auxEvents = List.filled(
                widget.visualizationMAC.dataMAC[index].length,
                widget.visualizationMAC.annotateCanvas[index]);
          } else {
            auxEvents = widget.visualizationMAC.events2Paint[index] +
                List.filled(widget.visualizationMAC.dataMAC[index].length,
                    widget.visualizationMAC.annotateCanvas[index]);
          }

          if (auxData.length > screenWidth) {
            int start = min(buffer, auxData.length - screenWidth.floor());
            auxListData[index] = auxData.sublist(start);
            print('auxListData len: ${auxListData[0].length}');
            auxListEvents[index] = auxEvents.sublist(start);
          } else {
            auxListData[index] = auxData;
            print('auxListData len: ${auxListData[0].length}');
            auxListEvents[index] = auxEvents;
          }

          if (widget.visualizationMAC.rangesList[index][2] == 0) {
            List<double> aux = []..addAll(auxListData[index]);
            aux.sort();
            if (_rangeUpdateNeeded(
                aux, widget.visualizationMAC.rangesList[index].sublist(0, 2))) {
              List auxListRanges =
                  List.from(widget.visualizationMAC.rangesList);

              auxListRanges[index] = _updateRange(
                  aux, widget.visualizationMAC.rangesList[index].sublist(0, 2));
              widget.visualizationMAC.rangesList = List.from(auxListRanges);
            }
          }
        });
        widget.visualizationMAC.data2Plot = List.from(auxListData);
        widget.visualizationMAC.events2Paint = List.from(auxListEvents);
      }
    };

    widget.startupError.addListener(listeners['startupError']);
    widget.timedOut.addListener(listeners['timedOut']);
    widget.visualizationMAC.addListener(listeners['dataMAC'], ['dataMAC']);
  }

  @override
  void dispose() {
    widget.startupError.removeListener(listeners['startupError']);
    widget.timedOut.removeListener(listeners['timedOut']);
    widget.visualizationMAC.removeListener(listeners['dataMAC'], ['dataMAC']);
    if (_timer != null) _timer.cancel();
    super.dispose();
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(milliseconds: 16), (Timer timer) {
      if (widget.visualizationMAC.data2Plot.isNotEmpty &&
          widget.acquisition.acquisitionState == 'acquiring') {
        // widget.visualizationMAC.data2Plot.asMap().forEach((index, newSamples) {
        //   if (newSamples.length > screenWidth) {
        //     // int start = min(buffer, newSamples.length - screenWidth.floor());
        //     // widget.visualizationMAC.data2Plot[index] =
        //     //     newSamples.sublist(start);
        //     // widget.visualizationMAC.events2Paint[index] =
        //     //     widget.visualizationMAC.events2Paint[index].sublist(start);
        //   }
        // });

        widget.visualizationMAC.refresh = true;
        print('data2plot len: ${widget.visualizationMAC.data2Plot.length}');
      }
      print(
          'number of 1: ${widget.visualizationMAC.events2Paint[0].where((element) => element == 1).length}');
    });
  }

  List<double> _getRangeFromSensor(sensor) {
    List<double> yRange;
    // the last value sets if the range should be updated throughout the acquisition
    if (sensor == 'ECG') {
      yRange = [-1.5, 1.5, 1];
    } else if (sensor == 'EEG') {
      yRange = [-39.49, 39.49, 1];
    } else if (sensor == 'PZT') {
      yRange = [-50, 50, 1];
    } else if (sensor == 'EDA') {
      yRange = [0, 25, 1];
    } else if (sensor == 'EOG') {
      yRange = [-0.81, 0.81, 1];
    } else if (sensor == 'EMG') {
      yRange = [-1.64, 1.64, 1];
    } else {
      yRange = [-1, 10, 0];
    }
    return yRange;
  }

  void _initRange(sensorsMAC) {
    for (int i = 0; i < sensorsMAC.length; i++) {
      List<double> auxRangesList;
      if (widget.configurations.saveRaw) {
        auxRangesList = [-1, 10, 0];
      } else {
        auxRangesList = _getRangeFromSensor(sensorsMAC[i]);
      }
      //setState(() => widget.visualizationMAC.rangesList[i] = auxRangesList);
      List<List<double>> auxList =
          List.from(widget.visualizationMAC.rangesList);
      auxList[i] = auxRangesList;
      widget.visualizationMAC.rangesList = List.from(auxList);
    }
    _rangeInitiated = true;
  }

  bool _rangeUpdateNeeded(List<double> data, List<double> currentRange) {
    bool update = false;
    int std = 5;
    if (data.first < currentRange[0] ||
        currentRange[0] < data.first - 3 * std) {
      update = true;
    }
    if (data.last > currentRange[1] || currentRange[1] > data.last + 3 * std) {
      update = true;
    }
    return update;
  }

  List<double> _updateRange(List data, List currentRange) {
    double min;
    double max;
    int std = 5;

    if (data.first < currentRange[0] || currentRange[0] < data.first - std) {
      min = (data.first - std).floor().toDouble();
    } else {
      min = currentRange[0];
    }
    if (data.last > currentRange[1] || currentRange[1] > data.last + std) {
      max = (data.last + std).ceil().toDouble();
    } else {
      max = currentRange[1];
    }
    return [min, max, 0];
  }

  @override
  Widget build(BuildContext context) {
    print('rebuilding VisualizationPage');
    return PropertyChangeProvider(
      value: widget.visualizationMAC,
      child: ListView(
          shrinkWrap: true,
          key: Key('visualizationListView'),
          children: [
            PropertyChangeConsumer<Visualization>(
                properties: ['refresh'],
                builder: (context, visualization, properties) {
                  if (visualization.dataMAC.isEmpty) {
                    return Container();
                  } else {
                    return Column(
                        children: visualization.data2Plot
                            .mapIndexed((data, i) {
                              if (data.isNotEmpty) {
                                return [
                                  PlotDataTitle(
                                      channels: visualization.channelsMAC[i],
                                      sensor: visualization.sensorsMAC[i]),
                                  PlotData(
                                    data: data,
                                    yRange: visualization.rangesList[i]
                                        .sublist(0, 2),
                                    plotHeight: plotHeight,
                                    startTime: startTime,
                                    secondsSinceStart: secondsSinceStart,
                                    configurations: widget.configurations,
                                    events2annotate:
                                        visualization.events2Paint[i],
                                  )
                                ];
                              }
                            })
                            .expand((k) => k)
                            .toList());
                  }
                }),
            SizedBox(height: 40.0),
          ]),
    );
  }
}

class PlotData extends StatelessWidget {
  final List<double> yRange;
  final List<double> data;
  final double plotHeight;
  final DateTime startTime;
  final int secondsSinceStart;
  final Configurations configurations;
  final List<int> events2annotate;

  PlotData({
    this.yRange,
    this.data,
    this.plotHeight,
    this.startTime,
    this.secondsSinceStart,
    this.configurations,
    this.events2annotate,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: plotHeight,
      child: Container(
        height: double.infinity,
        child: Padding(
          padding: EdgeInsets.only(bottom: 20.0),
          child: Row(children: [
            Padding(
              padding: EdgeInsets.only(left: 5.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${yRange[1].ceil()}'),
                  Text('${yRange[0].floor()}')
                ],
              ),
            ),
            Expanded(
              child: Oscilloscope(
                yAxisMax: yRange[1],
                yAxisMin: yRange[0],
                dataSet: data,
                events2annotate: events2annotate,
              ),
            )
          ]),
        ),
      ),
    );
  }
}

class PlotDataTitle extends StatelessWidget {
  final List channels;
  final String sensor;

  PlotDataTitle({
    this.channels,
    this.sensor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Canal: A${channels[1]} | $sensor',
        style: MyTextStyle(
            fontWeight: FontWeight.bold, color: DefaultColors.textColorOnLight),
      ),
    );
  }
}

extension ExtendedIterable<E> on Iterable<E> {
  /// Like Iterable<T>.map but callback have index as second argument
  Iterable<T> mapIndexed<T>(T Function(E e, int i) f) {
    var i = 0;
    return map((e) => f(e, i++));
  }

  void forEachIndexed(void Function(E e, int i) f) {
    var i = 0;
    forEach((e) => f(e, i++));
  }
}
