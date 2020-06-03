import 'package:flutter/material.dart';
import 'package:homeraces/model/user.dart';
import 'package:homeraces/screens/authenticate/authenticate.dart';
import 'package:homeraces/screens/home/home.dart';
import 'package:homeraces/services/dbservice.dart';
import 'package:provider/provider.dart';



class Wrapper extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<String>(context);
    if(user == null)
      return Authenticate();
    else
      /*return FutureProvider<User>.value(
          value: DBService().getUserData(user),
          child: Home()
      );*/
      return null;
  }
}