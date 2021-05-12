import 'package:flutter/material.dart';
import 'package:epibox/states/battery_state.dart';

class ExpandedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String text1;
  final Widget state1;
  final String text2;
  final Widget state2;
  final ValueNotifier<double> batteryBit1Notifier;
  final ValueNotifier<double> batteryBit2Notifier;

  ExpandedAppBar(
      {this.title,
      this.text1,
      this.state1,
      this.text2,
      this.state2,
      this.batteryBit1Notifier,
      this.batteryBit2Notifier});

  @override
  Size get preferredSize => const Size.fromHeight(100);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      /* shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(10),
        ),
      ), */
      elevation: 4,
      flexibleSpace: Padding(
        padding: EdgeInsets.only(top: 32),
        child: Column(children: [
          Row(children: [
            Container(
              width: MediaQuery.of(context).size.width - 50,
              child: Padding(
                padding: EdgeInsets.only(left: 50),
                child: Container(
                  height: 40,
                  child: Card(
                    child: Center(
                      child: state1,
                    ),
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ),
            BatteryState(mac: '1', batteryNotifier: batteryBit1Notifier),
          ]),
          SizedBox(height: 5),
          Row(children: [
            Container(
              width: MediaQuery.of(context).size.width - 50,
              child: Padding(
                padding: EdgeInsets.only(left: 20),
                child: Container(
                  height: 40,
                  // width: double.infinity,
                  child: Card(
                    child: Center(
                      child: state2,
                    ),
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ),
            BatteryState(mac: '2', batteryNotifier: batteryBit2Notifier),
          ]),
        ]),
      ),
    );
  }
}
