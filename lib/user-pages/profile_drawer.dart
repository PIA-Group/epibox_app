import 'package:epibox/app_localizations.dart';
import 'package:epibox/classes/devices.dart';
import 'package:epibox/classes/shared_pref.dart';
import 'package:epibox/mqtt/mqtt_wrapper.dart';
import 'package:epibox/shared_pref/pref_handler.dart';
import 'package:flutter/material.dart';
import 'package:epibox/decor/default_colors.dart';
import 'package:epibox/decor/text_styles.dart';

class ProfileDrawer extends StatefulWidget {
  final MQTTClientWrapper mqttClientWrapper;
  final ValueNotifier<String> patientNotifier;
  final Devices devices;
  final Preferences preferences;

  ProfileDrawer({
    this.mqttClientWrapper,
    this.patientNotifier,
    this.devices,
    this.preferences,
  });

  @override
  _ProfileDrawerState createState() => _ProfileDrawerState();
}

class _ProfileDrawerState extends State<ProfileDrawer> {
  int _radioValue;
  Map<String, int> typeOfDevices = {'bitalino': 0, 'scientisst': 1};
  //TextEditingController _idTemplateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _radioValue = typeOfDevices[widget.devices.type];
  }

  Iterable<Widget> get annotationsWidgets sync* {
    for (String annot in widget.preferences.annotationTypes) {
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
            // setState(() {
            //   annotationTypesS.removeWhere((String entry) {
            //     return entry == annot;
            //   });
            // });
            setState(() => widget.preferences.annotationTypes.remove(annot));
            updateAnnotations(widget.preferences);
          },
        ),
      );
    }
  }

  Iterable<Widget> get historyWidgets sync* {
    for (String mac in widget.preferences.macHistory) {
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
                widget.preferences.macHistory.removeWhere((String entry) {
                  return entry == mac;
                });
              });
              updateHistory(widget.preferences);
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
                  primary: Colors.white, // background
                  onPrimary: Colors.grey[600], // foreground
                ),
                label: Text(
                  AppLocalizations.of(context).translate('sign out').inCaps,
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
                  primary: Colors.white, // background
                  onPrimary: Colors.grey[600], // foreground
                ),
                label: Text(
                  AppLocalizations.of(context).translate('turn off RPi').inCaps,
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
                              widget.devices.type = 'bitalino';
                              updateDeviceType(widget.devices);
                            });
                          }),
                    ],
                  ),
                  Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text('ScientISST',
                            style: MyTextStyle(
                                color: DefaultColors.textColorOnLight)),
                        Radio(
                            value: 1,
                            groupValue: _radioValue,
                            onChanged: (int value) {
                              setState(() {
                                _radioValue = value;
                                widget.devices.type = 'scientisst';
                                updateDeviceType(widget.devices);
                              });
                            }),
                      ]),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                  width - 0.9 * width, 10.0, width - 0.9 * width, 0.0),
              child: Text(
                  AppLocalizations.of(context)
                          .translate('my annotations')
                          .inCaps +
                      ':',
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
              child: Text(
                  AppLocalizations.of(context)
                          .translate('device history')
                          .inCaps +
                      ':',
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
