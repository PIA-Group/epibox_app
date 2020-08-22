import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:rPiInterface/services/authentication.dart';
import 'package:rPiInterface/auth_wrapper.dart';
import 'package:provider/provider.dart';

void main() => runApp(new InterfaceRPi());

class InterfaceRPi extends StatelessWidget {
  
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // Provider allows to make available information (eg: Stream) to all of its descendents
    BluetoothConnection connection;
    return StreamProvider<User>.value(
      value: Auth().user,
      child: Provider<BluetoothConnection>.value(
        value: connection,
        child: MaterialApp(
          title: 'Aquisição de biossinais',
          debugShowCheckedModeBanner: false,
          home: AuthWrapper(),
        ),
      ),
    );
  }
}
