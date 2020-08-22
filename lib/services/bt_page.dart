import 'dart:async';
//import 'dart:convert';

// For using PlatformException
import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:rPiInterface/home_page.dart';
import 'package:provider/provider.dart';
import '../home_page.dart';
import 'authentication.dart';

class BluetoothPage extends StatefulWidget {
  @override
  _BluetoothPageState createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
  // Initializing the Bluetooth connection state to be unknown
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  // Initializing a global key, as it would help us in showing a SnackBar later
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  // Get the instance of the Bluetooth
  FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  // Track the Bluetooth connection with the remote device
  //BluetoothConnection connection;

  //int _deviceState;

  bool isDisconnecting = false;

  // Map<String, Color> colors = {
  //   'onBorderColor': Colors.green,
  //   'offBorderColor': Colors.red,
  //   'neutralBorderColor': Colors.transparent,
  //   'onTextColor': Colors.green[700],
  //   'offTextColor': Colors.red[700],
  //   'neutralTextColor': Colors.blue,
  // };

  // To track whether the device is still connected to Bluetooth
  //bool get isConnected => connection != null && connection.isConnected;

  // Define some variables, which will be required later
  List<BluetoothDevice> _devicesList = [];
  BluetoothDevice _device;
  bool _connected = false;
  bool _isButtonUnavailable = false;

  @override
  void initState() {
    super.initState();

    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    //_deviceState = 0; // neutral

    // If the bluetooth of the device is not enabled,
    // then request permission to turn on bluetooth
    // as the app starts up
    enableBluetooth();

    // Listen for further state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;
        if (_bluetoothState == BluetoothState.STATE_OFF) {
          _isButtonUnavailable = true;
        }
        getPairedDevices();
      });
    });
  }

  @override
  void dispose() {
    // Avoid memory leak and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection.dispose();
      connection = null;
    }

    super.dispose();
  }

  // Request Bluetooth permission from the user
  Future<void> enableBluetooth() async {
    // Retrieving the current Bluetooth state
    _bluetoothState = await FlutterBluetoothSerial.instance.state;

    // If the bluetooth is off, then turn it on first
    // and then retrieve the devices that are paired.
    if (_bluetoothState == BluetoothState.STATE_OFF) {
      await FlutterBluetoothSerial.instance.requestEnable();
      await getPairedDevices();
      return true;
    } else {
      await getPairedDevices();
    }
    return false;
  }

  // For retrieving and storing the paired devices
  // in a list.
  Future<void> getPairedDevices() async {
    List<BluetoothDevice> devices = [];

    // To get the list of paired devices
    try {
      devices = await _bluetooth.getBondedDevices();
    } on PlatformException {
      print("Error");
    }

    // It is an error to call [setState] unless [mounted] is true.
    if (!mounted) {
      return;
    }

    // Store the [devices] list in the [_devicesList] for accessing
    // the list outside this class
    setState(() {
      _devicesList = devices;
    });
  }

  @override
  Widget build(BuildContext context) {
    final connection = Provider.of<BluetoothConnection>(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text('Conectar um dispositivo'),
      ),
      body: Container(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Visibility(
              visible: _isButtonUnavailable &&
                  _bluetoothState == BluetoothState.STATE_ON,
              child: LinearProgressIndicator(
                backgroundColor: Colors.blueGrey,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blueGrey[100]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'Bluetooth',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Switch(
                    value: _bluetoothState.isEnabled,
                    onChanged: (bool value) {
                      future() async {
                        if (value) {
                          await FlutterBluetoothSerial.instance.requestEnable();
                        } else {
                          await FlutterBluetoothSerial.instance
                              .requestDisable();
                        }

                        await getPairedDevices();
                        _isButtonUnavailable = false;

                        if (_connected) {
                          _disconnect();
                        }
                      }

                      future().then((_) {
                        setState(() {});
                      });
                    },
                  )
                ],
              ),
            ),
            Stack(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Dispositivo:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          DropdownButton(
                            items: _getDeviceItems(),
                            onChanged: (value) =>
                                setState(() => _device = value),
                            value: _devicesList.isNotEmpty ? _device : null,
                          ),
                          RaisedButton(
                            onPressed: _isButtonUnavailable
                                ? null
                                : _connected ? _disconnect : _connect,
                            child: Text(
                              _connected ? 'Disconectar' : 'Conectar',
                              style: TextStyle(fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: FlatButton.icon(
                        icon: Icon(
                          Icons.refresh,
                          color: Colors.blue,
                        ),
                        label: Text(
                          "Refresh dispositivos emparelhados",
                          style: TextStyle(
                            color: Colors.blue,
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        splashColor: Colors.deepPurple,
                        onPressed: () async {
                          print(connection.toString());
                          await getPairedDevices().then((_) {
                            show('Lista de dispositivos refreshed');
                          });
                        },
                      ),
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.all(16.0),
                    //   child: Card(
                    //     shape: RoundedRectangleBorder(
                    //       side: new BorderSide(
                    //         color: _deviceState == 0
                    //             ? colors['neutralBorderColor']
                    //             : _deviceState == 1
                    //                 ? colors['onBorderColor']
                    //                 : colors['offBorderColor'],
                    //         width: 3,
                    //       ),
                    //       borderRadius: BorderRadius.circular(4.0),
                    //     ),
                    //     elevation: _deviceState == 0 ? 4 : 0,
                    //     child: Padding(
                    //       padding: const EdgeInsets.all(8.0),
                    //       child: Row(
                    //         children: <Widget>[
                    //           Expanded(
                    //             child: Text(
                    //               "DEVICE 1",
                    //               style: TextStyle(
                    //                 fontSize: 20,
                    //                 color: _deviceState == 0
                    //                     ? colors['neutralTextColor']
                    //                     : _deviceState == 1
                    //                         ? colors['onTextColor']
                    //                         : colors['offTextColor'],
                    //               ),
                    //             ),
                    //           ),
                    //           FlatButton(
                    //             onPressed: _connected
                    //                 ? _sendOnMessageToBluetooth
                    //                 : null,
                    //             child: Text("ON"),
                    //           ),
                    //           FlatButton(
                    //             onPressed: _connected
                    //                 ? _sendOffMessageToBluetooth
                    //                 : null,
                    //             child: Text("OFF"),
                    //           ),
                    //         ],
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
                Container(
                  color: Colors.blue,
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "NOTA: Se o dispositivo pretendido não se encontrar na lista acima, verifique se o dispositivo se encontra emparelhado nas Definições Bluetooth.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 15),
                      RaisedButton(
                        elevation: 2,
                        child: Text("Definições Bluetooth"),
                        onPressed: () {
                          FlutterBluetoothSerial.instance.openSettings();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            FlatButton.icon(
              label: Text(
                'Conectar um dispositivo',
                style: TextStyle(color: Colors.black),
              ),
              icon: Icon(
                Icons.bluetooth,
                color: Colors.black,
              ),
              onPressed: () async {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return Provider<BluetoothConnection>.value(
                      value: connection,
                      child: StreamProvider<User>.value(
                        value: Auth().user,
                        child: HomePage(),
                      ),
                    );
                  }),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Create the List of devices to be shown in Dropdown Menu
  List<DropdownMenuItem<BluetoothDevice>> _getDeviceItems() {
    List<DropdownMenuItem<BluetoothDevice>> items = [];
    if (_devicesList.isEmpty) {
      items.add(DropdownMenuItem(
        child: Text('--'),
      ));
    } else {
      _devicesList.forEach((device) {
        items.add(DropdownMenuItem(
          child: Text(device.name),
          value: device,
        ));
      });
    }
    return items;
  }

  // Method to connect to bluetooth
  void _connect() async {
    setState(() {
      _isButtonUnavailable = true;
    });
    if (_device == null) {
      show('Nenhum dispositivo selecionado!');
      _isButtonUnavailable = false;
    } else {
      if (!isConnected) {
        await BluetoothConnection.toAddress(_device.address)
            .then((_connection) {
          show('Conectado ao dispositivo!');
          connection = _connection;
          setState(() {
            _connected = true;
          });
          print(_connection.isConnected);
          print(connection.toString());
          print(isConnected);

          // connection.input.listen(null).onDone(() {
          //   if (isDisconnecting) {
          //     print('Disconnecting locally!');
          //   } else {
          //     print('Disconnected remotely!');
          //   }
          //   if (this.mounted) {
          //     setState(() {});
          //   }
          // });
        }).catchError((error) {
          show('Não foi possível conectar');
          print('Cannot connect, exception occurred');
          print(error);
        });

        setState(() => _isButtonUnavailable = false);
      }
    }
  }

  // void _onDataReceived(Uint8List data) {
  //   // Allocate buffer for parsed data
  //   int backspacesCounter = 0;
  //   data.forEach((byte) {
  //     if (byte == 8 || byte == 127) {
  //       backspacesCounter++;
  //     }
  //   });
  //   Uint8List buffer = Uint8List(data.length - backspacesCounter);
  //   int bufferIndex = buffer.length;

  //   // Apply backspace control character
  //   backspacesCounter = 0;
  //   for (int i = data.length - 1; i >= 0; i--) {
  //     if (data[i] == 8 || data[i] == 127) {
  //       backspacesCounter++;
  //     } else {
  //       if (backspacesCounter > 0) {
  //         backspacesCounter--;
  //       } else {
  //         buffer[--bufferIndex] = data[i];
  //       }
  //     }
  //   }
  // }

  // Method to disconnect bluetooth
  void _disconnect() async {
    setState(() {
      _isButtonUnavailable = true;
      //_deviceState = 0;
    });
    await connection.close();
    show('Disconectado do dispositivo!');
    print('disconectou pela função _disconnect');
    if (!connection.isConnected) {
      setState(() {
        _connected = false;
        _isButtonUnavailable = false;
      });
    }
  }

  // Method to send message,
  // for turning the Bluetooth device on
  // void _sendOnMessageToBluetooth() async {
  //   connection.output.add(utf8.encode("1" + "\r\n"));
  //   await connection.output.allSent;
  //   show('Device Turned On');
  //   setState(() {
  //     _deviceState = 1; // device on
  //   });
  // }

  // // Method to send message,
  // // for turning the Bluetooth device off
  // void _sendOffMessageToBluetooth() async {
  //   connection.output.add(utf8.encode("0" + "\r\n"));
  //   await connection.output.allSent;
  //   show('Device Turned Off');
  //   setState(() {
  //     _deviceState = -1; // device off
  //   });
  // }

  // Method to show a Snackbar,
  // taking message as the text
  Future show(
    String message, {
    Duration duration: const Duration(seconds: 3),
  }) async {
    print(message);
    await new Future.delayed(new Duration(milliseconds: 100));
    _scaffoldKey.currentState.showSnackBar(
      new SnackBar(
        content: new Text(
          message,
        ),
        duration: duration,
      ),
    );
  }
}
