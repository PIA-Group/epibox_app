import 'package:epibox/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:epibox/utils/id_wrapper.dart';
import 'package:epibox/decor/default_colors.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() => runApp(InterfaceRPi());

class InterfaceRPi extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
        ),
      ),
      supportedLocales: [
        Locale('en', 'US'),
        Locale('pt', 'PT'),
      ],
      // These delegates make sure that the localization data for the proper language is loaded
      localizationsDelegates: [
        // THIS CLASS WILL BE ADDED LATER
        // A class which loads the translations from JSON files
        AppLocalizations.delegate,
        // Built-in localization of basic text for Material widgets
        GlobalMaterialLocalizations.delegate,
        // Built-in localization for text direction LTR/RTL
        GlobalWidgetsLocalizations.delegate,
        DefaultCupertinoLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
      ],
      //showPerformanceOverlay: true,
      title: 'EpiBOX',
      debugShowCheckedModeBanner: false,
      home: IDWrapper(),
    );
  }
}
