import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:provider/provider.dart';
import './home_page.dart';
import './services/bt_page.dart';

class BluetoothWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final connection = Provider.of<BluetoothConnection>(context);
    print(connection.toString());
    return connection == null ? BluetoothPage(): HomePage();
  }
}