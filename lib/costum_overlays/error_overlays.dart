import 'package:epibox/decor/default_colors.dart';
import 'package:epibox/decor/text_styles.dart';
import 'package:flutter/material.dart';


class VerifyConnectionsOverlay extends StatelessWidget {
  VerifyConnectionsOverlay();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(
            'Não foi possível iniciar',
            textAlign: TextAlign.center,
            style: MyTextStyle(
                color: DefaultColors.textColorOnLight, fontSize: 20),
          ),
          SizedBox(height: 20),
          Text(
            'Verifique a conexão ao servidor e aos dispositivos de aquisição!',
            textAlign: TextAlign.center,
            style: MyTextStyle(
                color: DefaultColors.textColorOnLight, fontSize: 20),
          ),
          SizedBox(height: 20),
        ]),
      ),
    );
  }
}


class NotAcquiringOverlay extends StatelessWidget {
  NotAcquiringOverlay();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(
            'Não se encontra nenhuma aquisição a decorrer',
            textAlign: TextAlign.center,
            style: MyTextStyle(
                color: DefaultColors.textColorOnLight, fontSize: 20),
          ),
          SizedBox(height: 20),
          Text(
            'Inicie uma aquisição antes de pressionar o botão de pausa!',
            textAlign: TextAlign.center,
            style: MyTextStyle(
                color: DefaultColors.textColorOnLight, fontSize: 20),
          ),
          SizedBox(height: 20),
        ]),
      ),
    );
  }
}
