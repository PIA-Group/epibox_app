import 'package:flutter/material.dart';
import 'package:rPiInterface/utils/models.dart';
import 'package:rPiInterface/utils/mqtt_wrapper.dart';

class ConfigPage extends StatefulWidget {
  MQTTClientWrapper mqttClientWrapper;
  ValueNotifier<MqttCurrentConnectionState> connectionNotifier;
  ValueNotifier<List<String>> driveListNotifier;

  ValueNotifier<bool> isBit1Enabled;
  ValueNotifier<bool> isBit2Enabled;

  ValueNotifier<String> macAddress1Notifier;
  ValueNotifier<String> macAddress2Notifier;

  ValueNotifier<bool> sentConfigNotifier;

  ConfigPage(
      {this.mqttClientWrapper,
      this.connectionNotifier,
      this.driveListNotifier,
      this.isBit1Enabled,
      this.isBit2Enabled,
      this.macAddress1Notifier,
      this.macAddress2Notifier,
      this.sentConfigNotifier});

  @override
  _ConfigPageState createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  String _chosenDrive;

  List<bool> _bit1Selections = List.generate(6, (_) => false);
  List<bool> _bit2Selections = List.generate(6, (_) => false);

  List<String> _channels2Send = [];

  final TextEditingController _controllerFreq = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controllerFreq.text = '1000';
    _chosenDrive = widget.driveListNotifier.value[0];
  }

  Future<void> _setup() async {
    print('mac1: ${widget.macAddress1Notifier.value}, mac2: ${widget.macAddress2Notifier.value}');
    widget.mqttClientWrapper.publishMessage("['FOLDER', '$_chosenDrive']");
    widget.mqttClientWrapper.publishMessage("['FS', ${_controllerFreq.text}]");
    _bit1Selections.asMap().forEach((channel, value) {
      if (value) {
        _channels2Send.add(widget.macAddress1Notifier.value);
        _channels2Send.add((channel + 1).toString());
      }
    });
    _bit2Selections.asMap().forEach((channel, value) {
      if (value) {
        _channels2Send.add(widget.macAddress2Notifier.value);
        _channels2Send.add((channel + 1).toString());
      }
    });
    widget.mqttClientWrapper.publishMessage("['CHANNELS', '$_channels2Send']");
    setState(() => _channels2Send = []);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bodyWidth = MediaQuery.of(context).size.width -
        MediaQuery.of(context).viewInsets.left -
        MediaQuery.of(context).viewInsets.right;

    return Scaffold(
      appBar: AppBar(
        title: new Text('Configurações'),
      ),
      body: Center(
        child: ListView(
          children: <Widget>[
            ValueListenableBuilder(
                valueListenable: widget.sentConfigNotifier,
                builder: (BuildContext context,
                    bool state, Widget child) {
                  return Container(
                    height: 20,
                    color: state
                        ? Colors.green[50]
                        : Colors.red[50],
                    child: Align(
                      alignment: Alignment.center,
                      child: Container(
                        child: Text(
                          state
                              ? 'Enviado'
                              : 'Selecione configurações para proceder',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            //fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
            Padding(
              padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
              child: Column(children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20.0, 20.0, 0.0, 10.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      child: Text(
                        'Pasta para armazenamento',
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
                  height: 100.0,
                  width: 300.0,
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
                    child: ListView(
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 0.0),
                          child: DropdownButton(
                            value: _chosenDrive,
                            items: widget.driveListNotifier.value
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              );
                            }).toList(),
                            onChanged: (newDrive) =>
                                setState(() => _chosenDrive = newDrive),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ]),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
              child: Column(children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20.0, 20.0, 0.0, 10.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      child: Text(
                        'Configurações de aquisição',
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
                  height: 200.0,
                  width: 300.0,
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
                    child: ListView(
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 0.0),
                          child: Row(
                            children: [
                              Text(
                                'Freq. amostragem [Hz]:',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey[600]),
                              ),
                              Expanded(
                                child: Container(
                                  margin:
                                      EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
                                  child: DropdownButton(
                                    value: _controllerFreq.text,
                                    items: ['1000', '100', '10', '1']
                                        .map<DropdownMenuItem<String>>(
                                            (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(
                                          value,
                                          style: TextStyle(
                                              color: Colors.grey[600]),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (fs) =>
                                        setState(() => _controllerFreq.text = fs),
                                  ),
                                  /* TextField(
                                    controller: _controllerFreq,
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(
                                          color: Colors.grey[600], height: 1.0),
                                      decoration: InputDecoration(
                                        isDense: true,
                                        //border: OutlineInputBorder(),
                                      ),
                                      onChanged: null), */
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 5.0),
                          child: Text(
                            'Canais dispositivo 1:',
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[600]),
                          ),
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              ToggleButtons(
                                constraints: BoxConstraints(
                                    maxHeight: 25.0,
                                    minHeight: 25.0,
                                    maxWidth: 40.0,
                                    minWidth: 40.0),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(25)),
                                renderBorder: true,
                                children: <Widget>[
                                  Text('A1'),
                                  Text('A2'),
                                  Text('A3'),
                                  Text('A4'),
                                  Text('A5'),
                                  Text('A6'),
                                ],
                                isSelected: _bit1Selections,
                                onPressed: widget.isBit1Enabled.value
                                    ? (int index) {
                                        setState(() {
                                          _bit1Selections[index] =
                                              !_bit1Selections[index];
                                        });
                                      }
                                    : null,
                              )
                            ]),
                        Padding(
                          padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 5.0),
                          child: Text(
                            'Canais dispositivo 2:',
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[600]),
                          ),
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              ToggleButtons(
                                constraints: BoxConstraints(
                                    maxHeight: 25.0,
                                    minHeight: 25.0,
                                    maxWidth: 40.0,
                                    minWidth: 40.0),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(25)),
                                renderBorder: true,
                                children: <Widget>[
                                  Text('A1'),
                                  Text('A2'),
                                  Text('A3'),
                                  Text('A4'),
                                  Text('A5'),
                                  Text('A6'),
                                ],
                                isSelected: _bit2Selections,
                                onPressed: widget.isBit2Enabled.value
                                    ? (int index) {
                                        setState(() {
                                          _bit2Selections[index] =
                                              !_bit2Selections[index];
                                        });
                                      }
                                    : null,
                              )
                            ]),
                      ],
                    ),
                  ),
                ),
              ]),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    RaisedButton(
                      onPressed: () {
                        _setup();
                      },
                      child: new Text("Selecionar"),
                    ),
                  ]),
            ),
          ],
        ),
      ),
    );
  }
}
