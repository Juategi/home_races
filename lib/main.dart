import 'package:flutter/material.dart';
import 'package:homeraces/screens/authenticate/signup.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/authenticate/wrapper.dart';
import 'services/app_localizations.dart';
import 'services/auth.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    AppLocalizations tr = AppLocalizations.of(context);

    return StreamProvider<String>.value(
      value: AuthService().user,
      child: MaterialApp(
        routes:{
          //"/":(context) => Wrapper(),
          "/signup" : (context) => SignUp()
        },
        home: Wrapper(),
        //initialRoute:"/",
        supportedLocales: [
          Locale('es','ES'),
          Locale('en','US')
        ],
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate
        ],
        localeListResolutionCallback: (locales, supportedLocales){
          for(var locale in locales) {
            for (var supportedLocale in supportedLocales) {
              if (supportedLocale.languageCode == locale.languageCode &&
                  supportedLocale.countryCode == locale.countryCode)
                return supportedLocale;
            }
          }
          return supportedLocales.first;
        },
      ),
    );
  }
}

