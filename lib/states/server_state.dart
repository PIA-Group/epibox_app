import 'package:flutter/material.dart';
import 'package:epibox/decor/text_styles.dart';
import 'package:epibox/utils/models.dart';
import 'package:epibox/decor/default_colors.dart';

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
                  ? 'Conectado ao servidor'
                  : state == MqttCurrentConnectionState.CONNECTING
                      ? 'A conectar...'
                      : 'Desconectado do servidor',
              textAlign: TextAlign.center,
              style: MyTextStyle(
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
