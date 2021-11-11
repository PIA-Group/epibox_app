import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:epibox/utils/id_wrapper.dart';
import 'package:epibox/decor/default_colors.dart';

void main() => runApp(InterfaceRPi());

class InterfaceRPi extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    /* SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.white)); */
    // Provider allows to make available information (eg: Stream) to all of its descendents
    return MaterialApp(
      //showPerformanceOverlay: true,
      //checkerboardOffscreenLayers: true,
      //checkerboardRasterCacheImages: true,
      theme: ThemeData(
          canvasColor: DefaultColors.backgroundColor,
          scaffoldBackgroundColor: DefaultColors.backgroundColor,
          brightness: Brightness.light,
          hintColor: DefaultColors.mainLColor,
          primaryColor: DefaultColors.mainColor,
          //accentColor: DefaultColors.mainLColor,
          primaryColorDark: DefaultColors.mainLColor,
          fontFamily: 'Hind',
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
