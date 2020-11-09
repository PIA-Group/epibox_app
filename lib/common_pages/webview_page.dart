import 'package:flutter/material.dart';
import 'package:rPiInterface/utils/mqtt_wrapper.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebviewPage extends StatefulWidget {
  MQTTClientWrapper mqttClientWrapper;
  ValueNotifier<String> acquisitionNotifier;
  ValueNotifier<String> hostnameNotifier;

  WebviewPage({
    this.mqttClientWrapper,
    this.acquisitionNotifier,
    this.hostnameNotifier,
  });

  @override
  _WebviewPageState createState() => _WebviewPageState();
}

class _WebviewPageState extends State<WebviewPage> {
  //final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  void _stopAcquisition() {
    print(widget.hostnameNotifier);
    widget.mqttClientWrapper.publishMessage("['INTERRUPT']");
    //_showSnackBar('Aquisição terminada e dados gravados');
  }

  @override
  void initState() {
    super.initState();
    /* widget.acquisitionNotifier.addListener(() {
      _showSnackBar(
        widget.acquisitionNotifier.value == 'acquiring'
            ? 'A adquirir dados'
            : widget.acquisitionNotifier.value == 'reconnecting'
                ? 'A retomar aquisição ...'
                : widget.acquisitionNotifier.value == 'stopped'
                    ? 'Aquisição terminada e dados gravados'
                    : 'Aquisição desligada',
      );
    }); */
  }

  /*  void _showSnackBar(String _message) {
    try {
      _scaffoldKey.currentState.showSnackBar(new SnackBar(
        content: new Text(_message),
        backgroundColor: Colors.blue,
      ));
    } catch (e) {
      print(e);
    }
  } */

  @override
  Widget build(BuildContext context) {
    final bodyHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).viewInsets.bottom -
        MediaQuery.of(context).viewInsets.top;

    return Scaffold(
      appBar: new AppBar(
        title: new Text('Visualização'),
      ),
      body: Container(
        child: ListView(scrollDirection: Axis.vertical, children: <Widget>[
          ValueListenableBuilder(
              valueListenable: widget.acquisitionNotifier,
              builder: (BuildContext context, String state, Widget child) {
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
          Container(
            height: bodyHeight,
            child: WebView(
              initialUrl: 'http://' + widget.hostnameNotifier.value + ':8080/',
              javascriptMode: JavascriptMode.unrestricted,
            ),
          ),
        ]),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _stopAcquisition(),
        label: Text('Stop'),
        icon: Icon(Icons.stop),
      ),
    );
  }
}
