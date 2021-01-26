import 'package:flutter/material.dart';

import 'oscilloscope.dart';

class PlotData extends StatefulWidget {
  List<double> yRange;
  List<double> data;

  PlotData({
    this.yRange,
    this.data,
  });

  @override
  _PlotDataState createState() => _PlotDataState();
}

class _PlotDataState extends State<PlotData> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      child: Padding(
        padding: EdgeInsets.only(bottom: 20.0),
        child: Row(children: [
          Padding(
            padding: EdgeInsets.only(left: 5.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${widget.yRange[1]}'),
                Text('${widget.yRange[0]}')
              ],
            ),
          ),
          Expanded(
            child: Oscilloscope(
              yAxisMax: widget.yRange[1],
              yAxisMin: widget.yRange[0],
              dataSet: widget.data,
            ),
          ),
        ]),
      ),
    );
  }
}

class PlotDataTitle extends StatefulWidget {
  List channels;
  String sensor;

  PlotDataTitle({
    this.channels,
    this.sensor,
  });

  @override
  _PlotDataTitleState createState() => _PlotDataTitleState();
}

class _PlotDataTitleState extends State<PlotDataTitle> {
  @override
  Widget build(BuildContext context) {
    return Center(
    /* Padding(
      padding: EdgeInsets.only(top: 10.0,), */
      child: Text(
        'Canal: A${widget.channels[1]} | ${widget.sensor}',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}
