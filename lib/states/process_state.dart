import 'package:flutter/material.dart';
import 'package:rPiInterface/decor/default_colors.dart';
import 'package:rPiInterface/decor/text_styles.dart';

class ProcessState extends StatelessWidget {
  final ValueNotifier<bool> receivedMACNotifier;
  final double fontSize;
  ProcessState({this.receivedMACNotifier, this.fontSize});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: receivedMACNotifier,
        builder: (BuildContext context, bool state, Widget child) {
          return Text(state ? 'Iniciado' : 'Não iniciado',
              textAlign: TextAlign.center,
              style: MyTextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: state ? LightColors.kGreen : LightColors.kDarkBlue));
          //fontWeight: FontWeight.bold,
        });
  }
}
