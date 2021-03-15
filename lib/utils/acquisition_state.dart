import 'package:flutter/material.dart';
import 'package:rPiInterface/utils/default_colors.dart';

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
                ? 'A iniciar ...'
                : state == 'acquiring'
                    ? 'A adquirir dados'
                    : state == 'reconnecting'
                        ? 'A retomar ...'
                        : state == 'pairing'
                            ? 'A emparelhar dispositivos ...'
                            : state == 'paused'
                                ? 'Em pausa ...'
                                : state == 'trying'
                                    ? 'A reconectar aos dispositivos ...'
                                    : state == 'stopped'
                                        ? 'Terminada e dados gravados'
                                        : 'Desligada',
            textAlign: TextAlign.center,
            style: TextStyle(
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
                      : LightColors.kRed
            ),
          );
        });
  }
}
