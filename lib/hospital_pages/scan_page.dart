import 'dart:async';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:rPiInterface/hospital_pages/instructions_H.dart';

class ScanPage extends StatefulWidget {
  ValueNotifier<String> patientNotifier;
  ScanPage({this.patientNotifier});

  @override
  _ScanPageState createState() => new _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  String barcode = "";

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text('Scanner de código QR'),
      ),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: RaisedButton.icon(
                  color: Colors.blue,
                  textColor: Colors.white,
                  splashColor: Colors.blueGrey,
                  //onPressed: () => scan(widget.patientNotifier),
                  onPressed: () {
                    setState(() => widget.patientNotifier.value =
                        'kDvaj6fuMgfDbv3XGCQVFunsIhY2');
                    print(widget.patientNotifier.value);
                  },
                  icon: Icon(
                    MdiIcons.qrcode,
                  ),
                  label: const Text('INICIAR SCAN')),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                barcode,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          mini: true,
          heroTag: null,
          child: Icon(Icons.list),
          onPressed: () async {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) {
                return InstructionsHPage();
              }),
            );
          }),
    );
  }

  Future scan(ValueNotifier<String> notifier) async {
    try {
      var scan = (await BarcodeScanner.scan());
      String scanString = scan.rawContent;
      if (scan.format != BarcodeFormat.unknown) {
        setState(() => notifier.value = scanString);
        setState(() => this.barcode = 'ID: ${widget.patientNotifier.value}');
      }
      print('HERE: ${notifier.value}');
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.cameraAccessDenied) {
        setState(() {
          this.barcode = 'É necessário permissão para aceder à camera!';
        });
      } else {
        setState(() => this.barcode = 'Unknown error: $e');
      }
    } on FormatException {
      print('HERE: ${notifier.value}');
      setState(() => notifier.value = null);
      setState(() => this.barcode = 'Scan não completo.');
    } catch (e) {
      setState(() => this.barcode = 'Unknown error: $e');
    }
  }
}
