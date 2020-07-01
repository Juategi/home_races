import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:homeraces/model/competition.dart';
import 'package:homeraces/model/notification.dart';
import 'package:homeraces/model/user.dart';
import 'package:homeraces/shared/common_data.dart';
import 'package:provider/provider.dart';

class NotificationTile extends StatefulWidget {
  NotificationTile({this.notification});
  NotificationUser notification;
  @override
  _NotificationTileState createState() => _NotificationTileState(notification: notification);
}

class _NotificationTileState extends State<NotificationTile> {
  _NotificationTileState({this.notification});
  User user;
  NotificationUser notification;
  @override
  Widget build(BuildContext context) {
    user = Provider.of<User>(context);
    ScreenUtil.init(context, height: CommonData.screenHeight, width: CommonData.screenWidth, allowFontScaling: true);
    return GestureDetector(
        onTap: () => Navigator.pushNamed(context, "/competition", arguments: [notification.competition, user]).then((value) => setState(() {})),
        child: Container(
            height: 70.h,
            margin: EdgeInsets.only(right: 10.w, left: 10.w, top: 10.h, bottom: 10.h),
            child: Stack(
              children: <Widget>[
                Positioned(
                  left: 25.w,
                  top: 5.h,
                  child: Image.network(notification.competition.image, height: 80.h, width: 80.w,),
                ),
                Positioned(
                  left: 120.w,
                  top: 11.h,
                  child: Container(height:70.h, width: 250.w, child: Text(notification.message, maxLines: 2, style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(13)),))
                ),
                Positioned(
                    left: 120.w,
                    top: 50.h,
                    child: Text(_parseDate(notification.notificationDate), maxLines: 2, style: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(10)),)
                ),
              ],
            )
        )
    );
  }

  String _parseDate(DateTime date){
    DateTime today = DateTime.now();
    if(today.difference(date).inDays == 0){
      return "Hace ${today.hour - date.hour}h";
    }
    if(today.difference(date).inDays == 1)
      return "Ayer";
    return "Hace ${today.difference(date).inDays} días";
  }
}
