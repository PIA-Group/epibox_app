import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:provider/provider.dart';
import 'package:rPiInterface/common_pages/real_time.dart';
import 'package:rPiInterface/patient_pages/devices_setup.dart';
import 'package:rPiInterface/common_pages/rpi_setup.dart';
import 'package:rPiInterface/common_pages/webview_page.dart';
import 'package:rPiInterface/patient_pages/qr_page.dart';
import 'package:rPiInterface/utils/authentication.dart';
import 'package:rPiInterface/utils/models.dart';
import 'package:rPiInterface/utils/mqtt_wrapper.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  ValueNotifier<MqttCurrentConnectionState> connectionNotifier =
      ValueNotifier(MqttCurrentConnectionState.DISCONNECTED);

  ValueNotifier<String> macAddress1Notifier = ValueNotifier('Endereço MAC');
  ValueNotifier<String> macAddress2Notifier = ValueNotifier('Endereço MAC');

  ValueNotifier<String> defaultMacAddress1Notifier = ValueNotifier('Endereço MAC');
  ValueNotifier<String> defaultMacAddress2Notifier = ValueNotifier('Endereço MAC');

  ValueNotifier<List<String>> driveListNotifier =
      ValueNotifier(['Armazenamento interno']);

  ValueNotifier<String> hostnameNotifier = ValueNotifier('192.168.1.8');

  ValueNotifier<String> acquisitionNotifier = ValueNotifier('off');

  ValueNotifier<bool> receivedMACNotifier = ValueNotifier(false);
  ValueNotifier<bool> sentMACNotifier = ValueNotifier(false);

  final Auth _auth = Auth();
  final firestoreInstance = Firestore.instance;

  String message;

  // dataNotifier: list of lists, each sublist corresponds to a channel acquired
  ValueNotifier<List> dataNotifier = ValueNotifier([]); 
  ValueNotifier<List> dataChannelsNotifier = ValueNotifier([]); 

  MqttCurrentConnectionState connectionState;
  MQTTClientWrapper mqttClientWrapper;
  MqttClient client;

  final TextEditingController _nameController = TextEditingController();

  void setupHome() {
    mqttClientWrapper = MQTTClientWrapper(
      client,
      () => {},
      (newMessage) => gotNewMessage(newMessage),
      (newConnectionState) => updatedConnection(newConnectionState),
    );
  }

  @override
  void initState() {
    super.initState();
    acquisitionNotifier.value = 'off';
    setupHome();
    _nameController.text = " ";
    /* acquisitionNotifier.addListener(() {
      _showSnackBar(
        acquisitionNotifier.value == 'acquiring'
            ? 'A adquirir dados'
            : acquisitionNotifier.value == 'reconnecting'
                ? 'A retomar aquisição ...'
                : acquisitionNotifier.value == 'stopped'
                    ? 'Aquisição terminada e dados gravados'
                    : 'Aquisição desligada',
      );
    }); */
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    _nameController.dispose();
    super.dispose();
  }

  void gotNewMessage(String newMessage) {
    setState(() => message = newMessage);
    print('This is the new message: $message');
    _isMACAddress(message);
    _isDrivesList(message);
    _macReceived(message);
    _isAcquisitionStarting(message);
    _isData(message);
  }

  void updatedConnection(MqttCurrentConnectionState newConnectionState) {
    setState(() => connectionState = newConnectionState);
    connectionNotifier.value = newConnectionState;
    if (newConnectionState == MqttCurrentConnectionState.DISCONNECTED) {
      receivedMACNotifier.value = false;
    }
    print('This is the new connection state $connectionState');
  }

  void _isMACAddress(String message) {
    if (message.contains('DEFAULT')) {
      try {
        final List<String> listMAC = message.split(",");
        setState(() {
          defaultMacAddress1Notifier.value = listMAC[1].split("'")[1];
          defaultMacAddress2Notifier.value = listMAC[2].split("'")[1];
          receivedMACNotifier.value = true;
          /* macAddress1Notifier.value = listMAC[1];
          macAddress2Notifier.value = listMAC[2]; */
        });
      } catch (e) {
        print(e);
      }
    }
  }

  void _isDrivesList(String message) {
    if (message.contains('DRIVES')) {
      try {
        List<String> listDrives = message.split(",");
        listDrives.removeAt(0);
        listDrives = listDrives.map((drive) => drive.split("'")[1]).toList();
        setState(() => driveListNotifier.value = listDrives);
        mqttClientWrapper.publishMessage("['GO TO DEVICES']");
      } catch (e) {
        print(e);
      }
    }
  }

  void _macReceived(String message) {
    if (message.contains('RECEIVED MAC')) {
      sentMACNotifier.value = true;
    }
  }

  void _isAcquisitionStarting(String message) {
    if (message.contains('STARTING')) {
      setState(() => acquisitionNotifier.value = 'acquiring');
      print('ACQUISITION STARTING');
    } else if (message.contains('RECONNECTING')) {
      setState(() => acquisitionNotifier.value = 'reconnecting');
      print('RECONNECTING ACQUISITION');
    } else if (message.contains('STOPPED')) {
      setState(() => acquisitionNotifier.value = 'stopped');
      print('ACQUISITION STOPPED AND SAVED');
    } else if (message.contains('OFF')) {
      setState(() => acquisitionNotifier.value = 'off');
      print('ACQUISITION OFF');
    }
  }

  void _isData(String message) {
    if (message.contains('DATA')) {
      List message2List = json.decode(message);
      setState(() => dataNotifier.value = message2List[1]);
      setState(() => dataChannelsNotifier.value = message2List[2]);
    }
  }

  void _showSnackBar(String _message) {
    try {
      _scaffoldKey.currentState.showSnackBar(new SnackBar(
        content: new Text(_message),
        backgroundColor: Colors.blue,
      ));
    } catch (e) {
      print(e);
    }
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
    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
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
              )
            ]),
      ),
      appBar: new AppBar(title: new Text('PreEpiSeizures'), actions: <Widget>[
        FlatButton.icon(
          label: Text(
            'Sign out',
            style: TextStyle(color: Colors.white),
          ),
          icon: Icon(
            Icons.person,
            color: Colors.white,
          ),
          onPressed: () async {
            await _auth.signOut();
          },
        )
      ]),
      body: ListView(children: <Widget>[
        ValueListenableBuilder(
            valueListenable: receivedMACNotifier,
            builder: (BuildContext context, bool state, Widget child) {
              return Container(
                height: 20,
                color: state ? Colors.green[50] : Colors.red[50],
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    child: Text(
                      state
                          // && _conn == MqttCurrentConnectionState.CONNECTED)
                          ? 'Conectado ao RPi'
                          : 'Disconectado do RPi',
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
        ValueListenableBuilder(
            valueListenable: acquisitionNotifier,
            builder: (BuildContext context, String state, Widget child) {
              return Container(
                height: 20,
                color: state == 'acquiring'
                    ? Colors.green[50]
                    : state == 'reconnecting'
                        ? Colors.yellow[50]
                        : Colors.red[50],
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    child: Text(
                      state == 'acquiring'
                          ? 'A adquirir dados'
                          : state == 'reconnecting'
                              ? 'A retomar aquisição ...'
                              : state == 'stopped'
                                  ? 'Aquisição terminada e dados gravados'
                                  : 'Aquisição desligada',
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
          padding: EdgeInsets.fromLTRB(10, 20, 10, 10),
          child: Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue[300],
                child: Text(
                  '1',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              title: Text('Conectividade'),
              onTap: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return StreamProvider<User>.value(
                        value: Auth().user,
                        child: RPiPage(
                            mqttClientWrapper: mqttClientWrapper,
                            connectionNotifier: connectionNotifier,
                            defaultMacAddress1Notifier: defaultMacAddress1Notifier,
                            defaultMacAddress2Notifier: defaultMacAddress2Notifier,
                            macAddress1Notifier: macAddress1Notifier,
                            macAddress2Notifier: macAddress2Notifier,
                            receivedMACNotifier: receivedMACNotifier,
                            driveListNotifier: driveListNotifier,
                            acquisitionNotifier: acquisitionNotifier,
                            hostnameNotifier: hostnameNotifier,
                            sentMACNotifier: sentMACNotifier));
                  }),
                );
              },
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue[300],
                child: Text(
                  '2',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              title: Text('Selecionar dispositivos'),
              enabled: receivedMACNotifier.value == true,
              onTap: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return StreamProvider<User>.value(
                        value: Auth().user,
                        child: DevicesPage(
                            mqttClientWrapper: mqttClientWrapper,
                            defaultMacAddress1Notifier: defaultMacAddress1Notifier,
                            defaultMacAddress2Notifier: defaultMacAddress2Notifier,
                            macAddress1Notifier: macAddress1Notifier,
                            macAddress2Notifier: macAddress2Notifier,
                            connectionNotifier: connectionNotifier,
                            acquisitionNotifier: acquisitionNotifier,
                            receivedMACNotifier: receivedMACNotifier,
                            sentMACNotifier: sentMACNotifier));
                  }),
                );
              },
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue[300],
                child: Text(
                  '4',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              title: Text('Iniciar visualização'),
              enabled: acquisitionNotifier.value == 'acquiring',
              onTap: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return RealtimePage(
                      dataNotifier: dataNotifier,
                      dataChannelsNotifier: dataChannelsNotifier,
                      mqttClientWrapper: mqttClientWrapper,
                      hostnameNotifier: hostnameNotifier,
                    );
                  }),
                );
              },
            ),
          ),
        ),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: sentMACNotifier.value
            ? () async {
                mqttClientWrapper.publishMessage("['START']");
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return RealtimePage(
                      dataNotifier: dataNotifier,
                      dataChannelsNotifier: dataChannelsNotifier,
                      mqttClientWrapper: mqttClientWrapper,
                      hostnameNotifier: hostnameNotifier,
                    );
                  }),
                );
              }
            : () => {
                  connectionState != MqttCurrentConnectionState.CONNECTED
                      ? _showSnackBar('Erro: disconectado do RPi')
                      : _showSnackBar(
                          'Erro: dispositivo(s) ainda não selecionado(s)'),
                },
        label: Text('Start'),
        icon: Icon(Icons.play_circle_outline),
      ),
    );
  }
}
