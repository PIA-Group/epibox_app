import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:epibox/utils/id_wrapper.dart';
import 'package:epibox/decor/default_colors.dart';

void main() => runApp(new InterfaceRPi());

class InterfaceRPi extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.white));
    // Provider allows to make available information (eg: Stream) to all of its descendents
    return MaterialApp(
      theme: ThemeData(
          canvasColor: DefaultColors.backgroundColor,
          scaffoldBackgroundColor: DefaultColors.backgroundColor,

          // Define the default brightness and colors.
          brightness: Brightness.light,
          hintColor: DefaultColors.mainLColor,
          primaryColor: DefaultColors.mainColor,
          accentColor: DefaultColors.mainLColor,
          primaryColorDark: DefaultColors.mainLColor,
          //splashColor: Colors.white,
          // Define the default font family.
          fontFamily: 'Hind',

          // Define the default TextTheme. Use this to specify the default
          // text styling for headlines, titles, bodies of text, and more.
          textTheme: TextTheme(
            headline1: TextStyle(
              fontSize: 72.0,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
              fontFamily: 'Hind',
              //color: Colors.grey[800]),
            ),
            headline6: TextStyle(
              fontSize: 36.0,
              fontStyle: FontStyle.italic,
              letterSpacing: 1,
              fontFamily: 'Hind',
            ),
            //color: Colors.grey[800]),
            bodyText2: TextStyle(
              //fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 1,
              fontFamily: 'Hind',
              //color: Colors.grey[800]
            ),
          )),
      //showPerformanceOverlay: true,
      title: 'EpiBOX',
      debugShowCheckedModeBanner: false,
      home: IDWrapper(),
    );
  }
}
