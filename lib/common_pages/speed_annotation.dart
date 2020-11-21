import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SpeedAnnotationDialog extends StatefulWidget {
  List<String> annotationTypes;
  ValueNotifier<String> patientNotifier;
  ValueNotifier<bool> newAnnotation;

  SpeedAnnotationDialog({
    this.annotationTypes,
    this.patientNotifier,
    this.newAnnotation,
  });

  @override
  _SpeedAnnotationDialogState createState() => _SpeedAnnotationDialogState();
}

class _SpeedAnnotationDialogState extends State<SpeedAnnotationDialog> {
  final TextEditingController _controller = TextEditingController();
  final firestoreInstance = Firestore.instance;
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
      print(timeStamp);
      timeStamp = timeStamp
          .subtract(Duration(seconds: (_currentSliderValue * 60).toInt()));
      print(timeStamp);
      String today = '${timeStamp.year}-${timeStamp.month}-${timeStamp.day}';

      try {
        if (!widget.annotationTypes.contains(_controller.text)) {
          widget.annotationTypes.add(_controller.text);
          print(widget.annotationTypes);
          firestoreInstance
              .collection("annotations")
              .document('types')
              .setData({'types': widget.annotationTypes}, merge: true);
        }
      } catch (e) {
        print(e);
      }

      Map previousAnnot;
      try {
        await firestoreInstance
            .collection('users')
            .document(widget.patientNotifier.value)
            .collection('annotations')
            .document(today)
            .get()
            .then((value) => setState(() => previousAnnot = value.data[today]));
      } catch (e) {
        setState(() => previousAnnot = {});
      }

      try {
        if (!_isChecked) {
          previousAnnot[_controller.text]
              .add('${timeStamp.hour}:${timeStamp.minute}:${timeStamp.second}');
        } else {
          previousAnnot[_controller.text]
              .add('null');
        }
      } catch (e) {
        if (!_isChecked) {
        previousAnnot[_controller.text] = [
          '${timeStamp.hour}:${timeStamp.minute}:${timeStamp.second}'
        ];
        } else {previousAnnot[_controller.text] = ['null'];}
      }

      try {
        firestoreInstance
            .collection('users')
            .document(widget.patientNotifier.value)
            .collection('annotations')
            .document(today)
            .setData({today: previousAnnot}, merge: true);
        setState(() => widget.newAnnotation.value = true);
      } catch (e) {
        print(e);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width -
        MediaQuery.of(context).viewInsets.left -
        MediaQuery.of(context).viewInsets.right;

    final height = MediaQuery.of(context).size.height -
        MediaQuery.of(context).viewInsets.top -
        MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Anotação Rápida'),
        actions: [
          IconButton(
              icon: Icon(
                Icons.save_alt,
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
                      'Anotação',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
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
                      'Ajustar instante da anotação',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
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
                      '(Tempo decorrido [min])',
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
                          '(?) Não sei quando ocorreu',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
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
