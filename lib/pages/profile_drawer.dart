import 'package:flutter/material.dart';
import 'package:rPiInterface/decor/default_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rPiInterface/decor/text_styles.dart';

class ProfileDrawer extends StatefulWidget {
  ValueNotifier<String> patientNotifier;
  TextEditingController nameController;
  ValueNotifier<List> annotationTypesD;
  ValueNotifier<List<String>> historyMAC;

  ProfileDrawer({
    this.patientNotifier,
    this.nameController,
    this.annotationTypesD,
    this.historyMAC,
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

  void _updateAnnotations() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('annotationTypes', annotationTypesS);
    print('removed annot');
  }

  void _updateHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('historyMAC', widget.historyMAC.value);
    print('removed MAC');
  }

  Iterable<Widget> get annotationsWidgets sync* {
    for (String annot in annotationTypesS) {
      yield Padding(
        padding: const EdgeInsets.all(4.0),
        child: Chip(
          deleteIconColor: Colors.white,
          backgroundColor: DefaultColors.mainLColor,
          label: Text(annot,
              style: MyTextStyle(
                fontSize: 16,
              )),
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

  Iterable<Widget> get historyWidgets sync* {
    for (String mac in widget.historyMAC.value) {
      if (mac != ' ') {
        yield Padding(
          padding: const EdgeInsets.all(4.0),
          child: Chip(
            deleteIconColor: Colors.white,
            backgroundColor: DefaultColors.mainLColor,
            label: Text(mac,
                style: MyTextStyle(
                  fontSize: 16,
                )),
            onDeleted: () {
              setState(() {
                widget.historyMAC.value.removeWhere((String entry) {
                  return entry == mac;
                });
              });
              //setState(() => widget.annotationTypesD.value.remove(annot));
              _updateHistory();
            },
          ),
        );
      }
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
                color: DefaultColors.mainColor,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  CircleAvatar(
                      radius: 40.0,
                      backgroundImage: AssetImage('images/owl.jpg')),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('ID:  ',
                        style: MyTextStyle(
                          fontSize: 18,
                        )),
                    Text(widget.patientNotifier.value,
                        style: MyTextStyle(
                          fontSize: 18,
                        )),
                  ]),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                  width - 0.9 * width, 20, width - 0.9 * width, 0.0),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  primary: Colors.grey[200], // background
                  onPrimary: Colors.grey[600], // foreground
                ),
                label: Text(
                  'Sign out',
                  style: MyTextStyle(fontSize: 16, color: DefaultColors.textColorOnLight),
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
                  width - 0.9 * width, 20.0, width - 0.9 * width, 0.0),
              child: Text('Tipos de Anotações:',
                  style: MyTextStyle(
                    color: DefaultColors.textColorOnLight,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    decoration: TextDecoration.underline,
                  )),
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
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                  width - 0.9 * width, 20.0, width - 0.9 * width, 0.0),
              child: Text('Histórico de dispositivos:',
                  style: MyTextStyle(
                    color: DefaultColors.textColorOnLight,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    decoration: TextDecoration.underline,
                  )),
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
                        children: historyWidgets.toList(),
                      )),
                ),
              ),
            )
          ]),
    );
  }
}
