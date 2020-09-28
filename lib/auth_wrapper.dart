import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rPiInterface/non_auth_page.dart';
import 'package:rPiInterface/test.dart';
import 'package:rPiInterface/test2.dart';
import 'home_page.dart';
import './mqtt_state.dart';
import 'services/authentication.dart';


class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // returns home or authenticate based on authentiation status
    final user = Provider.of<User>(context);
    print(user == null ? null : user.uid);
    return user == null
        ? NonAuth()
        : ChangeNotifierProvider<MQTTAppState>(
        create: (_) => MQTTAppState(),
        child: MQTTView(),);
          
  }
}
