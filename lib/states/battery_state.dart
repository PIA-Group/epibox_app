import 'package:flutter/material.dart';
import 'package:epibox/decor/text_styles.dart';
import 'package:epibox/utils/battery_indicator.dart';

class BatteryState extends StatelessWidget {
  final String mac;
  final ValueNotifier<double> batteryNotifier;
  BatteryState({this.mac, this.batteryNotifier});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: batteryNotifier,
      builder: (BuildContext context, double battery, Widget child) {
        return battery != null
            ? Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                Text(
                  '$mac:',
                  style: MyTextStyle(),
                ),
                SizedBox(
                  width: 30.0,
                  height: 27.0,
                  child: new Center(
                    child: BatteryIndicator(
                      style: BatteryIndicatorStyle.skeumorphism,
                      batteryLevel: battery,
                    ),
                  ),
                ),
              ])
            : SizedBox.shrink();
      },
    );
  }
}
