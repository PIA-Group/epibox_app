import 'package:flutter/material.dart';
import 'package:rPiInterface/utils/default_colors.dart';

class SentMACState extends StatelessWidget {
  final ValueNotifier<bool> sentMACNotifier;
  final double fontSize;
  SentMACState({this.sentMACNotifier, this.fontSize});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: sentMACNotifier,
        builder: (BuildContext context, bool state, Widget child) {
          return Text(
              state ? 'Enviado' : 'Selecione dispositivos',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: state ? LightColors.kGreen : LightColors.kDarkBlue));
        });
  }
}
