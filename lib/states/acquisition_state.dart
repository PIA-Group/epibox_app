import 'package:flutter/material.dart';
import 'package:epibox/decor/default_colors.dart';
import 'package:epibox/decor/text_styles.dart';

class AcquisitionState extends StatelessWidget {
  final ValueNotifier<String> acquisitionNotifier;
  final double fontSize;
  AcquisitionState({this.acquisitionNotifier, this.fontSize});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: acquisitionNotifier,
        builder: (BuildContext context, String state, Widget child) {
          return Text(
            state == 'starting'
                ? 'A iniciar aquisição...'
                : state == 'acquiring'
                    ? 'A adquirir dados'
                    : state == 'reconnecting'
                        ? 'A retomar aquisição ...'
                        : state == 'pairing'
                            ? 'A emparelhar dispositivos ...'
                            : state == 'paused'
                                ? 'Aquisição em pausa ...'
                                : state == 'trying'
                                    ? 'A reconectar aos dispositivos ...'
                                    : state == 'stopped'
                                        ? 'Aquisição terminada'
                                        : 'Aquisição desligada',
            textAlign: TextAlign.center,
            style: MyTextStyle(
                fontWeight: FontWeight.bold,
                fontSize: fontSize,
                color: state == 'acquiring'
                    ? LightColors.kGreen
                    : (state == 'starting' ||
                            state == 'reconnecting' ||
                            state == 'trying' ||
                            state == 'pairing' ||
                            state == 'paused')
                        ? LightColors.kDarkYellow
                        : LightColors.kRed),
          );
        });
  }
}
