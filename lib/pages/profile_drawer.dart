import 'package:epibox/utils/mqtt_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:epibox/decor/default_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:epibox/decor/text_styles.dart';

class ProfileDrawer extends StatefulWidget {
  final MQTTClientWrapper mqttClientWrapper;
  final ValueNotifier<String> patientNotifier;
  final ValueNotifier<List> annotationTypesD;
  final ValueNotifier<List<String>> historyMAC;
  final ValueNotifier<String> isBitalino;

  ProfileDrawer({
    this.mqttClientWrapper,
    this.patientNotifier,
    this.annotationTypesD,
    this.historyMAC,
    this.isBitalino,
  });

  @override
  _ProfileDrawerState createState() => _ProfileDrawerState();
}

class _ProfileDrawerState extends State<ProfileDrawer> {
  List<String> annotationTypesS;
  int _radioValue;
  Map<String,int> typeOfDevices = {'Bitalino': 0, 'Mini': 1, 'Sense': 2};
  //TextEditingController _idTemplateController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _radioValue = typeOfDevices[widget.isBitalino.value];
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

  void _updateDeviceType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('deviceType', widget.isBitalino.value);
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
            Container(
              height: 170,
              child: DrawerHeader(
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
                  style: MyTextStyle(
                      fontSize: 16, color: DefaultColors.textColorOnLight),
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
                  width - 0.9 * width, 5, width - 0.9 * width, 0.0),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  primary: Colors.grey[200], // background
                  onPrimary: Colors.grey[600], // foreground
                ),
                label: Text(
                  'Desligar RPi',
                  style: MyTextStyle(
                      fontSize: 16, color: DefaultColors.textColorOnLight),
                ),
                icon: Icon(
                  Icons.power_settings_new_rounded,
                  color: Colors.grey[600],
                ),
                onPressed: () {
                  setState(() {
                    widget.mqttClientWrapper.publishMessage("['TURN OFF']");
                    Navigator.pop(context);
                  });
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                  width - 0.9 * width, 20.0, width - 0.9 * width, 0.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text('BITalino',
                          style: MyTextStyle(
                              color: DefaultColors.textColorOnLight)),
                      Radio(
                        value: 0,
                        groupValue: _radioValue,
                        onChanged: (int value) {
                          setState(() {
                                _radioValue = value;
                                widget.isBitalino.value = 'Bitalino';
                                _updateDeviceType();
                              });
                            }),
                    ],
                  ),
                  Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text('Mini',
                            style: MyTextStyle(
                                color: DefaultColors.textColorOnLight)),
                        Radio(
                          value: 1,
                          groupValue: _radioValue,
                          onChanged: (int value) {
                            setState(() {
                                _radioValue = value;
                                widget.isBitalino.value = 'Mini';
                                _updateDeviceType();
                              });
                            }),
                      ]),
                  Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text('Sense',
                            style: MyTextStyle(
                                color: DefaultColors.textColorOnLight)),
                        Radio(
                            value: 2,
                            groupValue: _radioValue,
                            onChanged: (int value) {
                              setState(() {
                                _radioValue = value;
                                widget.isBitalino.value = 'Sense';
                                _updateDeviceType();
                              });
                            }),
                      ]),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                  width - 0.9 * width, 10.0, width - 0.9 * width, 0.0),
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
            ),
            SizedBox(height: 20)
          ]),
    );
  }
}
