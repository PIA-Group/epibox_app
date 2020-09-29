import 'package:flutter/material.dart';
import 'package:rPiInterface/authentication.dart';
import 'package:rPiInterface/auth_wrapper.dart';
import 'package:provider/provider.dart';

void main() => runApp(new InterfaceRPi());

class InterfaceRPi extends StatelessWidget {
  
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // Provider allows to make available information (eg: Stream) to all of its descendents
    return StreamProvider<User>.value(
      value: Auth().user,
      child: MaterialApp(
          title: 'Aquisição de biossinais',
          debugShowCheckedModeBanner: false,
          home: AuthWrapper(),
        ),
    );
  }
}
