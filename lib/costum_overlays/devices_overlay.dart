import 'package:epibox/decor/default_colors.dart';
import 'package:epibox/decor/text_styles.dart';
import 'package:flutter/material.dart';

class DevicesCustomOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(
            'Não foi possível conectar',
            textAlign: TextAlign.center,
            style: MyTextStyle(
                color: DefaultColors.textColorOnLight, fontSize: 20),
          ),
          SizedBox(height: 20),
          Text(
            'Verifique a conexão ao servidor!',
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
