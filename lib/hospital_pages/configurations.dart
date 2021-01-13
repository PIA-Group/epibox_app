import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigurationsDialog extends StatefulWidget {
  ValueNotifier<List> annotationTypesD;

  ConfigurationsDialog({
    this.annotationTypesD,
  });

  @override
  _ConfigurationsDialogState createState() => _ConfigurationsDialogState();
}

class _ConfigurationsDialogState extends State<ConfigurationsDialog> {
  List<String> annotationTypesS;
  @override
  void initState() {
    super.initState();
    annotationTypesS = List<String>.from(widget.annotationTypesD.value);
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

  void _updateAnnotations() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('annotationTypes', annotationTypesS);
    print('removed annot');
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width -
        MediaQuery.of(context).viewInsets.left -
        MediaQuery.of(context).viewInsets.right;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
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
                      'Tipos de anotação',
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
                      padding: EdgeInsets.only(left: 10.0, right: 10.0),
                      child: Wrap(
                        children: annotationsWidgets.toList(),
                      )),
                ),
              ),
            ]),
          )
        ]),
      ),
    );
  }
}
