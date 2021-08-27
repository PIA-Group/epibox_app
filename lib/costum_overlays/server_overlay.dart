import 'package:epibox/decor/default_colors.dart';
import 'package:epibox/decor/text_styles.dart';
import 'package:epibox/mqtt/mqtt_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ServerCustomOverlay extends StatelessWidget {
  final MqttCurrentConnectionState connectionState;
  ServerCustomOverlay({this.connectionState, Key key}) : super(key: key);

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
        ]),
      );
    } else {
      return Container();
    }
  }
}
