import 'package:epibox/app_localizations.dart';
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
            AppLocalizations.of(context).translate('error during').inCaps +
                ' ' +
                AppLocalizations.of(context).translate('start'),
            textAlign: TextAlign.center,
            style: MyTextStyle(
                color: DefaultColors.textColorOnLight, fontSize: 20),
          ),
          SizedBox(height: 20),
          Text(
            AppLocalizations.of(context)
                    .translate(
                        'check your connection to the server and to the acquisition devices')
                    .inCaps +
                '!',
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
            AppLocalizations.of(context)
                .translate('no ongoing acquisition')
                .inCaps,
            textAlign: TextAlign.center,
            style: MyTextStyle(
                color: DefaultColors.textColorOnLight, fontSize: 20),
          ),
          SizedBox(height: 20),
          Text(
            AppLocalizations.of(context)
                    .translate(
                        'start an acquisition before pressing the button')
                    .inCaps +
                '!',
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
