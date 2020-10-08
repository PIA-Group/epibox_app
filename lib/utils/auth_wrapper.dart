import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rPiInterface/patient_pages/home_page.dart';
import 'package:rPiInterface/patient_pages/non_auth_page.dart';
import 'package:rPiInterface/utils/authentication.dart';

class AuthWrapper extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    // returns home or authenticate based on authentiation status
    final user = Provider.of<User>(context);
    //final mqttMessage = Provider.of<String>(context);
    print(user == null ? null : user.uid);
    return user == null
        ? NonAuth()
        : HomePage();

          
  }
}
