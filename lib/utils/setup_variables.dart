import 'package:flutter/material.dart';

class SetupVariables {
  ValueNotifier<String> macAddress1Notifier;
  ValueNotifier<String> macAddress2Notifier;

  ValueNotifier<bool> receivedMACNotifier;

  ValueNotifier<bool> sentMACNotifier;
  ValueNotifier<bool> sentConfigNotifier;

  SetupVariables(
    this.macAddress1Notifier,
    this.macAddress2Notifier,
  );
}
