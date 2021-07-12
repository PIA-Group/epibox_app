import 'package:epibox/decor/default_colors.dart';
import 'package:epibox/decor/text_styles.dart';
import 'package:epibox/utils/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CustomOverlay extends StatelessWidget {
  MqttCurrentConnectionState connectionState;
  CustomOverlay({this.connectionState, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (connectionState == MqttCurrentConnectionState.CONNECTING) {
      return Center(
        child: SpinKitFoldingCube(
          color: DefaultColors.mainColor,
          size: 70.0,
        ),
      );
    } else if (connectionState == MqttCurrentConnectionState.CONNECTED) {
      return Center(
        child: Container(
            child: Text(
          'Conectado ao servidor!',
          style:
              MyTextStyle(color: DefaultColors.textColorOnLight, fontSize: 20),
        )),
      );
    } else if (connectionState ==
        MqttCurrentConnectionState.ERROR_WHEN_CONNECTING) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(
            'Não foi possível conectar ao servidor',
            textAlign: TextAlign.center,
            style: MyTextStyle(
                color: DefaultColors.textColorOnLight, fontSize: 20),
          ),
          SizedBox(height: 20),
          Text(
            'Verifique a conexão wifi',
            textAlign: TextAlign.center,
            style: MyTextStyle(
                color: DefaultColors.textColorOnLight, fontSize: 20),
          ),
          SizedBox(height: 20),
          /* ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: DefaultColors.mainLColor, // background
                  onPrimary: DefaultColors.textColorOnDark, // foreground
                ),
                child: Text(
                  "WIFI",
                  style: MyTextStyle(),
                ),
                onPressed: () {
                  _isDialogOpen = false;
                  AppSettings.openWIFISettings();
                  Navigator.of(context).pop();
                },
              ), */
        ]),
      );
    } else {
      return Container();
    }
  }
}
