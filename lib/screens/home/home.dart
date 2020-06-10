import 'package:flutter/material.dart';
import 'package:homeraces/services/auth.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar:AppBar(leading: Text(""),), body: RaisedButton(onPressed: (){AuthService().signOut();},),);
  }
}
