import 'package:flutter/material.dart';
import 'package:rPiInterface/utils/authentication.dart';
import 'package:rPiInterface/utils/loading_icon.dart';

class LoginPage extends StatefulWidget {
  
  final Function toggleView;
  LoginPage({this.toggleView});
  
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  
  String _email = '';
  String _password = '';
  String _error = '';
  bool _loading = false;

  final Auth _auth = Auth();
  User result;
  final _formKey = GlobalKey<FormState>();

  /* User _userFromFirebaseUser(FirebaseUser user) {
    return user != null ? User(uid: user.uid) : null;
  } */

  Widget showEmailInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 100.0, 0.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'Email',
            icon: new Icon(
              Icons.mail,
              color: Colors.grey,
            )),
        validator: (value) => value.isEmpty ? 'Email não pode estar vazio' : null,
        onChanged: (value) {
          setState(() {
            _email = value.trim();
          });
        }
      ),
    );
  }

  Widget showPasswordInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        obscureText: true,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'Password',
            icon: new Icon(
              Icons.lock,
              color: Colors.grey,
            )),
        validator: (value) => value.isEmpty ? 'Password não pode estar vazia' : null,
        onChanged: (value) {
          setState((){
            _password = value.trim();
          });
        }
      ),
    );
  }

  Widget showPrimaryButton() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
        child: SizedBox(
          height: 40.0,
          child: new RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.blue,
            child: new Text('Login',
                style: new TextStyle(fontSize: 20.0, color: Colors.white)),
            onPressed: () async {
              if (_formKey.currentState.validate()) {
                setState(() => _loading = true);
                await _auth.signIn(_email, _password);
                //result = _userFromFirebaseUser(await _auth.getCurrentUser());
                //result = await _auth.getCurrentUser();
                if (result == null) {
                  setState(() {
                    _error = 'Credenciais incorretas!';
                    _loading = false;
                  });
                } else {
                  setState(() {
                    _error = '';
                    _loading = false;
                  });
                }
              }
            }),
          ),
        );
  }

  Widget showSecondaryButton() {
    return FlatButton(
        child: new Text('Ainda não tem conta? Registar',
            style: new TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300)),
        onPressed: () => widget.toggleView());
  }

  Widget showErrorMessage() {
    return Text(_error,
    textAlign: TextAlign.center,
    style: TextStyle(color: Colors.red.withOpacity(0.6)));
    // add error message if network connection fails
  }

  @override
  Widget build(BuildContext context) {
    return _loading ? LoadingIcon() : Scaffold(
      appBar: new AppBar(
        title: new Text('PreEpiSeizures'),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: new Form(
          key: _formKey,
          child: new ListView(
            shrinkWrap: true,
            children: <Widget>[
              showEmailInput(),
              showPasswordInput(),
              showPrimaryButton(),
              showSecondaryButton(),
              showErrorMessage(),
            ],
          ),
        ),
      ),
    );
  }
}
