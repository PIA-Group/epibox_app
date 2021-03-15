import 'package:flutter/material.dart';
import 'package:rPiInterface/utils/models.dart';
import 'package:rPiInterface/utils/default_colors.dart';

class ServerState extends StatelessWidget {
  final ValueNotifier<MqttCurrentConnectionState> connectionNotifier;
  final double fontSize;
  ServerState({this.connectionNotifier, this.fontSize});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: connectionNotifier,
        builder: (BuildContext context, MqttCurrentConnectionState state,
            Widget child) {
          return Text(
              state == MqttCurrentConnectionState.CONNECTED
                  ? 'Conectado'
                  : state == MqttCurrentConnectionState.CONNECTING
                      ? 'A conectar...'
                      : 'Disconectado',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: state == MqttCurrentConnectionState.CONNECTED
                    ? LightColors.kGreen
                    : state == MqttCurrentConnectionState.CONNECTING
                        ? LightColors.kDarkYellow
                        : LightColors.kRed,
                fontSize: fontSize,
              ));
        });
  }
}
