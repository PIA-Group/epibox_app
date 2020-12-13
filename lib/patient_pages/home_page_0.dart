
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:rPiInterface/patient_pages/qr_page.dart';
import 'package:rPiInterface/utils/authentication.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class HomePage0 extends StatefulWidget {
  @override
  _HomePage0State createState() => _HomePage0State();
}

class _HomePage0State extends State<HomePage0> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();



  final Auth _auth = Auth();
  final firestoreInstance = Firestore.instance;

  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = " ";
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<String> currentUserID() async {
    var firebaseUser = await FirebaseAuth.instance.currentUser();
    return firebaseUser.uid;
  }

  Future<DocumentSnapshot> getUserName(uid) {
    return firestoreInstance.collection("users").document(uid).get();
  }

  void _submitNewProfile(_newName) async {
    var firebaseUser = await FirebaseAuth.instance.currentUser();
    firestoreInstance
        .collection("users")
        .document(firebaseUser.uid)
        .setData({"userName": _newName}, merge: true).then((_) {
      print("New profile submitted!!");
    });
  }

  Future<void> _showAvatars() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Escolher novo avatar'),
          content: SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
                          onTap: () {
                            _setAvatar('images/owl.jpg');
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          child: CircleAvatar(
                            radius: 30.0,
                            backgroundImage: AssetImage('images/owl.jpg'),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            _setAvatar('images/penguin.jpg');
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          child: CircleAvatar(
                            radius: 30.0,
                            backgroundImage: AssetImage('images/penguin.jpg'),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            _setAvatar('images/pig.jpg');
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          child: CircleAvatar(
                            radius: 30.0,
                            backgroundImage: AssetImage('images/pig.jpg'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                        onTap: () {
                          _setAvatar('images/fox.jpg');
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        child: CircleAvatar(
                          radius: 30.0,
                          //backgroundColor: Colors.blue[300],
                          backgroundImage: AssetImage('images/fox.jpg'),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          _setAvatar('images/dog.jpg');
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        child: CircleAvatar(
                          radius: 30.0,
                          //backgroundColor: Colors.blue[300],
                          backgroundImage: AssetImage('images/dog.jpg'),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          _setAvatar('images/cat.jpg');
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        child: CircleAvatar(
                          radius: 30.0,
                          backgroundImage: AssetImage('images/cat.jpg'),
                        ),
                      ),
                    ],
                  ),
                ]),
          ),
          actions: <Widget>[],
        );
      },
    );
  }

  Future<DocumentSnapshot> _getAvatar(uid) async {
    return firestoreInstance.collection("users").document(uid).get();
  }

  void _setAvatar(_avatar) async {
    var firebaseUser = await FirebaseAuth.instance.currentUser();
    firestoreInstance
        .collection("users")
        .document(firebaseUser.uid)
        .setData({"avatar": _avatar}, merge: true).then((_) {
      print("New avatar submitted!!");
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    FutureBuilder(
                        future: currentUserID(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return FutureBuilder(
                                future: _getAvatar(snapshot.data),
                                builder: (context, snapshot2) {
                                  if (snapshot2.connectionState ==
                                      ConnectionState.done) {
                                    return InkWell(
                                      onTap: () {
                                        _showAvatars();
                                      },
                                      child: CircleAvatar(
                                          radius: 40.0,
                                          backgroundImage: AssetImage(
                                              snapshot2.data.data["avatar"])),
                                    );
                                  } else {
                                    return CircularProgressIndicator();
                                  }
                                });
                          } else {
                            return CircularProgressIndicator();
                          }
                        }),
                    Text('ID:',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          decoration: TextDecoration.underline,
                        )),
                    FutureBuilder(
                        future: _auth.getCurrentUserStr(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return Text('${snapshot.data}',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16));
                          } else {
                            return CircularProgressIndicator();
                          }
                        }),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Nome: ',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.grey[600]),
                          ),
                          FutureBuilder(
                              future: currentUserID(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  return FutureBuilder(
                                      future: getUserName(snapshot.data),
                                      builder: (context, snapshot2) {
                                        if (snapshot2.connectionState ==
                                            ConnectionState.done) {
                                          return Text(
                                            '${snapshot2.data.data["userName"]}',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: Colors.grey[600]),
                                          );
                                        } else {
                                          return CircularProgressIndicator();
                                        }
                                      });
                                } else {
                                  return CircularProgressIndicator();
                                }
                              }),
                        ]),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(10.0, 50.0, 10.0, 0.0),
                child: Container(
                  height: 150.0,
                  width: 200.0,
                  color: Colors.transparent,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey[200],
                            offset: new Offset(5.0, 5.0))
                      ],
                    ),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
                            child: TextField(
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: "Novo nome"),
                              controller: _nameController,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                            child: RaisedButton(
                              onPressed: () {
                                _submitNewProfile(_nameController.text.trim());
                                setState(() => _nameController.text = " ");
                                Navigator.pop(context);
                              },
                              child: new Text("Submeter"),
                            ),
                          ),
                        ]),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0),
                child: FlatButton.icon(
                  label: Text(
                    'Gerar código QR',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  icon: Icon(
                    MdiIcons.qrcode,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return QRPage();
                    }));
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    width - 0.9 * width, 50, width - 0.9 * width, 50),
                child: RaisedButton.icon(
                  label: Text(
                    'Sign out',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  icon: Icon(
                    Icons.person,
                    color: Colors.grey[600],
                  ),
                  onPressed: () async {
                    await _auth.signOut();
                  },
                ),
              )
            ]),
      ),
      appBar: new AppBar(title: new Text('EpiBox')),
      body: ListView(children: <Widget>[
        Padding(
              padding: EdgeInsets.only(top: 70.0),
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  child: RichText(
                      textAlign: TextAlign.justify,
                      text: TextSpan(children: [
                        TextSpan(
                            text: 'Bem vindo ao  ',
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[600])),
                        TextSpan(
                            text: 'EpiBox',
                            style: TextStyle(
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600])),
                        TextSpan(
                            text: '!',
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[600])),
                      ])),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
              child: Align(
                alignment: Alignment.center,
                child: Container(
                    child: Text(
                        'De momento, as features para os pacientes ainda se encontram em desenvolvimento. No entanto, é possível configurar o perfil (incluindo o nome e avatar!) e criar um código QR com o ID.',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        textAlign: TextAlign.justify)),
              ),
            ),
      ]),
      
    );
  }
}