import 'package:epibox/app_localizations.dart';
import 'package:epibox/decor/default_colors.dart';
import 'package:epibox/decor/text_styles.dart';
import 'package:flutter/material.dart';

class SystemCustomOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(
            AppLocalizations.of(context).translate('EpiBOX Core turned off') +
                '!',
            textAlign: TextAlign.center,
            style: MyTextStyle(
                color: DefaultColors.textColorOnLight, fontSize: 20),
          ),
        ]),
      ),
    );
  }
}
