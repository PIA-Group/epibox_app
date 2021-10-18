import 'dart:async';
import 'dart:math';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:charts_flutter/flutter.dart';
import 'package:epibox/classes/acquisition.dart';
import 'package:epibox/classes/configurations.dart';
import 'package:epibox/classes/visualization.dart';
import 'package:epibox/decor/default_colors.dart';
import 'package:epibox/decor/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:epibox/mqtt/mqtt_states.dart';
import 'package:epibox/mqtt/mqtt_wrapper.dart';
import 'package:property_change_notifier/property_change_notifier.dart';
import 'package:intl/intl.dart';

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
  final plotHeight = 200.0;
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
        if (!_rangeInitiated && widget.visualizationMAC.dataMAC.isNotEmpty) {
          //screenWidth = MediaQuery.of(context).size.width;
          screenWidth = 330;
          startTimer();
          _rangeInitiated = true;
        }

        List<List<double>> auxListData =
            List.filled(widget.visualizationMAC.dataMAC.length, []);

        widget.visualizationMAC.dataMAC.asMap().forEach((index, newSamples) {
          List<double> auxData;

          if (widget.visualizationMAC.data2Plot.isEmpty) {
            widget.visualizationMAC.data2Plot =
                List.filled(widget.visualizationMAC.dataMAC.length, []);

            auxData = newSamples.map((d) => d as double).toList();
          } else {
            auxData = widget.visualizationMAC.data2Plot[index] +
                newSamples.map((d) => d as double).toList();
          }

          if (auxData.length > screenWidth) {
            int start = min(buffer, auxData.length - screenWidth.floor());
            auxListData[index] = auxData.sublist(start);
          } else {
            auxListData[index] = auxData;
          }
        });
        widget.visualizationMAC.data2Plot = List.from(auxListData);
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
        widget.visualizationMAC.refresh = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
                                    plotHeight: plotHeight,
                                    configurations: widget.configurations,
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
  final List<double> data;
  final double plotHeight;
  final Configurations configurations;

  PlotData({
    this.data,
    this.plotHeight,
    this.configurations,
  });

  @override
  Widget build(BuildContext context) {
    List<charts.Series<AcquiredSample, DateTime>> series =
        data2Series(data, configurations);

    // Future.delayed(Duration.zero).then((value) {
    //   print('width: ${_plotKey.currentContext.size.width}');
    // });

    return SizedBox(
      height: plotHeight,
      child: Container(
        height: double.infinity,
        child: Padding(
          padding: EdgeInsets.only(bottom: 20.0),
          child: charts.TimeSeriesChart(
            series,
            animate: false,
            behaviors: [charts.PanAndZoomBehavior()],
            domainAxis: DateTimeAxisSpec(
              showAxisLine: true,
              tickProviderSpec: const DateTimeEndPointsTickProviderSpec(),
              tickFormatterSpec: BasicDateTimeTickFormatterSpec.fromDateFormat(
                  DateFormat.Hms()),
            ),
          ),
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

List<charts.Series<AcquiredSample, DateTime>> data2Series(
    List<double> data, Configurations configurations) {
  List<int> aux = List<int>.generate(data.length, (i) => i + 1);
  DateTime now = DateTime.now();

  List<AcquiredSample> listSamples = aux
      .map(
        (i) => AcquiredSample(
            now.add(Duration(
                    milliseconds:
                        // ((1 / int.parse(configurations.controllerFreq.text)) *
                        //         1000)
                        //     .floor()) *
                        ((1 / 1000) * 1000).floor()) *
                (i - 1)),
            data[i - 1]),
      )
      .toList();

  return [
    new charts.Series<AcquiredSample, DateTime>(
      id: 'Samples',
      colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
      domainFn: (AcquiredSample sample, _) => sample.timestamp,
      measureFn: (AcquiredSample sample, _) => sample.sample,
      data: listSamples,
    )
  ];
}

class AcquiredSample {
  final DateTime timestamp;
  final double sample;

  AcquiredSample(this.timestamp, this.sample);
}
