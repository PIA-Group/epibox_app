import 'package:epibox/app_localizations.dart';
import 'package:epibox/decor/default_colors.dart';
import 'package:epibox/decor/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class AcquisitionCustomOverlay extends StatelessWidget {
  final String state;
  AcquisitionCustomOverlay({this.state, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (state == 'starting') {
      return Center(
        child: SpinKitFoldingCube(
          color: DefaultColors.mainColor,
          size: 70.0,
        ),
      );
    } else if (state == 'reconnecting') {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(
            AppLocalizations.of(context)
                    .translate('trying to resume the acquisition')
                    .inCaps +
                '...',
            textAlign: TextAlign.center,
            style: MyTextStyle(
                color: DefaultColors.textColorOnLight, fontSize: 20),
          ),
          SizedBox(height: 20),
          Center(
            child: SpinKitFoldingCube(
              color: DefaultColors.mainColor,
              size: 70.0,
            ),
          ),
          SizedBox(height: 20),
        ]),
      );
    } else if (state == 'paused') {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(
            AppLocalizations.of(context)
                    .translate('acquisition paused')
                    .inCaps +
                '!',
            textAlign: TextAlign.center,
            style: MyTextStyle(
                color: DefaultColors.textColorOnLight, fontSize: 20),
          ),
          SizedBox(height: 20),
          Text(
            AppLocalizations.of(context)
                .translate('press the button to resume')
                .inCaps,
            textAlign: TextAlign.center,
            style: MyTextStyle(
                color: DefaultColors.textColorOnLight, fontSize: 20),
          ),
          SizedBox(height: 20),
        ]),
      );
    } else if (state == 'stopped') {
      return Center(
        child: Text(
          AppLocalizations.of(context).translate('acquisition stopped').inCaps +
              '!',
          textAlign: TextAlign.center,
          style:
              MyTextStyle(color: DefaultColors.textColorOnLight, fontSize: 20),
        ),
      );
    } else {
      return Container();
    }
  }
}
