import 'package:flutter/material.dart';
import 'package:rPiInterface/utils/mqtt_wrapper.dart';
import 'package:rPiInterface/utils/plot_data.dart';
import 'package:rPiInterface/utils/battery_indicator.dart';

class RealtimePage extends StatefulWidget {

  ValueNotifier<List> dataNotifier;
  ValueNotifier<List> dataChannelsNotifier;

  MQTTClientWrapper mqttClientWrapper;

  ValueNotifier<String> hostnameNotifier;

  ValueNotifier<String> acquisitionNotifier;

  ValueNotifier<double> batteryBit1Notifier;
  ValueNotifier<double> batteryBit2Notifier;

  RealtimePage({
    this.dataNotifier,
    this.dataChannelsNotifier,
    this.mqttClientWrapper,
    this.hostnameNotifier,
    this.acquisitionNotifier,
    this.batteryBit1Notifier,
    this.batteryBit2Notifier,
  });

  @override
  _RealtimePageState createState() => _RealtimePageState();
}

class _RealtimePageState extends State<RealtimePage> {
  List aux;

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

  List<double> yRange1 = [0, 10];
  List<double> yRange2 = [0, 10];
  List<double> yRange3 = [0, 10];
  List<double> yRange4 = [0, 10];
  List<double> yRange5 = [0, 10];
  List<double> yRange6 = [0, 10];
  List<double> yRange7 = [0, 10];
  List<double> yRange8 = [0, 10];
  List<double> yRange9 = [0, 10];
  List<double> yRange10 = [0, 10];

  void _stopAcquisition() {
    widget.mqttClientWrapper.publishMessage("['INTERRUPT']");
  }

  bool _rangeUpdateNeeded(List data, List currentRange) {
    bool update = false;
    if (data.first < currentRange[0] || currentRange[0] < data.first - 5) {
      update = true;
    }
    if (data.last > currentRange[1] || currentRange[1] > data.last + 5) {
      update = true;
    }
    return update;
  }

  List<double> _updateRange(List data, List currentRange) {
    double min;
    double max;

    if (data.first < currentRange[0] || currentRange[0] < data.first - 5) {
      min = (data.first - 5).floor().toDouble();
    } else {
      min = currentRange[0];
    }
    if (data.last > currentRange[1] || currentRange[1] > data.last + 5) {
      max = (data.last + 5).ceil().toDouble();
    } else {
      max = currentRange[1];
    }
    return [min, max];
  }

  @override
  void initState() {
    super.initState();
    widget.dataNotifier.addListener(() {
      if (this.mounted) {
        double canvasWidth = MediaQuery.of(context).size.width;
        widget.dataNotifier.value.asMap().forEach((index, channel) {
          channel.asMap().forEach((i, value) {
            if (index == 0) {
              setState(() => data1.value.add(value));
              if (data1.value.length > canvasWidth) {
                data1.value.removeAt(0);
              }
              aux = []..addAll(data1.value);
              aux.sort();
              if (_rangeUpdateNeeded(aux, yRange1)) {
                setState(() => yRange1 = _updateRange(aux, yRange1));
              }
            } else if (index == 1) {
              setState(() => data2.value.add(value));
              if (data2.value.length > canvasWidth) {
                data2.value.removeAt(0);
              }
              aux = []..addAll(data2.value);
              aux.sort();
              if (_rangeUpdateNeeded(aux, yRange2)) {
                setState(() => yRange2 = _updateRange(aux, yRange2));
              }
            } else if (index == 2) {
              setState(() => data3.value.add(value));
              if (data3.value.length > canvasWidth) {
                data3.value.removeAt(0);
              }
              aux = []..addAll(data3.value);
              aux.sort();
              if (_rangeUpdateNeeded(aux, yRange3)) {
                setState(() => yRange3 = _updateRange(aux, yRange3));
              }
            } else if (index == 3) {
              setState(() => data4.value.add(value));
              if (data4.value.length > canvasWidth) {
                data4.value.removeAt(0);
              }
              aux = []..addAll(data4.value);
              aux.sort();
              if (_rangeUpdateNeeded(aux, yRange4)) {
                setState(() => yRange4 = _updateRange(aux, yRange4));
              }
            } else if (index == 4) {
              setState(() => data5.value.add(value));
              if (data5.value.length > canvasWidth) {
                data5.value.removeAt(0);
              }
              aux = []..addAll(data5.value);
              aux.sort();
              if (_rangeUpdateNeeded(aux, yRange5)) {
                setState(() => yRange5 = _updateRange(aux, yRange5));
              }
            } else if (index == 5) {
              setState(() => data6.value.add(value));
              if (data6.value.length > canvasWidth) {
                data6.value.removeAt(0);
              }
              aux = []..addAll(data6.value);
              aux.sort();
              if (_rangeUpdateNeeded(aux, yRange6)) {
                setState(() => yRange6 = _updateRange(aux, yRange6));
              }
            } else if (index == 6) {
              setState(() => data7.value.add(value));
              if (data7.value.length > canvasWidth) {
                data7.value.removeAt(0);
              }
              aux = []..addAll(data7.value);
              aux.sort();
              if (_rangeUpdateNeeded(aux, yRange7)) {
                setState(() => yRange7 = _updateRange(aux, yRange7));
              }
            } else if (index == 7) {
              setState(() => data8.value.add(value));
              if (data8.value.length > canvasWidth) {
                data8.value.removeAt(0);
              }
              aux = []..addAll(data8.value);
              aux.sort();
              if (_rangeUpdateNeeded(aux, yRange8)) {
                setState(() => yRange8 = _updateRange(aux, yRange8));
              }
            } else if (index == 8) {
              setState(() => data9.value.add(value));
              if (data9.value.length > canvasWidth) {
                data9.value.removeAt(0);
              }
              aux = []..addAll(data9.value);
              aux.sort();
              if (_rangeUpdateNeeded(aux, yRange9)) {
                setState(() => yRange9 = _updateRange(aux, yRange9));
              }
            } else if (index == 9) {
              setState(() => data10.value.add(value));
              if (data10.value.length > canvasWidth) {
                data10.value.removeAt(0);
              }
              aux = []..addAll(data10.value);
              aux.sort();
              if (_rangeUpdateNeeded(aux, yRange10)) {
                setState(() => yRange10 = _updateRange(aux, yRange10));
              }
            }
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text('Visualização'),
        actions: [Column(children: [
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
                            showPercentNum: false,
                            mainColor: Colors.black,
                            height: 10,
                            width: 20,

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
                            showPercentNum: false,
                            mainColor: Colors.black,
                            height: 10,
                            width: 20,
                            //showPercentSlide: _showPercentSlide,
                          ),
                        ),
                      ),
                    ])
                  : SizedBox.shrink();
            },
          ),
        ]),],
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
                    valueListenable: widget.acquisitionNotifier,
                    builder:
                        (BuildContext context, String state, Widget child) {
                      return Container(
                        height: 20,
                        color: state == 'acquiring'
                            ? Colors.green[50]
                            : state == 'reconnecting'
                                ? Colors.yellow[50]
                                : Colors.red[50],
                        child: Align(
                          alignment: Alignment.center,
                          child: Container(
                            child: Text(
                              state == 'acquiring'
                                  ? 'A adquirir dados'
                                  : state == 'reconnecting'
                                      ? 'A retomar aquisição ...'
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
                  PlotDataTitle(channels: widget.dataChannelsNotifier.value[0]),
                if (widget.dataChannelsNotifier.value.length > 0)
                  ValueListenableBuilder(
                      valueListenable: data1,
                      builder: (BuildContext context, List data, Widget child) {
                        return PlotData(yRange: yRange1, data: data);
                      }),
                // ############### PLOT 2 ###############
                if (widget.dataChannelsNotifier.value.length > 1)
                  PlotDataTitle(channels: widget.dataChannelsNotifier.value[1]),
                if (widget.dataChannelsNotifier.value.length > 1)
                  ValueListenableBuilder(
                      valueListenable: data2,
                      builder: (BuildContext context, List data, Widget child) {
                        return PlotData(yRange: yRange2, data: data);
                      }),
                // ############### PLOT 3 ###############
                if (widget.dataChannelsNotifier.value.length > 2)
                  PlotDataTitle(channels: widget.dataChannelsNotifier.value[2]),
                if (widget.dataChannelsNotifier.value.length > 2)
                  ValueListenableBuilder(
                      valueListenable: data3,
                      builder: (BuildContext context, List data, Widget child) {
                        return PlotData(yRange: yRange3, data: data);
                      }),
                // ############### PLOT 4 ###############
                if (widget.dataChannelsNotifier.value.length > 3)
                  PlotDataTitle(channels: widget.dataChannelsNotifier.value[3]),
                if (widget.dataChannelsNotifier.value.length > 3)
                  ValueListenableBuilder(
                      valueListenable: data4,
                      builder: (BuildContext context, List data, Widget child) {
                        return PlotData(yRange: yRange4, data: data);
                      }),
                // ############### PLOT 5 ###############
                if (widget.dataChannelsNotifier.value.length > 4)
                  PlotDataTitle(channels: widget.dataChannelsNotifier.value[4]),
                if (widget.dataChannelsNotifier.value.length > 4)
                  ValueListenableBuilder(
                      valueListenable: data5,
                      builder: (BuildContext context, List data, Widget child) {
                        return PlotData(yRange: yRange5, data: data);
                      }),
                // ############### PLOT 6 ###############
                if (widget.dataChannelsNotifier.value.length > 5)
                  PlotDataTitle(channels: widget.dataChannelsNotifier.value[5]),
                if (widget.dataChannelsNotifier.value.length > 5)
                  ValueListenableBuilder(
                      valueListenable: data6,
                      builder: (BuildContext context, List data, Widget child) {
                        return PlotData(yRange: yRange6, data: data);
                      }),
                // ############### PLOT 7 ###############
                if (widget.dataChannelsNotifier.value.length > 6)
                  PlotDataTitle(channels: widget.dataChannelsNotifier.value[6]),
                if (widget.dataChannelsNotifier.value.length > 6)
                  ValueListenableBuilder(
                      valueListenable: data7,
                      builder: (BuildContext context, List data, Widget child) {
                        return PlotData(yRange: yRange7, data: data);
                      }),
                // ############### PLOT 8 ###############
                if (widget.dataChannelsNotifier.value.length > 7)
                  PlotDataTitle(channels: widget.dataChannelsNotifier.value[7]),
                if (widget.dataChannelsNotifier.value.length > 7)
                  ValueListenableBuilder(
                      valueListenable: data8,
                      builder: (BuildContext context, List data, Widget child) {
                        return PlotData(yRange: yRange8, data: data);
                      }),
                // ############### PLOT 9 ###############
                if (widget.dataChannelsNotifier.value.length > 8)
                  PlotDataTitle(channels: widget.dataChannelsNotifier.value[8]),
                if (widget.dataChannelsNotifier.value.length > 8)
                  ValueListenableBuilder(
                      valueListenable: data9,
                      builder: (BuildContext context, List data, Widget child) {
                        return PlotData(yRange: yRange9, data: data);
                      }),
                // ############### PLOT 10 ###############
                if (widget.dataChannelsNotifier.value.length > 9)
                  PlotDataTitle(channels: widget.dataChannelsNotifier.value[9]),
                if (widget.dataChannelsNotifier.value.length > 9)
                  ValueListenableBuilder(
                      valueListenable: data10,
                      builder: (BuildContext context, List data, Widget child) {
                        return PlotData(yRange: yRange10, data: data);
                      }),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _stopAcquisition(),
        label: Text('Stop'),
        icon: Icon(Icons.stop),
      ),
    );
  }
}
