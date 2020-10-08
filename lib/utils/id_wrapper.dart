import 'package:flutter/material.dart';
import 'package:rPiInterface/hospital_pages/home_H_page.dart';
import 'package:rPiInterface/hospital_pages/scan_page.dart';

class IDWrapper extends StatelessWidget {
  ValueNotifier<String> patientNotifier = ValueNotifier(null);
  @override
  Widget build(BuildContext context) {
    //final mqttMessage = Provider.of<String>(context);
    print(patientNotifier.value == null ? null : patientNotifier.value);
    return ValueListenableBuilder(
        valueListenable: patientNotifier,
        builder: (BuildContext context, String state, Widget child) {
          return patientNotifier.value == null
              ? ScanPage(
                  patientNotifier: patientNotifier,
                )
              : HomeHPage(patientNotifier: patientNotifier,);
        });
  }
}
