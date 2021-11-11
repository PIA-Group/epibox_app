import 'package:epibox/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:epibox/decor/default_colors.dart';
import 'package:epibox/mqtt/mqtt_wrapper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SpeedAnnotationDialog extends StatefulWidget {
  final ValueNotifier<List> annotationTypesD;
  final List<String> annotationTypes;
  final ValueNotifier<String> patientNotifier;
  final MQTTClientWrapper mqttClientWrapper;

  SpeedAnnotationDialog({
    this.annotationTypesD,
    this.annotationTypes,
    this.patientNotifier,
    this.mqttClientWrapper,
  });

  @override
  _SpeedAnnotationDialogState createState() => _SpeedAnnotationDialogState();
}

class _SpeedAnnotationDialogState extends State<SpeedAnnotationDialog> {
  final TextEditingController _controller = TextEditingController();
  double _currentSliderValue = 0.0;

  bool _isChecked = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveAnnotation() async {
    if (_controller.text.trim() != '') {
      var timeStamp = DateTime.now();
      timeStamp = timeStamp
          .subtract(Duration(seconds: (_currentSliderValue * 60).toInt()));
      try {
        setState(() => _controller.text = _controller.text.trim());
        if (!widget.annotationTypes.contains(_controller.text)) {
          setState(() => widget.annotationTypesD.value.add(_controller.text));
          widget.annotationTypes.add(_controller.text);
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setStringList('annotationTypes', widget.annotationTypes);
        }
      } catch (e) {
        print(e);
      }

      List annot;
      String annotText = _controller.text.replaceAll('ç', 'c');
      annotText = annotText.replaceAll(' ', '_');
      if (!_isChecked) {
        annot = [
          '"$annotText"',
          '"${timeStamp.hour}:${timeStamp.minute}:${timeStamp.second}"'
        ];
      } else {
        annot = ['"$annotText"', '"null"'];
      }

      widget.mqttClientWrapper.publishMessage("['ANNOTATION', $annot]");

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width -
        MediaQuery.of(context).viewInsets.left -
        MediaQuery.of(context).viewInsets.right;

    /* final height = MediaQuery.of(context).size.height -
        MediaQuery.of(context).viewInsets.top -
        MediaQuery.of(context).viewInsets.bottom; */

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)
            .translate('flash annotation')
            .capitalizeFirstofEach),
        actions: [
          IconButton(
              icon: Icon(
                Icons.save_outlined,
                color: Colors.white,
              ),
              onPressed: _saveAnnotation)
        ],
      ),
      body: new Center(
        child: ListView(children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 0.0),
            child: Column(children: [
              Padding(
                padding: EdgeInsets.fromLTRB(20.0, 0.0, 0.0, 10.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    child: Text(
                      AppLocalizations.of(context)
                          .translate('annotation')
                          .inCaps,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                height: 100,
                width: width * 0.85,
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
                    padding: EdgeInsets.only(left: 20.0, bottom: 10.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                            child: TextField(
                          controller: _controller,
                          onChanged: null,
                        )),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.arrow_drop_down),
                          onSelected: (String value) {
                            _controller.text = value;
                          },
                          itemBuilder: (BuildContext context) {
                            return widget.annotationTypes
                                .map<PopupMenuItem<String>>((String value) {
                              return new PopupMenuItem(
                                  child: new Text(value), value: value);
                            }).toList();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20.0, 30.0, 0.0, 10.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    child: Text(
                      AppLocalizations.of(context)
                          .translate('adjust annotation time')
                          .inCaps,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20.0, 0.0, 0.0, 10.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    child: Text(
                      '${AppLocalizations.of(context).translate('time elapsed').inCaps} [min]',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                height: 100,
                width: width * 0.85,
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
                  child: Column(children: [
                    Slider(
                      value: _currentSliderValue,
                      min: 0.0,
                      max: 5.0,
                      divisions: 10,
                      label: _currentSliderValue.toString(),
                      onChanged: (double value) {
                        setState(() {
                          _currentSliderValue = value;
                        });
                      },
                    ),
                    Expanded(
                      child: CheckboxListTile(
                        value: _isChecked,
                        onChanged: (bool val) {
                          setState(() => _currentSliderValue = 0.0);
                          setState(() => _isChecked = val);
                        },
                        title: Text(
                          '(?) ${AppLocalizations.of(context).translate("don't know when it happened").inCaps}',
                          style: TextStyle(
                            color: DefaultColors.textColorOnLight,
                          ),
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ]),
          )
        ]),
      ),
    );
  }
}
