import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:provider/provider.dart';
import 'package:rPiInterface/bt_wrapper.dart';
import 'package:rPiInterface/non_auth_page.dart';
import 'services/authentication.dart';
import './services/bt_page.dart';

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // returns home or authenticate based on authentiation status
    final user = Provider.of<User>(context);
    final connection = Provider.of<BluetoothConnection>(context);
    print(user == null ? null : user.uid);
    return user == null
        ? NonAuth()
        : Provider<BluetoothConnection>.value(
            value: connection,
            child: BluetoothWrapper(),
          );
  }
}
