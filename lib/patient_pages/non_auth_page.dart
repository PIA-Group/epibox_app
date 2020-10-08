import 'package:flutter/material.dart';
import 'package:rPiInterface/patient_pages/login_page.dart';
import 'package:rPiInterface/patient_pages/register_page.dart';


class NonAuth extends StatefulWidget {
  @override
  _NonAuthState createState() => _NonAuthState();
}

class _NonAuthState extends State<NonAuth> {
  
  bool showSignIn = true;
  void toggleView() {
    setState(() => showSignIn = !showSignIn);
  }

  @override
  Widget build(BuildContext context) {
      return showSignIn ? LoginPage(toggleView: toggleView) : RegisterPage(toggleView: toggleView);
    
    
  }
}
