import 'package:flutter/material.dart';
import 'package:rPiInterface/appbars/expanded_appbar.dart';
import 'package:rPiInterface/bottom_navbar/destinations.dart';
import 'package:rPiInterface/pages/speed_annotation.dart';
import 'package:rPiInterface/states/acquisition_state.dart';
import 'package:rPiInterface/states/server_state.dart';
import 'package:rPiInterface/utils/models.dart';
import 'package:rPiInterface/utils/mqtt_wrapper.dart';
import 'package:rPiInterface/utils/plot_data.dart';

class DestinationView extends StatefulWidget {
  DestinationView({
    Key key,
    this.destination,
    this.macAddress1Notifier,
    this.dataMAC1Notifier,
    this.dataMAC2Notifier,
    this.channelsMAC1Notifier,
    this.channelsMAC2Notifier,
    this.sensorsMAC1Notifier,
    this.sensorsMAC2Notifier,
    this.mqttClientWrapper,
    this.acquisitionNotifier,
    this.batteryBit1Notifier,
    this.batteryBit2Notifier,
    this.patientNotifier,
    this.annotationTypesD,
    this.timedOut,
    this.startupError,
    this.connectionNotifier,
  }) : super(key: key);

  final Destination destination;
  ValueNotifier<String> macAddress1Notifier;

  ValueNotifier<List<List>> dataMAC1Notifier;
  ValueNotifier<List<List>> dataMAC2Notifier;
  ValueNotifier<List<List>> channelsMAC1Notifier;
  ValueNotifier<List<List>> channelsMAC2Notifier;
  ValueNotifier<List> sensorsMAC1Notifier;
  ValueNotifier<List> sensorsMAC2Notifier;

  MQTTClientWrapper mqttClientWrapper;

  ValueNotifier<String> acquisitionNotifier;

  ValueNotifier<double> batteryBit1Notifier;
  ValueNotifier<double> batteryBit2Notifier;

  ValueNotifier<String> patientNotifier;

  ValueNotifier<List> annotationTypesD;

  ValueNotifier<String> timedOut;
  ValueNotifier<bool> startupError;

  ValueNotifier<MqttCurrentConnectionState> connectionNotifier;

  @override
  _DestinationViewState createState() => _DestinationViewState();
}

class _DestinationViewState extends State<DestinationView> {
  List aux;

  final plotHeight = 160.0;

  ValueNotifier<bool> newAnnotation = ValueNotifier(false);

  ValueNotifier<List> data1 = ValueNotifier([]);
  ValueNotifier<List> data2 = ValueNotifier([]);
  ValueNotifier<List> data3 = ValueNotifier([]);
  ValueNotifier<List> data4 = ValueNotifier([]);
  ValueNotifier<List> data5 = ValueNotifier([]);
  ValueNotifier<List> data6 = ValueNotifier([]);

  List<List<double>> rangesList = List.filled(6, [-1, 10, 1]);
  bool _rangeInitiated;
  bool _isTimedOutOpen = false;
  var f;

  List<double> _getRangeFromSensor(sensor) {
    List<double> yRange;
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
      List<double> auxList = _getRangeFromSensor(sensorsMAC[i]);
      setState(() => rangesList[i] = auxList);
    }
    setState(() => _rangeInitiated = true);
  }

  bool _rangeUpdateNeeded(List data, List currentRange) {
    bool update = false;
    //List<double> dataL =  List<double>.from(data);
    //final stats = Stats.fromData(dataL).toJson();
    //final std = stats['standardDeviation'];
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

    //List<double> dataL =  List<double>.from(data);
    //final stats = Stats.fromData(dataL).toJson();
    //final std = stats['standardDeviation'];
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

  /* void _showSnackBar(String _message) {
    try {
      _scaffoldRealTime.currentState.showSnackBar(new SnackBar(
        content: new Text(_message),
        backgroundColor: Colors.blue,
      ));
    } catch (e) {
      print(e);
    }
  } */

  Future<void> _timedOutDialog(device) async {
    await Future.delayed(Duration.zero);
    if (!_isTimedOutOpen) {
      f = () {
        //print('I LISTENED');
        widget.destination.dataMACNotifier.removeListener(f);
        setState(() => _isTimedOutOpen = false);
        Navigator.of(context, rootNavigator: true).pop();
      };
      widget.destination.dataMACNotifier.addListener(f);
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
                      RaisedButton(
                        child: Text("OK"),
                        onPressed: () {
                          widget.destination.dataMACNotifier.removeListener(f);
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
                      RaisedButton(
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

    widget.destination.dataMACNotifier.addListener(() {
      if (this.mounted) {
        if (!_rangeInitiated &&
            widget.destination.sensorsMACNotifier.value.isNotEmpty) {
          _initRange(widget.destination.sensorsMACNotifier.value);
          //print('RANGE: $rangesList');
        }

        double canvasWidth = MediaQuery.of(context).size.width;

        widget.destination.dataMACNotifier.value
            .asMap()
            .forEach((index, channel) {
          if (index == 0) {
            List auxData = data1.value + channel;
            if (auxData.length > canvasWidth) {
              auxData = auxData.sublist(auxData.length - canvasWidth.floor());
            }
            setState(() => data1.value = auxData);
            if (rangesList[index][2] == 0) {
              aux = []..addAll(data1.value);
              aux.sort();
              if (_rangeUpdateNeeded(aux, rangesList[index].sublist(0, 2))) {
                setState(() => rangesList[index] =
                    _updateRange(aux, rangesList[index].sublist(0, 2)));
              }
            }
          } else if (index == 1) {
            List auxData = data2.value + channel;
            if (auxData.length > canvasWidth) {
              auxData = auxData.sublist(auxData.length - canvasWidth.floor());
            }
            setState(() => data2.value = auxData);
            if (rangesList[index][2] == 0) {
              aux = []..addAll(data2.value);
              aux.sort();
              if (_rangeUpdateNeeded(aux, rangesList[index].sublist(0, 2))) {
                setState(() => rangesList[index] =
                    _updateRange(aux, rangesList[index].sublist(0, 2)));
              }
            }
          } else if (index == 2) {
            List auxData = data3.value + channel;
            if (auxData.length > canvasWidth) {
              auxData = auxData.sublist(auxData.length - canvasWidth.floor());
            }
            setState(() => data3.value = auxData);
            if (rangesList[index][2] == 0) {
              aux = []..addAll(data3.value);
              aux.sort();
              if (_rangeUpdateNeeded(aux, rangesList[index].sublist(0, 2))) {
                setState(() => rangesList[index] =
                    _updateRange(aux, rangesList[index].sublist(0, 2)));
              }
            }
          } else if (index == 3) {
            List auxData = data4.value + channel;
            if (auxData.length > canvasWidth) {
              auxData = auxData.sublist(auxData.length - canvasWidth.floor());
            }
            setState(() => data4.value = auxData);
            if (rangesList[index][2] == 0) {
              aux = []..addAll(data4.value);
              aux.sort();
              if (_rangeUpdateNeeded(aux, rangesList[index].sublist(0, 2))) {
                setState(() => rangesList[index] =
                    _updateRange(aux, rangesList[index].sublist(0, 2)));
              }
            }
          } else if (index == 4) {
            List auxData = data5.value + channel;
            if (auxData.length > canvasWidth) {
              auxData = auxData.sublist(auxData.length - canvasWidth.floor());
            }
            setState(() => data5.value = auxData);
            if (rangesList[index][2] == 0) {
              aux = []..addAll(data5.value);
              aux.sort();
              if (_rangeUpdateNeeded(aux, rangesList[index].sublist(0, 2))) {
                setState(() => rangesList[index] =
                    _updateRange(aux, rangesList[index].sublist(0, 2)));
              }
            }
          } else if (index == 5) {
            List auxData = data6.value + channel;
            if (auxData.length > canvasWidth) {
              auxData = auxData.sublist(auxData.length - canvasWidth.floor());
            }
            setState(() => data6.value = auxData);
            if (rangesList[index][2] == 0) {
              aux = []..addAll(data6.value);
              aux.sort();
              if (_rangeUpdateNeeded(aux, rangesList[index].sublist(0, 2))) {
                setState(() => rangesList[index] =
                    _updateRange(aux, rangesList[index].sublist(0, 2)));
              }
            }
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ExpandedAppBar(
        title: '',
        text1: 'Servidor: ',
        state1: ServerState(connectionNotifier: widget.connectionNotifier),
        text2: 'Aquisição: ',
        state2:
            AcquisitionState(acquisitionNotifier: widget.acquisitionNotifier),
        batteryBit1Notifier: widget.batteryBit1Notifier,
        batteryBit2Notifier: widget.batteryBit2Notifier,
      ),
      //backgroundColor: widget.destination.color[100],
      body: Column(children: [
        Expanded(
          child: Container(
            width: MediaQuery.of(context).size.width - 15.0,
            child: ListView(
              children: <Widget>[
                SizedBox(height: 20),
                // ############### PLOT 1 ###############
                if (widget.destination.channelsMACNotifier.value.length > 0)
                  PlotDataTitle(
                      channels: widget.destination.channelsMACNotifier.value[0],
                      sensor: widget.destination.sensorsMACNotifier.value[0]),
                if (widget.destination.channelsMACNotifier.value.length > 0)
                  ValueListenableBuilder(
                      valueListenable: data1,
                      builder: (BuildContext context, List data, Widget child) {
                        return SizedBox(
                            height: plotHeight,
                            child: PlotData(
                                yRange: rangesList[0].sublist(0, 2),
                                data: data.map((s) => s as double).toList()));
                      }),
                // ############### PLOT 2 ###############
                if (widget.destination.channelsMACNotifier.value.length > 1)
                  PlotDataTitle(
                      channels: widget.destination.channelsMACNotifier.value[1],
                      sensor: widget.destination.sensorsMACNotifier.value[1]),
                if (widget.destination.channelsMACNotifier.value.length > 1)
                  ValueListenableBuilder(
                      valueListenable: data2,
                      builder: (BuildContext context, List data, Widget child) {
                        return SizedBox(
                            height: plotHeight,
                            child: PlotData(
                                yRange: rangesList[1].sublist(0, 2),
                                data: data.map((s) => s as double).toList()));
                      }),
                // ############### PLOT 3 ###############
                if (widget.destination.channelsMACNotifier.value.length > 2)
                  PlotDataTitle(
                      channels: widget.destination.channelsMACNotifier.value[2],
                      sensor: widget.destination.sensorsMACNotifier.value[2]),
                if (widget.destination.channelsMACNotifier.value.length > 2)
                  ValueListenableBuilder(
                      valueListenable: data3,
                      builder: (BuildContext context, List data, Widget child) {
                        return SizedBox(
                            height: plotHeight,
                            child: PlotData(
                                yRange: rangesList[2].sublist(0, 2),
                                data: data.map((s) => s as double).toList()));
                      }),
                // ############### PLOT 4 ###############
                if (widget.destination.channelsMACNotifier.value.length > 3)
                  PlotDataTitle(
                      channels: widget.destination.channelsMACNotifier.value[3],
                      sensor: widget.destination.sensorsMACNotifier.value[3]),
                if (widget.destination.channelsMACNotifier.value.length > 3)
                  ValueListenableBuilder(
                      valueListenable: data4,
                      builder: (BuildContext context, List data, Widget child) {
                        return SizedBox(
                            height: plotHeight,
                            child: PlotData(
                                yRange: rangesList[3].sublist(0, 2),
                                data: data.map((s) => s as double).toList()));
                      }),
                // ############### PLOT 5 ###############
                if (widget.destination.channelsMACNotifier.value.length > 4)
                  PlotDataTitle(
                      channels: widget.destination.channelsMACNotifier.value[4],
                      sensor: widget.destination.sensorsMACNotifier.value[4]),
                if (widget.destination.channelsMACNotifier.value.length > 4)
                  ValueListenableBuilder(
                      valueListenable: data5,
                      builder: (BuildContext context, List data, Widget child) {
                        return SizedBox(
                            height: plotHeight,
                            child: PlotData(
                                yRange: rangesList[4].sublist(0, 2),
                                data: data.map((s) => s as double).toList()));
                      }),
                // ############### PLOT 6 ###############
                if (widget.destination.channelsMACNotifier.value.length > 5)
                  PlotDataTitle(
                      channels: widget.destination.channelsMACNotifier.value[5],
                      sensor: widget.destination.sensorsMACNotifier.value[5]),
                if (widget.destination.channelsMACNotifier.value.length > 5)
                  ValueListenableBuilder(
                      valueListenable: data6,
                      builder: (BuildContext context, List data, Widget child) {
                        return SizedBox(
                            height: plotHeight,
                            child: PlotData(
                                yRange: rangesList[5].sublist(0, 2),
                                data: data.map((s) => s as double).toList()));
                      }),
                SizedBox(height: 53),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
