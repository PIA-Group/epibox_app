import 'package:flutter/material.dart';
import 'package:rPiInterface/common_pages/mode_selection.dart';
import 'package:rPiInterface/utils/authentication.dart';
import 'package:provider/provider.dart';

void main() => runApp(new InterfaceRPi());

class InterfaceRPi extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // Provider allows to make available information (eg: Stream) to all of its descendents
    return StreamProvider<User>.value(
      value: Auth().user,
      child: MaterialApp(
          title: 'PreEpiSeizures',
          debugShowCheckedModeBanner: false,
          home: ModeSelectionPage(),
        ),
    );
  }
}
