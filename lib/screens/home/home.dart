import 'package:flutter/material.dart';
import 'package:homeraces/model/user.dart';
import 'package:homeraces/services/auth.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  User user;
  @override
  Widget build(BuildContext context) {
    user = Provider.of<User>(context);
    return Scaffold(appBar:AppBar(leading: Text(user.username),), body: RaisedButton(onPressed: (){AuthService().signOut();},),);
  }
}
