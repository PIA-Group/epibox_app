import 'dart:async';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:epibox/decor/text_styles.dart';
import 'package:epibox/pages/instructions_H.dart';
import 'package:epibox/decor/default_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScanPage extends StatefulWidget {
  final ValueNotifier<String> patientNotifier;
  ScanPage({this.patientNotifier});

  @override
  _ScanPageState createState() => new _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final TextEditingController _idController = TextEditingController();
  String barcodeError = "";

  @override
  initState() {
    super.initState();
    //var timeStamp = DateTime.now();
    _getIdTemplate();
    /* _idController.text =
        '${timeStamp.day}_${timeStamp.month}_${timeStamp.year}'; */
  }

  void _getIdTemplate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _idTemplate;
    try {
      _idTemplate = prefs.getString('id_template').toString() ?? '';
      setState(() => _idController.text = _idTemplate);
    } catch (e) {
      print(e);
    }
  }

  Future<void> _updateIdTemplate() async {
    await SharedPreferences.getInstance().then((prefs) async {
      await prefs.setString('id_template', _idController.text);
    });
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
            bottom: Radius.circular(10),
          ),
        ),
        title: new Text(
          'Bem vindo ao EpiBOX!',
          style: MyTextStyle(
            fontSize: 18,
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
                  label: const Text(
                    'INICIAR SCAN',
                    style: MyTextStyle(fontSize: 14),
                  )),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
              child: Align(
                alignment: Alignment.center,
                child: Container(
                    child: Text(barcodeError,
                        style: MyTextStyle(color: Colors.grey[500]),
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
                              contentPadding: EdgeInsets.all(10)),
                          onChanged: null),
                    ),
                    IconButton(
                        icon: Icon(
                          Icons.check_circle,
                          color: DefaultColors.mainLColor,
                          size: 30,
                        ),
                        onPressed: () {
                          setState(() => widget.patientNotifier.value =
                              _idController.text.trim());
                          _updateIdTemplate();
                        })
                  ],
                )),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
          //mini: true,
          label: Text(
            'Instruções',
            style: MyTextStyle(fontSize: 14),
          ),
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
        setState(
            () => this.barcodeError = 'ID: ${widget.patientNotifier.value}');
      }
      print('HERE: ${notifier.value}');
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.cameraAccessDenied) {
        setState(() {
          this.barcodeError = 'É necessário permissão para aceder à camera!';
        });
      } else {
        setState(() => this.barcodeError = 'Unknown error: $e');
      }
    } on FormatException {
      print('HERE: ${notifier.value}');
      setState(() => notifier.value = null);
      setState(() => this.barcodeError = 'Scan não completo.');
    } catch (e) {
      setState(() => this.barcodeError = 'Unknown error: $e');
    }
  }
}
