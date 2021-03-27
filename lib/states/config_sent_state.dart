import 'package:flutter/material.dart';
import 'package:rPiInterface/decor/default_colors.dart';
import 'package:rPiInterface/decor/text_styles.dart';

class ConfigSentState extends StatelessWidget {
  final ValueNotifier<bool> sentConfigNotifier;
  final double fontSize;
  ConfigSentState({this.sentConfigNotifier, this.fontSize});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: sentConfigNotifier,
        builder: (BuildContext context, bool state, Widget child) {
          return Text(state ? 'Enviado' : 'Selecione configurações',
              textAlign: TextAlign.center,
              style: MyTextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: state ? LightColors.kGreen : LightColors.kDarkBlue));
        });
  }
}
