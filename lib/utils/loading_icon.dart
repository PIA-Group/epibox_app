import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/material.dart';

class LoadingIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text('PreEpiSeizures'),
      ),
      body: Container(
        child: Center(
          child: SpinKitWave(
            color: Colors.blue,
          ),
        ),
      ),
    );
  }
}
