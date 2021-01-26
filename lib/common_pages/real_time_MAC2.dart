import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:rPiInterface/hospital_pages/speed_annotation.dart';
import 'package:rPiInterface/utils/models.dart';
import 'package:rPiInterface/utils/mqtt_wrapper.dart';
import 'package:rPiInterface/utils/plot_data.dart';
import 'package:rPiInterface/utils/battery_indicator.dart';
import 'package:rPiInterface/common_pages/real_time_MAC1.dart';

class RealtimePageMAC2 extends StatefulWidget {
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

  RealtimePageMAC2({
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
    this.connectionNotifier,
    this.timedOut,
    this.startupError,
  });

  @override
  _RealtimePageMAC2State createState() => _RealtimePageMAC2State();
}

class _RealtimePageMAC2State extends State<RealtimePageMAC2> {
  final GlobalKey<ScaffoldState> _scaffoldRealTime =
      new GlobalKey<ScaffoldState>();
  List aux;
  //final firestoreInstance = Firestore.instance;

  final plotHeight = 120.0;

  ValueNotifier<bool> newAnnotation = ValueNotifier(false);

  ValueNotifier<List<double>> data1 = ValueNotifier([]);
  ValueNotifier<List<double>> data2 = ValueNotifier([]);
  ValueNotifier<List<double>> data3 = ValueNotifier([]);
  ValueNotifier<List<double>> data4 = ValueNotifier([]);
  ValueNotifier<List<double>> data5 = ValueNotifier([]);
  ValueNotifier<List<double>> data6 = ValueNotifier([]);

  List<List> dataMAC = [];
  List<List> channelsMAC = [];
  List<String> sensorsMAC = [];

  List<List<double>> rangesList = List.filled(6, [-1, 10, 1]);
  bool _rangeInitiated;
  bool _isTimedOutOpen = false;
  var f;

  void _stopAcquisition() {
    widget.mqttClientWrapper.publishMessage("['INTERRUPT']");
  }

  Future<void> _speedAnnotation() async {
    //List annotationTypesD = await getAnnotationTypes();
    List<String> annotationTypes =
        List<String>.from(widget.annotationTypesD.value);
    //print(annotationTypes);
    Navigator.of(context).push(new MaterialPageRoute<Null>(
        builder: (BuildContext context) {
          return SpeedAnnotationDialog(
            annotationTypesD: widget.annotationTypesD,
            annotationTypes: annotationTypes,
            patientNotifier: widget.patientNotifier,
            newAnnotation: newAnnotation,
            mqttClientWrapper: widget.mqttClientWrapper,
          );
        },
        fullscreenDialog: true));
  }

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

  void _showSnackBar(String _message) {
    try {
      _scaffoldRealTime.currentState.showSnackBar(new SnackBar(
        content: new Text(_message),
        backgroundColor: Colors.blue,
      ));
    } catch (e) {
      print(e);
    }
  }

  Future<void> _timedOutDialog(device) async {
    await Future.delayed(Duration.zero);
    if (!_isTimedOutOpen) {
      f = () {
        //print('I LISTENED');
        widget.dataMAC2Notifier.removeListener(f);
        setState(() => _isTimedOutOpen = false);
        Navigator.of(context, rootNavigator: true).pop();
      };
      widget.dataMAC2Notifier.addListener(f);
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
                          widget.dataMAC2Notifier.removeListener(f);
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

    newAnnotation.addListener(() async {
      if (newAnnotation.value) {
        Future<Null>.delayed(Duration.zero, () {
          _showSnackBar('Anotação gravada!');
          setState(() => newAnnotation.value = false);
        });
      }
    });

    widget.dataMAC2Notifier.addListener(() {
      if (this.mounted) {
        if (!_rangeInitiated && widget.sensorsMAC2Notifier.value.isNotEmpty) {
          _initRange(widget.sensorsMAC2Notifier.value);
          //print('RANGE: $rangesList');
        }

        double canvasWidth = MediaQuery.of(context).size.width;
        widget.dataMAC2Notifier.value.asMap().forEach((index, channel) {
          channel.asMap().forEach((i, value) {
            if (index == 0) {
              setState(() => data1.value.add(value));
              if (data1.value.length > canvasWidth) {
                data1.value.removeAt(0);
              }
              if (rangesList[index][2] == 0) {
                aux = []..addAll(data1.value);
                aux.sort();
                if (_rangeUpdateNeeded(aux, rangesList[index].sublist(0, 2))) {
                  setState(() => rangesList[index] =
                      _updateRange(aux, rangesList[index].sublist(0, 2)));
                }
              }
            } else if (index == 1) {
              setState(() => data2.value.add(value));
              if (data2.value.length > canvasWidth) {
                data2.value.removeAt(0);
              }
              if (rangesList[index][2] == 0) {
                aux = []..addAll(data2.value);
                aux.sort();
                if (_rangeUpdateNeeded(aux, rangesList[index].sublist(0, 2))) {
                  setState(() => rangesList[index] =
                      _updateRange(aux, rangesList[index].sublist(0, 2)));
                }
              }
            } else if (index == 2) {
              setState(() => data3.value.add(value));
              if (data3.value.length > canvasWidth) {
                data3.value.removeAt(0);
              }
              if (rangesList[index][2] == 0) {
                aux = []..addAll(data3.value);
                aux.sort();
                if (_rangeUpdateNeeded(aux, rangesList[index].sublist(0, 2))) {
                  setState(() => rangesList[index] =
                      _updateRange(aux, rangesList[index].sublist(0, 2)));
                }
              }
            } else if (index == 3) {
              setState(() => data4.value.add(value));
              if (data4.value.length > canvasWidth) {
                data4.value.removeAt(0);
              }
              if (rangesList[index][2] == 0) {
                aux = []..addAll(data4.value);
                aux.sort();
                if (_rangeUpdateNeeded(aux, rangesList[index].sublist(0, 2))) {
                  setState(() => rangesList[index] =
                      _updateRange(aux, rangesList[index].sublist(0, 2)));
                }
              }
            } else if (index == 4) {
              setState(() => data5.value.add(value));
              if (data5.value.length > canvasWidth) {
                data5.value.removeAt(0);
              }
              if (rangesList[index][2] == 0) {
                aux = []..addAll(data5.value);
                aux.sort();
                if (_rangeUpdateNeeded(aux, rangesList[index].sublist(0, 2))) {
                  setState(() => rangesList[index] =
                      _updateRange(aux, rangesList[index].sublist(0, 2)));
                }
              }
            } else if (index == 5) {
              setState(() => data6.value.add(value));
              if (data6.value.length > canvasWidth) {
                data6.value.removeAt(0);
              }
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
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    //double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      key: _scaffoldRealTime,
      appBar: new AppBar(
        title: new Text('MAC2'),
        actions: [
          Column(children: [
            ValueListenableBuilder(
              valueListenable: widget.batteryBit1Notifier,
              builder: (BuildContext context, double battery, Widget child) {
                return battery != null
                    ? Row(children: [
                        Text('MAC 1: ',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13)),
                        SizedBox(
                          width: 50.0,
                          height: 27.0,
                          child: new Center(
                            child: BatteryIndicator(
                              style: BatteryIndicatorStyle.skeumorphism,
                              batteryLevel: battery,
                            ),
                          ),
                        ),
                      ])
                    : SizedBox.shrink();
              },
            ),
            ValueListenableBuilder(
              valueListenable: widget.batteryBit2Notifier,
              builder: (BuildContext context, double battery, Widget child) {
                return battery != null
                    ? Row(children: [
                        Text('MAC 2: ',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13)),
                        SizedBox(
                          width: 50.0,
                          height: 27.0,
                          child: new Center(
                            child: BatteryIndicator(
                              style: BatteryIndicatorStyle.skeumorphism,
                              batteryLevel: battery,
                              //showPercentSlide: _showPercentSlide,
                            ),
                          ),
                        ),
                      ])
                    : SizedBox.shrink();
              },
            ),
          ]),
        ],
      ),
      body: Column(children: [
        ValueListenableBuilder(
            valueListenable: widget.connectionNotifier,
            builder: (BuildContext context, MqttCurrentConnectionState state,
                Widget child) {
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
            valueListenable: widget.acquisitionNotifier,
            builder: (BuildContext context, String state, Widget child) {
              return Container(
                height: 20,
                color: state == 'acquiring'
                    ? Colors.green[50]
                    : (state == 'starting' ||
                            state == 'reconnecting' ||
                            state == 'trying')
                        ? Colors.yellow[50]
                        : Colors.red[50],
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    child: Text(
                      state == 'starting'
                          ? 'A iniciar aquisição ...'
                          : state == 'acquiring'
                              ? 'A adquirir dados'
                              : state == 'reconnecting'
                                  ? 'A retomar aquisição ...'
                                  : state == 'trying'
                                      ? 'A reconectar aos dispositivos ...'
                                      : state == 'stopped'
                                          ? 'Aquisição terminada e dados gravados'
                                          : 'Aquisição desligada',
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
        Expanded(
          child: Row(children: [
            Expanded(
              child: FlatButton(
                padding: EdgeInsets.zero,
                textColor: Colors.black,
                color: Colors.grey[300],
                height: MediaQuery.of(context).size.height,
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return RealtimePageMAC1(
                        dataMAC1Notifier: widget.dataMAC1Notifier,
                        dataMAC2Notifier: widget.dataMAC2Notifier,
                        channelsMAC1Notifier: widget.channelsMAC1Notifier,
                        channelsMAC2Notifier: widget.channelsMAC2Notifier,
                        sensorsMAC1Notifier: widget.sensorsMAC1Notifier,
                        sensorsMAC2Notifier: widget.sensorsMAC2Notifier,
                        mqttClientWrapper: widget.mqttClientWrapper,
                        acquisitionNotifier: widget.acquisitionNotifier,
                        batteryBit1Notifier: widget.batteryBit1Notifier,
                        batteryBit2Notifier: widget.batteryBit2Notifier,
                        patientNotifier: widget.patientNotifier,
                        annotationTypesD: widget.annotationTypesD,
                        connectionNotifier: widget.connectionNotifier,
                        timedOut: widget.timedOut,
                        startupError: widget.startupError,
                      );
                    }),
                  );
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_back_ios,
                      color: Colors.grey,
                      size: 20.0,
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width - 15.0,
              child: ListView(
                children: <Widget>[
                  // ############### PLOT 1 ###############
                  if (widget.channelsMAC2Notifier.value.length > 0)
                    PlotDataTitle(
                        channels: widget.channelsMAC2Notifier.value[0],
                        sensor: widget.sensorsMAC2Notifier.value[0]),
                  if (widget.channelsMAC2Notifier.value.length > 0)
                    ValueListenableBuilder(
                        valueListenable: data1,
                        builder:
                            (BuildContext context, List data, Widget child) {
                          return SizedBox(
                              height: plotHeight,
                              child: PlotData(
                                  yRange: rangesList[0].sublist(0, 2),
                                  data: data));
                        }),
                  // ############### PLOT 2 ###############
                  if (widget.channelsMAC2Notifier.value.length > 1)
                    PlotDataTitle(
                        channels: widget.channelsMAC2Notifier.value[1],
                        sensor: widget.sensorsMAC2Notifier.value[1]),
                  if (widget.channelsMAC2Notifier.value.length > 1)
                    ValueListenableBuilder(
                        valueListenable: data2,
                        builder:
                            (BuildContext context, List data, Widget child) {
                          return SizedBox(
                              height: plotHeight,
                              child: PlotData(
                                  yRange: rangesList[1].sublist(0, 2),
                                  data: data));
                        }),
                  // ############### PLOT 3 ###############
                  if (widget.channelsMAC2Notifier.value.length > 2)
                    PlotDataTitle(
                        channels: widget.channelsMAC2Notifier.value[2],
                        sensor: widget.sensorsMAC2Notifier.value[2]),
                  if (widget.channelsMAC2Notifier.value.length > 2)
                    ValueListenableBuilder(
                        valueListenable: data3,
                        builder:
                            (BuildContext context, List data, Widget child) {
                          return SizedBox(
                              height: plotHeight,
                              child: PlotData(
                                  yRange: rangesList[2].sublist(0, 2),
                                  data: data));
                        }),
                  // ############### PLOT 4 ###############
                  if (widget.channelsMAC2Notifier.value.length > 3)
                    PlotDataTitle(
                        channels: widget.channelsMAC2Notifier.value[3],
                        sensor: widget.sensorsMAC2Notifier.value[3]),
                  if (widget.channelsMAC2Notifier.value.length > 3)
                    ValueListenableBuilder(
                        valueListenable: data4,
                        builder:
                            (BuildContext context, List data, Widget child) {
                          return SizedBox(
                              height: plotHeight,
                              child: PlotData(
                                  yRange: rangesList[3].sublist(0, 2),
                                  data: data));
                        }),
                  // ############### PLOT 5 ###############
                  if (widget.channelsMAC2Notifier.value.length > 4)
                    PlotDataTitle(
                        channels: widget.channelsMAC2Notifier.value[4],
                        sensor: widget.sensorsMAC2Notifier.value[4]),
                  if (widget.channelsMAC2Notifier.value.length > 4)
                    ValueListenableBuilder(
                        valueListenable: data5,
                        builder:
                            (BuildContext context, List data, Widget child) {
                          return SizedBox(
                              height: plotHeight,
                              child: PlotData(
                                  yRange: rangesList[4].sublist(0, 2),
                                  data: data));
                        }),
                  // ############### PLOT 6 ###############
                  if (widget.channelsMAC2Notifier.value.length > 5)
                    PlotDataTitle(
                        channels: widget.channelsMAC2Notifier.value[5],
                        sensor: widget.sensorsMAC2Notifier.value[5]),
                  if (widget.channelsMAC2Notifier.value.length > 5)
                    ValueListenableBuilder(
                        valueListenable: data6,
                        builder:
                            (BuildContext context, List data, Widget child) {
                          return SizedBox(
                              height: plotHeight,
                              child: PlotData(
                                  yRange: rangesList[5].sublist(0, 2),
                                  data: data));
                        }),
                ],
              ),
            ),
          ]),
        ),
      ]),
      floatingActionButton: Stack(children: [
        Align(
          alignment: Alignment(-0.8, 1.0),
          child: FloatingActionButton(
            mini: true,
            heroTag: null,
            onPressed: () => _speedAnnotation(),
            child: Icon(MdiIcons.lightningBolt),
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: FloatingActionButton.extended(
            onPressed: () => _stopAcquisition(),
            label: Text('Parar'),
            icon: Icon(Icons.stop),
          ),
        ),
      ]),
    );
  }
}
