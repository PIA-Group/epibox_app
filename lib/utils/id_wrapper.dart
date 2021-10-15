import 'package:epibox/navigation/navigation_page.dart';
import 'package:flutter/material.dart';
import 'package:epibox/pages/scan_page.dart';

class IDWrapper extends StatelessWidget {
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
