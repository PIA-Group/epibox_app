// Copyright (c) 2018, Steve Rogers. All rights reserved. Use of this source code
// is governed by an Apache License 2.0 that can be found in the LICENSE file.

import 'package:flutter/material.dart';

/// A widget that defines a customisable Oscilloscope type display that can be used to graph out data
///
/// The [dataSet] arguments MUST be a List<double> -  this is the data that is used by the display to generate a trace
///
/// All other arguments are optional as they have preset values
///
/// [showCanvas] this will display a line along the yAxisat 0 if the value is set to true (default is false)
/// [yAxisColor] determines the color of the displayed yAxis (default value is Colors.white)
///
/// [yAxisMin] and [yAxisMax] although optional should be set to reflect the data that is supplied in [dataSet]. These values
/// should be set to the min and max values in the supplied [dataSet].
///
/// For example if the max value in the data set is 2.5 and the min is -3.25  then you should set [yAxisMin] = -3.25 and [yAxisMax] = 2.5
/// This allows the oscilloscope display to scale the generated graph correctly.
///
/// You can modify the background color of the oscilloscope with the [backgroundColor] argument and the color of the trace with [traceColor]
///
/// The [padding] argument allows space to be set around the display (this defaults to 10.0 if not specified)
///
/// NB: This is not a Time Domain trace, the update frequency of the supplied [dataSet] determines the trace speed.
class Oscilloscope extends StatefulWidget {
  final List<double> dataSet;
  final double yAxisMin;
  final double yAxisMax;
  final double padding;
  final Color backgroundColor;
  final Color traceColor;
  final Color yAxisColor;
  final bool showCanvas;
  Oscilloscope(
      {this.traceColor = Colors.blue,
      this.backgroundColor: Colors.white,
      this.yAxisColor: Colors.black,
      this.padding = 10.0,
      this.yAxisMax = 1.0,
      this.yAxisMin = -1.0,
      this.showCanvas = true,
      @required this.dataSet});

  @override
  _OscilloscopeState createState() => _OscilloscopeState();
}

class _OscilloscopeState extends State<Oscilloscope> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.0),
        child: Container(
          decoration: BoxDecoration(
              color: widget.backgroundColor,
              border: Border.all(color: widget.yAxisColor, width: 2.0)),
          height: double.infinity,
          width: double.infinity,
          child: RepaintBoundary(
            child: CustomPaint(
              isComplex: true,
              painter: _TracePainter(
                showCanvas: widget.showCanvas,
                yAxisColor: widget.yAxisColor,
                dataSet: widget.dataSet,
                traceColor: widget.traceColor,
                yMin: widget.yAxisMin,
                yMax: widget.yAxisMax,
              ),
            ),
          ),
        ),
        //),
      );
    });
  }
}

/// A Custom Painter used to generate the trace line from the supplied dataset
class _TracePainter extends CustomPainter {
  final List dataSet;
  final double xScale;
  final double yMin;
  final double yMax;
  final Color traceColor;
  final Color yAxisColor;
  final bool showCanvas;
  final bool showXAxis;

  _TracePainter(
      {this.showCanvas,
      this.showXAxis,
      this.yAxisColor,
      this.yMin,
      this.yMax,
      this.dataSet,
      this.xScale = 1.0,
      this.traceColor = Colors.white});

  @override
  void paint(Canvas canvas, Size size) {
    final tracePaint = Paint()
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 1.0
      ..color = traceColor
      ..style = PaintingStyle.stroke;

    double yRange = yMax - yMin;
    double yScale = (size.height / yRange);
    List data2draw = dataSet;

    // only start plot if dataset has data
    int length = dataSet.length;
    if (length > 0) {
      if (length > size.width.toInt())
        data2draw = dataSet.sublist(dataSet.length - size.width.floor());
      // Create Path and set Origin to first data point
      Path trace = Path();
      //trace.moveTo(0.0, size.height - (dataSet[0] - yMin) * yScale);

      // generate trace path
      int dataSize = data2draw.length;
      for (int p = 0; p < dataSize - 1; p++) {
        double plotPoint = size.height - (data2draw[p] - yMin) * yScale;
        trace.lineTo(p * xScale, plotPoint);
      }

      // display the trace
      canvas.drawPath(trace, tracePaint);
    }
  }

  @override
  bool shouldRepaint(_TracePainter old) => true;
}
