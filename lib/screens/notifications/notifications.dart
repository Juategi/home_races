import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:homeraces/model/competition.dart';
import 'package:homeraces/model/user.dart';
import 'package:homeraces/model/notification.dart';
import 'package:homeraces/screens/notifications/notification_tile.dart';
import 'package:homeraces/services/dbservice.dart';
import 'package:homeraces/shared/common_data.dart';
import 'package:provider/provider.dart';

class Notifications extends StatefulWidget {
  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  User user;
  List<NotificationUser> notifications;
  final DBService _dbService = DBService();

  void _loadNotifications()async{
    if(notifications == null){
      notifications = await _dbService.getNotifications(user.id);
      setState(() {});
    }
  }

  void _timerNotifications()async{
    if(user != null){
      notifications = await _dbService.getNotifications(user.id);
      setState(() {
      });
    }
    Future.delayed(Duration(seconds: 5)).then((_) {
      print("Getting notifications...");
      _timerNotifications;
    });
  }
  @override
  void initState() {
    _timerNotifications();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    user = Provider.of<User>(context);
    _loadNotifications();
    ScreenUtil.init(context, height: CommonData.screenHeight, width: CommonData.screenWidth, allowFontScaling: true);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.h),
        child: AppBar(
          elevation: 1,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          centerTitle: true,
          title: Text('NOTIFICACIONES', style: TextStyle(fontWeight: FontWeight.bold, fontSize: ScreenUtil().setSp(16), color: Colors.black,),),
        ),
      ),
      body: notifications == null? Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),),
        ],
      ):
      Column(crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: 30.h,),
          Flexible(
            child: ListView(
              children: notifications.map((n) => NotificationTile(notification: n,)).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
