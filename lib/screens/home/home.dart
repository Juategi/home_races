import 'package:flutter/material.dart';
import 'package:homeraces/model/user.dart';
import 'package:homeraces/services/auth.dart';
import 'package:homeraces/shared/loading.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  User user;
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    setState(()  {
      _selectedIndex = index;
    });
  }
  @override
  Future<bool> didPopRoute() async {
    if(_selectedIndex == 0)
      return false;
    else {
      setState(() {
        _selectedIndex = 0;
      });
      return Future<bool>.value(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    user = Provider.of<User>(context);
    return user == null? Loading() : Scaffold(
      appBar: AppBar(leading: Text(user.username),),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today, size: 30,),
            title: Container(height: 0.0)
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search, size: 30,),
              title: Container(height: 0.0)
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.alarm, size: 30,),
              title: Container(height: 0.0)
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.person, size: 30,),
              title: Container(height: 0.0)
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue[500],
        onTap: _onItemTapped,
      ),
      body: RaisedButton(onPressed: () {
        AuthService().signOut();},),
    );
  }
}
