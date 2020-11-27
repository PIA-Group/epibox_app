import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:rPiInterface/hospital_pages/speed_annotation.dart';
import 'package:rPiInterface/utils/models.dart';
import 'package:rPiInterface/utils/mqtt_wrapper.dart';
import 'package:rPiInterface/utils/plot_data.dart';
import 'package:rPiInterface/utils/battery_indicator.dart';

class RealtimePage extends StatefulWidget {
  ValueNotifier<List> dataNotifier;
  ValueNotifier<List> dataChannelsNotifier;
  ValueNotifier<List> dataSensorsNotifier;
  MQTTClientWrapper mqttClientWrapper;

  ValueNotifier<String> acquisitionNotifier;

  ValueNotifier<double> batteryBit1Notifier;
  ValueNotifier<double> batteryBit2Notifier;

  ValueNotifier<String> patientNotifier;

  ValueNotifier<List> annotationTypesD;

  ValueNotifier<MqttCurrentConnectionState> connectionNotifier;

  RealtimePage({
    this.dataNotifier,
    this.dataChannelsNotifier,
    this.dataSensorsNotifier,
    this.mqttClientWrapper,
    this.acquisitionNotifier,
    this.batteryBit1Notifier,
    this.batteryBit2Notifier,
    this.patientNotifier,
    this.annotationTypesD,
    this.connectionNotifier,
  });

  @override
  _RealtimePageState createState() => _RealtimePageState();
}

class _RealtimePageState extends State<RealtimePage> {
  final GlobalKey<ScaffoldState> _scaffoldRealTime =
      new GlobalKey<ScaffoldState>();
  List aux;
  final firestoreInstance = Firestore.instance;

  ValueNotifier<bool> newAnnotation = ValueNotifier(false);

  ValueNotifier<List<double>> data1 = ValueNotifier([]);
  ValueNotifier<List<double>> data2 = ValueNotifier([]);
  ValueNotifier<List<double>> data3 = ValueNotifier([]);
  ValueNotifier<List<double>> data4 = ValueNotifier([]);
  ValueNotifier<List<double>> data5 = ValueNotifier([]);
  ValueNotifier<List<double>> data6 = ValueNotifier([]);
  ValueNotifier<List<double>> data7 = ValueNotifier([]);
  ValueNotifier<List<double>> data8 = ValueNotifier([]);
  ValueNotifier<List<double>> data9 = ValueNotifier([]);
  ValueNotifier<List<double>> data10 = ValueNotifier([]);

  List<List<double>> rangesList = List.filled(10, [0, 10, 1]);
  bool _rangeInitiated;

  /* Future<List> getAnnotationTypes() async {
    List annot;
    await firestoreInstance
        .collection("annotations")
        .document('types')
        .get()
        .then(
            //(value) => print('annot: ${value.data}'));
            (value) => setState(() => annot = value.data['types'].toList()));
    print(annot);
    return annot;
  } */

  void _stopAcquisition() {
    widget.mqttClientWrapper.publishMessage("['INTERRUPT']");
    
  }

  Future<void> _speedAnnotation() async {
    //List annotationTypesD = await getAnnotationTypes();
    List<String> annotationTypes = List<String>.from(widget.annotationTypesD.value);
    print(annotationTypes);
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
      yRange = [0, 10, 0];
    }
    return yRange;
  }

  void _initRange(sensorsList) {
  
    for (int i=0; i<sensorsList.length; i++) {
      List<double> auxList = _getRangeFromSensor(sensorsList[i]);
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

  @override
  void initState() {
    super.initState();
    
    setState(() => _rangeInitiated = false);

    /* widget.acquisitionNotifier.addListener(() {
      if (widget.acquisitionNotifier.value == 'stopped') Navigator.pop(context);}); */
    newAnnotation.addListener(() async {
      if (newAnnotation.value) {
        Future<Null>.delayed(Duration.zero, () {
          _showSnackBar('Anotação gravada!');
          setState(() => newAnnotation.value = false);
        });
      }
    });

    widget.dataNotifier.addListener(() {
      if (this.mounted) {
        if(!_rangeInitiated && widget.dataSensorsNotifier.value.isNotEmpty) {
          _initRange(widget.dataSensorsNotifier.value);
          print('RANGE: $rangesList');
        }

        double canvasWidth = MediaQuery.of(context).size.width;
        widget.dataNotifier.value.asMap().forEach((index, channel) {
          channel.asMap().forEach((i, value) {
            if (index == 0) {
              setState(() => data1.value.add(value));
              if (data1.value.length > canvasWidth) {
                data1.value.removeAt(0);
              }
              if (rangesList[index][2] == 0) {
                aux = []..addAll(data1.value);
                aux.sort();
                if (_rangeUpdateNeeded(aux, rangesList[index].sublist(0,2))) {
                  setState(() => rangesList[index] = _updateRange(aux, rangesList[index].sublist(0,2)));
                }
              }
            } else if (index == 1) {
              setState(() => data2.value.add(value));
              if (data2.value.length > canvasWidth) {
                data2.value.removeAt(0);
              }
              if (rangesList[index][2] == 0) {
                aux = []..addAll(data1.value);
                aux.sort();
                if (_rangeUpdateNeeded(aux, rangesList[index].sublist(0,2))) {
                  setState(() => rangesList[index] = _updateRange(aux, rangesList[index].sublist(0,2)));
                }
              }
            } else if (index == 2) {
              setState(() => data3.value.add(value));
              if (data3.value.length > canvasWidth) {
                data3.value.removeAt(0);
              }
              if (rangesList[index][2] == 0) {
                aux = []..addAll(data1.value);
                aux.sort();
                if (_rangeUpdateNeeded(aux, rangesList[index].sublist(0,2))) {
                  setState(() => rangesList[index] = _updateRange(aux, rangesList[index].sublist(0,2)));
                }
              }
            } else if (index == 3) {
              setState(() => data4.value.add(value));
              if (data4.value.length > canvasWidth) {
                data4.value.removeAt(0);
              }
              if (rangesList[index][2] == 0) {
                aux = []..addAll(data1.value);
                aux.sort();
                if (_rangeUpdateNeeded(aux, rangesList[index].sublist(0,2))) {
                  setState(() => rangesList[index] = _updateRange(aux, rangesList[index].sublist(0,2)));
                }
              }
            } else if (index == 4) {
              setState(() => data5.value.add(value));
              if (data5.value.length > canvasWidth) {
                data5.value.removeAt(0);
              }
              if (rangesList[index][2] == 0) {
                aux = []..addAll(data1.value);
                aux.sort();
                if (_rangeUpdateNeeded(aux, rangesList[index].sublist(0,2))) {
                  setState(() => rangesList[index] = _updateRange(aux, rangesList[index].sublist(0,2)));
                }
              }
            } else if (index == 5) {
              setState(() => data6.value.add(value));
              if (data6.value.length > canvasWidth) {
                data6.value.removeAt(0);
              }
              if (rangesList[index][2] == 0) {
                aux = []..addAll(data1.value);
                aux.sort();
                if (_rangeUpdateNeeded(aux, rangesList[index].sublist(0,2))) {
                  setState(() => rangesList[index] = _updateRange(aux, rangesList[index].sublist(0,2)));
                }
              }
            } else if (index == 6) {
              setState(() => data7.value.add(value));
              if (data7.value.length > canvasWidth) {
                data7.value.removeAt(0);
              }
              if (rangesList[index][2] == 0) {
                aux = []..addAll(data1.value);
                aux.sort();
                if (_rangeUpdateNeeded(aux, rangesList[index].sublist(0,2))) {
                  setState(() => rangesList[index] = _updateRange(aux, rangesList[index].sublist(0,2)));
                }
              }
            } else if (index == 7) {
              setState(() => data8.value.add(value));
              if (data8.value.length > canvasWidth) {
                data8.value.removeAt(0);
              }
              if (rangesList[index][2] == 0) {
                aux = []..addAll(data1.value);
                aux.sort();
                if (_rangeUpdateNeeded(aux, rangesList[index].sublist(0,2))) {
                  setState(() => rangesList[index] = _updateRange(aux, rangesList[index].sublist(0,2)));
                }
              }
            } else if (index == 8) {
              setState(() => data9.value.add(value));
              if (data9.value.length > canvasWidth) {
                data9.value.removeAt(0);
              }
              if (rangesList[index][2] == 0) {
                aux = []..addAll(data1.value);
                aux.sort();
                if (_rangeUpdateNeeded(aux, rangesList[index].sublist(0,2))) {
                  setState(() => rangesList[index] = _updateRange(aux, rangesList[index].sublist(0,2)));
                }
              }
            } else if (index == 9) {
              setState(() => data10.value.add(value));
              if (data10.value.length > canvasWidth) {
                data10.value.removeAt(0);
              }
              if (rangesList[index][2] == 0) {
                aux = []..addAll(data1.value);
                aux.sort();
                if (_rangeUpdateNeeded(aux, rangesList[index].sublist(0,2))) {
                  setState(() => rangesList[index] = _updateRange(aux, rangesList[index].sublist(0,2)));
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
        title: new Text('Visualização'),
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
      body: Container(
        child: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
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
                    builder:
                        (BuildContext context, String state, Widget child) {
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
                // ############### PLOT 1 ###############
                if (widget.dataChannelsNotifier.value.length > 0)
                  PlotDataTitle(
                      channels: widget.dataChannelsNotifier.value[0],
                      sensor: widget.dataSensorsNotifier.value[0]),
                if (widget.dataChannelsNotifier.value.length > 0)
                  ValueListenableBuilder(
                      valueListenable: data1,
                      builder: (BuildContext context, List data, Widget child) {
                        return PlotData(yRange: rangesList[0].sublist(0,2), data: data);
                      }),
                // ############### PLOT 2 ###############
                if (widget.dataChannelsNotifier.value.length > 1)
                  PlotDataTitle(
                      channels: widget.dataChannelsNotifier.value[1],
                      sensor: widget.dataSensorsNotifier.value[1]),
                if (widget.dataChannelsNotifier.value.length > 1)
                  ValueListenableBuilder(
                      valueListenable: data2,
                      builder: (BuildContext context, List data, Widget child) {
                        return PlotData(yRange: rangesList[1].sublist(0,2), data: data);
                      }),
                // ############### PLOT 3 ###############
                if (widget.dataChannelsNotifier.value.length > 2)
                  PlotDataTitle(
                      channels: widget.dataChannelsNotifier.value[2],
                      sensor: widget.dataSensorsNotifier.value[2]),
                if (widget.dataChannelsNotifier.value.length > 2)
                  ValueListenableBuilder(
                      valueListenable: data3,
                      builder: (BuildContext context, List data, Widget child) {
                        return PlotData(yRange: rangesList[2].sublist(0,2), data: data);
                      }),
                // ############### PLOT 4 ###############
                if (widget.dataChannelsNotifier.value.length > 3)
                  PlotDataTitle(
                      channels: widget.dataChannelsNotifier.value[3],
                      sensor: widget.dataSensorsNotifier.value[3]),
                if (widget.dataChannelsNotifier.value.length > 3)
                  ValueListenableBuilder(
                      valueListenable: data4,
                      builder: (BuildContext context, List data, Widget child) {
                        return PlotData(yRange: rangesList[3].sublist(0,2), data: data);
                      }),
                // ############### PLOT 5 ###############
                if (widget.dataChannelsNotifier.value.length > 4)
                  PlotDataTitle(
                      channels: widget.dataChannelsNotifier.value[4],
                      sensor: widget.dataSensorsNotifier.value[4]),
                if (widget.dataChannelsNotifier.value.length > 4)
                  ValueListenableBuilder(
                      valueListenable: data5,
                      builder: (BuildContext context, List data, Widget child) {
                        return PlotData(yRange: rangesList[4].sublist(0,2), data: data);
                      }),
                // ############### PLOT 6 ###############
                if (widget.dataChannelsNotifier.value.length > 5)
                  PlotDataTitle(
                      channels: widget.dataChannelsNotifier.value[5],
                      sensor: widget.dataSensorsNotifier.value[5]),
                if (widget.dataChannelsNotifier.value.length > 5)
                  ValueListenableBuilder(
                      valueListenable: data6,
                      builder: (BuildContext context, List data, Widget child) {
                        return PlotData(yRange: rangesList[5].sublist(0,2), data: data);
                      }),
                // ############### PLOT 7 ###############
                if (widget.dataChannelsNotifier.value.length > 6)
                  PlotDataTitle(
                      channels: widget.dataChannelsNotifier.value[6],
                      sensor: widget.dataSensorsNotifier.value[6]),
                if (widget.dataChannelsNotifier.value.length > 6)
                  ValueListenableBuilder(
                      valueListenable: data7,
                      builder: (BuildContext context, List data, Widget child) {
                        return PlotData(yRange: rangesList[6].sublist(0,2), data: data);
                      }),
                // ############### PLOT 8 ###############
                if (widget.dataChannelsNotifier.value.length > 7)
                  PlotDataTitle(
                      channels: widget.dataChannelsNotifier.value[7],
                      sensor: widget.dataSensorsNotifier.value[7]),
                if (widget.dataChannelsNotifier.value.length > 7)
                  ValueListenableBuilder(
                      valueListenable: data8,
                      builder: (BuildContext context, List data, Widget child) {
                        return PlotData(yRange: rangesList[7].sublist(0,2), data: data);
                      }),
                // ############### PLOT 9 ###############
                if (widget.dataChannelsNotifier.value.length > 8)
                  PlotDataTitle(
                      channels: widget.dataChannelsNotifier.value[8],
                      sensor: widget.dataSensorsNotifier.value[8]),
                if (widget.dataChannelsNotifier.value.length > 8)
                  ValueListenableBuilder(
                      valueListenable: data9,
                      builder: (BuildContext context, List data, Widget child) {
                        return PlotData(yRange: rangesList[8].sublist(0,2), data: data);
                      }),
                // ############### PLOT 10 ###############
                if (widget.dataChannelsNotifier.value.length > 9)
                  PlotDataTitle(
                      channels: widget.dataChannelsNotifier.value[9],
                      sensor: widget.dataSensorsNotifier.value[9]),
                if (widget.dataChannelsNotifier.value.length > 9)
                  ValueListenableBuilder(
                      valueListenable: data10,
                      builder: (BuildContext context, List data, Widget child) {
                        return PlotData(yRange: rangesList[9].sublist(0,2), data: data);
                      }),
              ],
            ),
          ),
        ),
      ),
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
