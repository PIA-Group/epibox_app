import 'package:epibox/classes/configurations.dart';
import 'package:epibox/classes/visualization.dart';
import 'package:epibox/decor/default_colors.dart';
import 'package:epibox/decor/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:epibox/utils/models.dart';
import 'package:epibox/utils/mqtt_wrapper.dart';
import 'package:epibox/utils/plot_data.dart';
import 'package:property_change_notifier/property_change_notifier.dart';

class DestinationView extends StatefulWidget {

  final Configurations configurations;
  final Visualization visualizationMAC;

  final MQTTClientWrapper mqttClientWrapper;

  final ValueNotifier<String> patientNotifier;

  final ValueNotifier<List> annotationTypesD;

  final ValueNotifier<String> timedOut;
  final ValueNotifier<bool> startupError;

  final ValueNotifier<MqttCurrentConnectionState> connectionNotifier;

  DestinationView({
    Key key,
    this.visualizationMAC,
    this.configurations,
    this.mqttClientWrapper,
    this.patientNotifier,
    this.annotationTypesD,
    this.timedOut,
    this.startupError,
    this.connectionNotifier,
  }) : super(key: key);

  @override
  _DestinationViewState createState() => _DestinationViewState();
}

class _DestinationViewState extends State<DestinationView> {
  List aux;

  final plotHeight = 160.0;

  ValueNotifier<bool> newAnnotation = ValueNotifier(false);

  bool _rangeInitiated;
  bool _isTimedOutOpen = false;
  var f;

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
      List<double> auxList;
      if (widget.configurations.saveRaw) {
        auxList = [-1, 10, 0];
      } else {
        auxList = _getRangeFromSensor(sensorsMAC[i]);
      }
      setState(() => widget.visualizationMAC.rangesList[i] = auxList);
    }
    setState(() => _rangeInitiated = true);
  }

  bool _rangeUpdateNeeded(List data, List currentRange) {
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

  Future<void> _timedOutDialog(device) async {
    await Future.delayed(Duration.zero);
    if (!_isTimedOutOpen) {
      f = () {
        //print('I LISTENED');
        widget.visualizationMAC.removeListener(f, ['dataMAC']);
        setState(() => _isTimedOutOpen = false);
        Navigator.of(context, rootNavigator: true).pop();
      };
      widget.visualizationMAC.addListener(f, ['dataMAC']);
    }
    /* if (_isTimedOutOpen) {
      Navigator.of(context, rootNavigator: true).pop();
    } */
    _isTimedOutOpen = true;
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Dificuldade em conectar',
            textAlign: TextAlign.start,
            style: MyTextStyle(
                color: DefaultColors.textColorOnLight, fontSize: 22),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(right: 15.0, left: 15.0),
                  child: Text(
                    'Está a ser difícil de conectar ao dispositivo de aquisição $device. Por favor desligue-o e volte a ligar.',
                    textAlign: TextAlign.justify,
                  ),
                ),
                ButtonBar(
                    alignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ElevatedButton(
                        child: Text("OK"),
                        onPressed: () {
                          widget.visualizationMAC
                              .removeListener(f, ['dataMAC']);
                          setState(() => _isTimedOutOpen = false);
                          Navigator.of(context, rootNavigator: true).pop();
                        },
                      ),
                    ]),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _startupErrorDialog() async {
    await Future.delayed(Duration.zero);
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Erro ao iniciar',
            textAlign: TextAlign.start,
            style: MyTextStyle(
                color: DefaultColors.textColorOnLight, fontSize: 22),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(right: 15.0, left: 15.0),
                  child: Text(
                    'Ocorreu um erro ao tentar iniciar a aquisição. Por favor desligue e ligue todos os dispositivos de aquisição e re-inicie o processo.',
                    textAlign: TextAlign.justify,
                  ),
                ),
                ButtonBar(
                    alignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ElevatedButton(
                        child: Text("OK"),
                        onPressed: () {
                          Navigator.of(context, rootNavigator: true).pop();
                        },
                      ),
                    ]),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    widget.startupError.addListener(() {
      if (widget.startupError.value) {
        _startupErrorDialog();
      }
    });

    widget.timedOut.addListener(() {
      //print(widget.timedOut.value);
      if (widget.timedOut.value != null) {
        _timedOutDialog(widget.timedOut.value);
      }
    });

    setState(() => _rangeInitiated = false);

    /* newAnnotation.addListener(() async {
      if (newAnnotation.value) {
        Future<Null>.delayed(Duration.zero, () {
          _showSnackBar('Anotação gravada!');
          setState(() => newAnnotation.value = false);
        });
      }
    }); */

    widget.visualizationMAC.addListener(() {
      if (this.mounted) {
        if (!_rangeInitiated && widget.visualizationMAC.sensorsMAC.isNotEmpty) {
          _initRange(widget.visualizationMAC.sensorsMAC);
        }

        double canvasWidth = MediaQuery.of(context).size.width;

        widget.visualizationMAC.dataMAC.asMap().forEach((index, channel) {
          List auxData = widget.visualizationMAC.data2Plot[index] + channel;
          if (auxData.length > canvasWidth) {
            auxData = auxData.sublist(auxData.length - canvasWidth.floor());
          }
          setState(() => widget.visualizationMAC.data2Plot[index] = auxData);
          if (widget.visualizationMAC.rangesList[index][2] == 0) {
            aux = []..addAll(widget.visualizationMAC.data2Plot[index]);
            aux.sort();
            if (_rangeUpdateNeeded(
                aux, widget.visualizationMAC.rangesList[index].sublist(0, 2))) {
              setState(() => widget.visualizationMAC.rangesList[index] =
                  _updateRange(aux,
                      widget.visualizationMAC.rangesList[index].sublist(0, 2)));
            }
          }
        });
      }
    }, ['dataMAC']);
  }

  @override
  Widget build(BuildContext context) {
    return PropertyChangeProvider(
      value: widget.visualizationMAC,
      child: Column(children: [
        Expanded(
          child: Container(
            width: MediaQuery.of(context).size.width - 15.0,
            child: PropertyChangeConsumer<Visualization>(
                properties: ['data2Plot'],
                builder: (context, visualization, properties) {
                  if (visualization.dataMAC.isEmpty) {
                    return Container();
                  } else {
                    return ListView(
                        children:
                            /* <Widget>[
                      SizedBox(height: 20), */

                            visualization.data2Plot
                                .mapIndexed((data, i) {
                                  if (data != [])
                                    return [
                                      PlotDataTitle(
                                          channels:
                                              visualization.channelsMAC[i],
                                          sensor: visualization.sensorsMAC[i]),
                                      _plot(data, visualization.rangesList[i]),
                                    ];
                                })
                                .expand((k) => k)
                                .toList()

                        /* 
                      SizedBox(height: 53),
                    ], */
                        );
                  }
                }),
          ),
        ),
      ]),
    );
  }

  Widget _plot(List data, List ranges) {
    return SizedBox(
        height: plotHeight,
        child: PlotData(
            yRange: ranges.sublist(0, 2),
            data: data.map((s) => s as double).toList()));
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
