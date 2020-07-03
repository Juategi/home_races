import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:homeraces/model/user.dart';
import 'package:homeraces/screens/calendar/calendar.dart';
import 'package:homeraces/screens/explorer/explorer.dart';
import 'package:homeraces/screens/notifications/notifications.dart';
import 'package:homeraces/screens/profile/profile_user.dart';
import 'package:homeraces/shared/common_data.dart';
import 'package:homeraces/shared/loading.dart';
import 'package:provider/provider.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  User user;
  int _selectedIndex = 1;
  bool flag = true;

  void _onItemTapped(int index) {
    setState(()  {
      _selectedIndex = index;
    });
  }

  void _timer() {
    if(flag) {
      Future.delayed(Duration(seconds: 2)).then((_) {
        setState(() {
          print("Loading...");
        });
        _timer();
      });
    }
  }

  bool myInterceptor(bool stopDefaultButtonEvent) {
    if(_selectedIndex == 1)
      return false;
    else {
      setState(() {
        _selectedIndex = 1;
      });
      return true;
    }
  }

  @override
  void initState() {
    super.initState();
    _timer();
    BackButtonInterceptor.add(myInterceptor);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, height: CommonData.screenHeight, width: CommonData.screenWidth, allowFontScaling: true);
    user = Provider.of<User>(context);
    if(user == null)
      return Loading();
    else{
      flag = false;
      return Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today, size: ScreenUtil().setSp(30),),
                title: Container(height: 0.0)
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.search, size: ScreenUtil().setSp(30),),
                title: Container(height: 0.0)
            ),
            BottomNavigationBarItem(
                icon: FaIcon(FontAwesomeIcons.solidBell, size: ScreenUtil().setSp(28),),
                title: Container(height: 0.0)
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.person, size: ScreenUtil().setSp(30),),
                title: Container(height: 0.0)
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.blue[500],
          onTap: _onItemTapped,
        ),
        body: Stack(
          children: <Widget>[
            Offstage(
              offstage: _selectedIndex != 0,
              child: TickerMode(
                enabled: _selectedIndex == 0,
                child: Calendar(),
              ),
            ),
            Offstage(
              offstage: _selectedIndex != 1,
              child: TickerMode(
                enabled: _selectedIndex == 1,
                child: Explorer(),
              ),
            ),
            Offstage(
              offstage: _selectedIndex != 2,
              child: TickerMode(
                enabled: _selectedIndex == 2,
                child: Notifications(),
              ),
            ),
            Offstage(
              offstage: _selectedIndex != 3,
              child: TickerMode(
                enabled: _selectedIndex == 3,
                child: UserProfile()
              ),
            ),
          ],
        ),
      );
    }
  }
}
