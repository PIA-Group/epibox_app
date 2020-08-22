import 'package:flutter/material.dart';
import 'login_page.dart';
import 'register_page.dart';

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
    
    // return new Scaffold(
    //     appBar: new AppBar(
    //       title: new Text('Aquisição de biossinais'),
    //     ),
    //     body: Center(
    //       child: Column(
    //         mainAxisSize: MainAxisSize.min,
    //         children: <Widget>[
    //           Padding(
    //             padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
    //             child: SizedBox(
    //               height: 40.0,
    //               width: 380,
    //               child: new RaisedButton(
    //                   elevation: 5.0,
    //                   shape: new RoundedRectangleBorder(
    //                       borderRadius: new BorderRadius.circular(30.0)),
    //                   color: Colors.blue,
    //                   child: new Text('Login',
    //                       style: new TextStyle(
    //                           fontSize: 20.0, color: Colors.white)),
    //                   onPressed: () {
    //                     Navigator.push(
    //                       context,
    //                       MaterialPageRoute(builder: (context) => LoginPage()),
    //                     );
    //                   }),
    //             ),
    //           ),
    //           FlatButton(
    //             onPressed: () {
    //               Navigator.push(
    //                 context,
    //                 MaterialPageRoute(builder: (context) => RegisterPage()),
    //               );
    //             },
    //             child:
    //                 Text('Create an account', style: TextStyle(fontSize: 20)),
    //           ),
    //         ],
    //       ),
    //     ));
  }
}
