import 'package:flutter/material.dart';
import 'package:rPiInterface/utils/authentication.dart';
import 'package:provider/provider.dart';
import 'package:rPiInterface/utils/id_wrapper.dart';
import 'package:rPiInterface/utils/default_colors.dart';

void main() => runApp(new InterfaceRPi());

class InterfaceRPi extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // Provider allows to make available information (eg: Stream) to all of its descendents
    return StreamProvider<User>.value(
      value: Auth().user,
      child: MaterialApp(
        theme: ThemeData(
            scaffoldBackgroundColor: LightColors.kLightYellow,

            // Define the default brightness and colors.
            brightness: Brightness.light,
            primaryColor: LightColors.kDarkYellow,
            accentColor: LightColors.kDarkYellow,

            // Define the default font family.
            fontFamily: 'Hind',

            // Define the default TextTheme. Use this to specify the default
            // text styling for headlines, titles, bodies of text, and more.
            textTheme: TextTheme(
              headline1: TextStyle(
                  fontSize: 72.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  fontFamily: 'Hind'),
              headline6: TextStyle(
                  fontSize: 36.0,
                  fontStyle: FontStyle.italic,
                  letterSpacing: 1,
                  fontFamily: 'Hind'),
              bodyText2: TextStyle(
                  //fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 1,
                  fontFamily: 'Hind'),
            )),
        //showPerformanceOverlay: true,
        title: 'EpiBOX',
        debugShowCheckedModeBanner: false,
        home: IDWrapper(),
      ),
    );
  }
}
