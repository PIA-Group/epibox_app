import 'package:flutter/material.dart';
import 'package:rPiInterface/services/authentication.dart';
import './loading_icon.dart';

class RegisterPage extends StatefulWidget {
 
  final Function toggleView;
  RegisterPage({this.toggleView});
  
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String _email;
  String _password;
  bool _loading = false;
  final Auth _auth = Auth();
  final _formKey = GlobalKey<FormState>();


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
        validator: (value) => value.length < 6 ? 'Por favor escolher uma password com 6+ caracteres' : null,
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
            child: new Text('Registar',
                style: new TextStyle(fontSize: 20.0, color: Colors.white)),
            onPressed: () async {
              if (_formKey.currentState.validate()) {
                setState(() => _loading = true);
                await _auth.signUp(_email, _password);
                setState(() {
                  _loading = false;
                });
              }
            }),
          ),
        );
  }


  Widget showSecondaryButton() {
    return new FlatButton(
        child: new Text('Já tem conta? Login',
            style: new TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300)),
        onPressed: () {
          widget.toggleView();
        });
  }

  @override
  Widget build(BuildContext context) {
    return _loading ? LoadingIcon() : Scaffold(
      appBar: new AppBar(
        title: new Text('Aquisição de biossinais'),
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
              //showErrorMessage(),
            ],
          ),
        ),
      ),
    );
  }
}
