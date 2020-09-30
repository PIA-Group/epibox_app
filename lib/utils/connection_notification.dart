
import 'package:flutter/material.dart';
import 'package:rPiInterface/utils/models.dart';

class NewConnectionNotification extends Notification {
  final MqttCurrentConnectionState newConnection;

  const NewConnectionNotification({this.newConnection});
}