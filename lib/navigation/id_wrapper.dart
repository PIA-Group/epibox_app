import 'package:epibox/navigation/navigation_page.dart';
import 'package:flutter/material.dart';
import 'package:epibox/user-pages/scan_page.dart';

class IDWrapper extends StatelessWidget {
  /* This class listens to changes in the variable "patientNotifier".
  It sends the user into the ScanPage (login page) if it is null or the
  NavigationPage (home page) if is is not null */

  final ValueNotifier<String> patientNotifier = ValueNotifier(null);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: patientNotifier,
        builder: (BuildContext context, String state, Widget child) {
          return patientNotifier.value == null
              ? ScanPage(patientNotifier: patientNotifier)
              : NavigationPage(patientNotifier: patientNotifier);
        });
  }
}
