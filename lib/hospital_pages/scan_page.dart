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
  final TextEditingController _idController = TextEditingController();
  String barcode = "";

  @override
  initState() {
    super.initState();
    var timeStamp = DateTime.now();
    _idController.text = '${timeStamp.day}_${timeStamp.month}_${timeStamp.year}';
  }

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text('EpiBox'),
      ),
      body: new Center(
        child: new ListView(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 70.0),
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  child: RichText(
                      textAlign: TextAlign.justify,
                      text: TextSpan(children: [
                        TextSpan(
                            text: 'Bem vindo ao  ',
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[600])),
                        TextSpan(
                            text: 'EpiBox',
                            style: TextStyle(
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600])),
                        TextSpan(
                            text: '!',
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[600])),
                      ])),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
              child: Align(
                alignment: Alignment.center,
                child: Container(
                    child: Text(
                        'Para começar as aquisições, faça scan do ID do paciente ou introduza-o manualmente.',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        textAlign: TextAlign.center)),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.0, 30.0, 20.0, 0.0),
              child: RaisedButton.icon(
                  color: Colors.blue,
                  textColor: Colors.white,
                  splashColor: Colors.blueGrey,
                  onPressed: () => scan(widget.patientNotifier),
                  icon: Icon(
                    MdiIcons.qrcode,
                  ),
                  label: const Text('INICIAR SCAN')),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
              child: Align(
                alignment: Alignment.center,
                child: Container(
                    child: Text(
                        barcode,
                        style: TextStyle(fontSize: 16, color: Colors.red[200]),
                        textAlign: TextAlign.center)),
              ),
            ),
            Padding(
                padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextField(
                          style: TextStyle(color: Colors.grey[600]),
                          controller: _idController,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'ID do paciente',
                              isDense: true,
                              contentPadding: EdgeInsets.all(10)),
                          onChanged: null),
                    ),
                    IconButton(
                        icon: Icon(
                          Icons.check_circle,
                          color: Colors.blue,
                          size: 30,
                        ),
                        onPressed: () => setState(() =>
                            widget.patientNotifier.value = _idController.text.trim()))
                  ],
                )),
            
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
          //mini: true,
          label: Text('Instruções'),
          icon: Icon(Icons.list),
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
