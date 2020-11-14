import 'package:flutter/material.dart';
import 'package:rPiInterface/utils/oscilloscope.dart';

class RealtimePage extends StatefulWidget {
  ValueNotifier<double> value1;
  ValueNotifier<double> value2;

  RealtimePage({
    this.value1,
    this.value2,
  });

  @override
  _RealtimePageState createState() => _RealtimePageState();
}

class _RealtimePageState extends State<RealtimePage> {
  //final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  List<double> acquisition1 = List();
  List<double> acquisition2 = List();

  @override
  void initState() {
    super.initState();
    widget.value1.addListener(() {
      if (this.mounted) {
        setState(() {
          acquisition1.add(widget.value1.value);
          acquisition2.add(widget.value2.value);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text('Visualização'),
      ),
      body: Container(
        child: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Text(
                    'CENAS',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                ValueListenableBuilder(
                    valueListenable: widget.value1,
                    builder: (BuildContext context, double val, Widget child) {
                      // This builder will only get called when the _counter
                      // is updated.
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 20.0),
                          child: Row(children: [
                            Padding(
                              padding: EdgeInsets.only(left: 10.0),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('1'),
                                  Text('-1'),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Oscilloscope(
                                yAxisMax: 1.0,
                                yAxisMin: -1.0,
                                dataSet: acquisition1,
                              ),
                            ),
                          ]),
                        ),
                      );
                    }),
                Text(
                  'CENAS',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                ValueListenableBuilder(
                    valueListenable: widget.value2,
                    builder: (BuildContext context, double val, Widget child) {
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 20.0),
                          child: Row(children: [
                            Padding(
                              padding: EdgeInsets.only(left: 10.0),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [Text('1'), Text('-1')],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Oscilloscope(
                                yAxisMax: 1.0,
                                yAxisMin: -1.0,
                                dataSet: acquisition2,
                              ),
                            ),
                          ]),
                        ),
                      );
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
