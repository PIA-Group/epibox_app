import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:async';
import 'dart:typed_data';
import 'dart:io';
import 'package:rPiInterface/utils/authentication.dart';
import 'package:screenshot/screenshot.dart';

class QRPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _QRPageState();
}

class _QRPageState extends State<QRPage> {
  final Auth _auth = Auth();

  GlobalKey globalKey = new GlobalKey();

  ScreenshotController screenshotController = ScreenshotController();

  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bodyHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      key: globalKey,
      appBar: AppBar(
        title: Text('Código QR'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.share),
            onPressed: _captureAndShare,
          ),
        ],
      ),
      body: Center(
        child: RepaintBoundary(
          child: FutureBuilder(
              future: _auth.getCurrentUserStr(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Screenshot(
                    controller: screenshotController,
                    child: 
                    Container(
                      color: Colors.white,
                      child: QrImage(
                      data: snapshot.data,
                      size: 0.5 * bodyHeight,
                      /* onError: (ex) {
                              print("[QR] ERROR - $ex");
                              setState((){
                                _inputErrorText = "Error! Maybe your input value is too long?";
                              });
                            }, */
                    ),
                  ),);
                } else {
                  return CircularProgressIndicator();
                }
              }),
        ),
      ),
    );
  }

  Future<void> _captureAndShare() async {
    try {
      screenshotController
          .capture(pixelRatio: 1.5, delay: Duration(milliseconds: 10))
          .then((File image) async {
            Uint8List pngBytes = image.readAsBytesSync().buffer.asUint8List();
            await Share.file('esys image', 'esys.png', pngBytes, 'image/png');
      });
    } catch (e) {
      print('error');
      print(e);
    }
  }

  /* Future<void> _captureAndSharePng() async {
    try {
      RenderRepaintBoundary boundary =
          globalKey.currentContext.findRenderObject();
      print('here');
      var image = await boundary.toImage();
      print('here2');
      ByteData byteData = await image.toByteData(format: ImageByteFormat.png);
      print('here3');
      Uint8List pngBytes = byteData.buffer.asUint8List();
      print('here4');

      await Share.file('esys image', 'esys.png', pngBytes, 'image/png');
      print('here5');
      /* final tempDir = await getTemporaryDirectory();
      final file = await new File('${tempDir.path}/image.png').create();
      await file.writeAsBytes(pngBytes);

      final channel = const MethodChannel('channel:me.alfian.share/share');
      channel.invokeMethod('shareFile', 'image.png'); */

    } catch (e) {
      print('here6');
      print(e.toString());
    }
  } */
}
