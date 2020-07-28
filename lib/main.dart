import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:homeraces/screens/authenticate/login/login.dart';
import 'package:homeraces/screens/authenticate/login/reset.dart';
import 'package:homeraces/screens/authenticate/signup/basic_data.dart';
import 'package:homeraces/screens/authenticate/signup/date_sex.dart';
import 'package:homeraces/screens/competition/create_competition.dart';
import 'package:homeraces/screens/competition/profile_competition.dart';
import 'package:homeraces/screens/competition/race.dart';
import 'package:homeraces/screens/competition/results/partials.dart';
import 'package:homeraces/screens/competition/results/results.dart';
import 'package:homeraces/screens/home/home.dart';
import 'package:homeraces/screens/profile/editcompetition/edit_competition.dart';
import 'package:homeraces/screens/profile/edituser/edit_user.dart';
import 'file:///C:/D/home_races/lib/screens/profile/edituser/change_password.dart';
import 'file:///C:/D/home_races/lib/screens/profile/editcompetition/owned.dart';
import 'package:homeraces/screens/profile/ranks.dart';
import 'package:homeraces/screens/profile/search_followers.dart';
import 'package:homeraces/shared/SpanishCupertinoLocalizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/authenticate/wrapper.dart';
import 'services/app_localizations.dart';
import 'services/auth.dart';

void main() {
  runApp(Phoenix(child: MyApp()));
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    AppLocalizations tr = AppLocalizations.of(context);

    return StreamProvider<String>.value(
      value: AuthService().user,
      child: MaterialApp(
        routes:{
          "/wrapper": (context) => Wrapper(),
          "/signup" : (context) => SignUp(),
          "/login" : (context) => LogIn(),
          "/home": (context) => Home(),
          "/competition": (context) => CompetitionProfile(),
          "/newcompetition": (context) => CreateCompetition(),
          "/edituser": (context) => EditUser(),
          "/changepassword":(context) => ChangePassword(),
          "/ranks": (context) => Ranks(),
          "/followers": (context) => SearchFollowers(),
          "/results": (context) => RaceResults(),
          "/partials": (context) => PartialsData(),
          "/race": (context) => Race(),
          "/reset": (context) => ResetPassword(),
          "/owned": (context) =>  OwnedCompetitions(),
          "/editcompetition": (context) =>  EditCompetition()
        },
        home: Wrapper(),
        //initialRoute:"/",
        supportedLocales: [
          Locale('en','US'),
          Locale('es','ES')
        ],
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          DefaultCupertinoLocalizations.delegate,
          SpanishCupertinoLocalizations.delegate
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

