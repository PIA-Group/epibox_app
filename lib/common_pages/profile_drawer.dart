import 'package:flutter/material.dart';
import 'package:rPiInterface/hospital_pages/configurations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileDrawer extends StatefulWidget {
  ValueNotifier<String> patientNotifier;
  TextEditingController nameController;
  ValueNotifier<List> annotationTypesD;

  ProfileDrawer({
    this.patientNotifier,
    this.nameController,
    this.annotationTypesD,
  });

  @override
  _ProfileDrawerState createState() => _ProfileDrawerState();
}

class _ProfileDrawerState extends State<ProfileDrawer> {

  List<String> annotationTypesS;
  @override
  void initState() {
    super.initState();
    annotationTypesS = List<String>.from(widget.annotationTypesD.value);
  }

  /* void _submitNewName(String uid, username) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> user = (prefs.getStringList(uid) ?? []);
      setState(() => prefs.setStringList(uid, [username, user[1]]));
    } catch (e) {
      print(e);
    }
  } */

  /* Future<String> getUserName(uid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      List<String> user = (prefs.getStringList(uid) ?? []);
      //print('UserName: ${user[0]}');
      return user[0];
    } catch (e) {
      print(e);
      setState(
          () => prefs.setStringList(uid, ['Não definido', 'images/owl.jpg']));
      return 'Não definido';
    }
  } */

  /* Future<String> _getAvatar(uid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      List<String> user = (prefs.getStringList(uid) ?? []);
      //print('avatar: ${user[1]}');
      return user[1];
    } catch (e) {
      print(e);
      setState(
          () => prefs.setStringList(uid, ['Não definido', 'images/owl.jpg']));
      return 'images/owl.jpg';
    }
  } */

  void _updateAnnotations() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('annotationTypes', annotationTypesS);
    print('removed annot');
  }

  Iterable<Widget> get annotationsWidgets sync* {
    for (String annot in annotationTypesS) {
      yield Padding(
        padding: const EdgeInsets.all(4.0),
        child: Chip(
          label: Text(annot),
          onDeleted: () {
            setState(() {
              annotationTypesS.removeWhere((String entry) {
                return entry == annot;
              });
            });
            setState(() => widget.annotationTypesD.value.remove(annot));
            _updateAnnotations();
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Drawer(
      child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  CircleAvatar(
                      radius: 40.0,
                      backgroundImage: AssetImage('images/owl.jpg')),
                  /* FutureBuilder(
                        future: _getAvatar(widget.patientNotifier.value),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return CircleAvatar(
                                radius: 40.0,
                                backgroundImage: AssetImage(snapshot.data));
                          } else {
                            return CircularProgressIndicator();
                          }
                        }), */
                  Text('ID:',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        decoration: TextDecoration.underline,
                      )),
                  Text(widget.patientNotifier.value,
                      style: TextStyle(color: Colors.white, fontSize: 14)),
                ],
              ),
            ),
            /* Padding(
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
                              color: Colors.grey[600],
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          FutureBuilder(
                            future: getUserName(widget.patientNotifier.value),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                return Text(
                                  '${snapshot.data}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                );
                              } else {
                                return CircularProgressIndicator();
                              }
                            },
                          ),
                        ]),
                  ),
                ),
              ), */
            /* Padding(
                padding: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 0.0),
                child: Container(
                  height: 130.0,
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
                                  labelText: "Novo nome",
                                  isDense: true),
                              controller: widget.nameController,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                            child: RaisedButton(
                              onPressed: () {
                                _submitNewName(widget.patientNotifier.value,
                                    widget.nameController.text.trim());
                                setState(() => widget.nameController.text = " ");
                                Navigator.pop(context);
                              },
                              child: new Text("Submeter"),
                            ),
                          ),
                        ]),
                  ),
                ),
              ), */
            Padding(
              padding: EdgeInsets.fromLTRB(
                  width - 0.9 * width, 50.0, width - 0.9 * width, 50.0),
              child: RaisedButton.icon(
                label: Text(
                  'Sign out',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                icon: Icon(
                  Icons.person,
                  color: Colors.grey[600],
                ),
                onPressed: () {
                  setState(() {
                    widget.patientNotifier.value = null;
                    Navigator.pop(context);
                  });
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                  width - 0.9 * width, 0.0, width - 0.9 * width, 0.0),
              child: Text('Tipos de Anotações:',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    decoration: TextDecoration.underline,
                  )),
              /* child: RaisedButton.icon(
                label: Text(
                  'Configurações',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                icon: Icon(
                  Icons.settings,
                  color: Colors.grey[600],
                ),
                onPressed: () {
                  //print(annotationTypesD.value);
                  Navigator.of(context).push(new MaterialPageRoute<Null>(
                      builder: (BuildContext context) {
                        return ConfigurationsDialog(
                          annotationTypesD: widget.annotationTypesD,
                        );
                      },
                      fullscreenDialog: true));
                },
              ), */
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                  width - 0.95 * width, 10.0, width - 0.95 * width, 0.0),
              child: Container(
                color: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey[200], offset: new Offset(5.0, 5.0))
                    ],
                  ),
                  child: Padding(
                      padding: EdgeInsets.only(left: 10.0, right: 10.0),
                      child: Wrap(
                        children: annotationsWidgets.toList(),
                      )),
                ),
              ),
            )
          ]),
    );
  }
}
