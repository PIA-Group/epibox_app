import 'dart:async';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:rPiInterface/decor/text_styles.dart';
import 'package:rPiInterface/pages/instructions_H.dart';
import 'package:rPiInterface/decor/default_colors.dart';

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
    _idController.text =
        '${timeStamp.day}_${timeStamp.month}_${timeStamp.year}';
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
        centerTitle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
        title: new Text(
          'Bem vindo ao EpiBOX!',
          style: MyTextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: new Center(
        child: new ListView(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(20.0, 100.0, 20.0, 0.0),
              child: Align(
                alignment: Alignment.center,
                child: Container(
                    child: Text(
                        'Para começar as aquisições, faça scan do ID do paciente ou introduza-o manualmente.',
                        style:
                            MyTextStyle(color: DefaultColors.textColorOnLight),
                        textAlign: TextAlign.center)),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.0, 30.0, 20.0, 0.0),
              child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    primary: DefaultColors.mainLColor, // background
                    //onPrimary: Colors.white, // foreground
                  ),
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
                    child: Text(barcode,
                        style:
                            MyTextStyle(color: DefaultColors.textColorOnLight),
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
                          style: MyTextStyle(
                            color: DefaultColors.textColorOnLight,
                          ),
                          controller: _idController,
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(),
                              labelText: 'ID do paciente',
                              isDense: true,
                              contentPadding: EdgeInsets.all(10)),
                          onChanged: null),
                    ),
                    IconButton(
                        icon: Icon(
                          Icons.check_circle,
                          color: DefaultColors.mainLColor,
                          size: 30,
                        ),
                        onPressed: () => setState(() => widget
                            .patientNotifier.value = _idController.text.trim()))
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
