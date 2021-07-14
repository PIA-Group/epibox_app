import 'package:flutter/material.dart';

class Destination {
  Destination(this.icon, this.color, this.dataMACNotifier,
      this.sensorsMACNotifier, this.channelsMACNotifier);

  final IconData icon;
  final Color color;
  final ValueNotifier<List<List>> dataMACNotifier;
  final ValueNotifier<List> sensorsMACNotifier;
  final ValueNotifier<List<List>> channelsMACNotifier;
}
