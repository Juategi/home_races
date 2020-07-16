import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:homeraces/model/competition.dart';
import 'package:homeraces/model/user.dart';
import 'package:homeraces/model/notification.dart';
import 'package:homeraces/services/dbservice.dart';
import 'package:homeraces/shared/common_data.dart';
import 'package:provider/provider.dart';

class Notifications extends StatefulWidget {
  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  User user;
  List<Widget> tiles;
  Widget aux;

  void _timerNotifications(){
    Future.delayed(Duration(seconds: 80)).then((_) async {
      if(user != null){
        user.notifications = await DBService.dbService.getNotifications(user.id);
        setState(() {
          print("Getting notifications...");
        });
      }
      _timerNotifications();
    });
  }

  String _parseDate(DateTime date){
    DateTime today = DateTime.now();
    if(today.difference(date).inDays == 0){
      if(today.difference(date).inHours != 0)
        return "Hace ${today.difference(date).inHours}h";
      else if(today.difference(date).inMinutes != 0)
        return "Hace ${today.difference(date).inMinutes} minutos";
      else
        return "Hace ${today.difference(date).inSeconds} segundos";
    }
    if(today.difference(date).inDays == 1)
      return "Ayer";
    return "Hace ${today.difference(date).inDays} días";
  }

  @override
  void initState() {
    //_timerNotifications();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    user = Provider.of<User>(context);
    tiles = null;
    tiles = List<Widget>();
    for (NotificationUser notification in user.notifications) {
      aux = GestureDetector(
          onTap: () async {
            if(notification.userreference == "null") {
              DBService.dbService.deleteNotification(notification.id.toString());
              setState(() {
                user.notifications.removeWhere((element) => element.id == notification.id);
              });
              Navigator.pushNamed(context, "/competition",
                  arguments: [notification.competition, user]).then((value) =>
                  setState(() {}));
            }
            else {
              User userReference = await DBService.dbService.getUserDataChecker(
                  notification.userreference);
              String result = await showDialog(
                  context: context,
                  builder: (_) => AcceptDialog(user: userReference, competitionid: notification.competition.id.toString(),),
                  barrierDismissible: false,
              );
              if(result == "Ok"){
                DBService.dbService.deleteNotification(notification.id.toString());
                setState(() {
                  user.notifications.removeWhere((element) => element.id == notification.id);
                });
              }
            }
          } ,
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
      tiles.add(aux);
    }
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
      body: user.notifications == null? Row(
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
              children: tiles,
            ),
          ),
        ],
      ),
    );
  }
}

class AcceptDialog extends StatelessWidget {
  AcceptDialog({this.user, this.competitionid});
  User user;
  String competitionid;
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black87,
      child: Container(
        width: 400.w,
        height: 180.h,
        decoration: BoxDecoration(
            color: Colors.black87,
            border: Border.all(color: Colors.black87),
            borderRadius: new BorderRadius.only(
              topLeft: const Radius.circular(20.0),
              topRight: const Radius.circular(20.0),
              bottomLeft: const Radius.circular(20.0),
              bottomRight: const Radius.circular(20.0),
            )
        ),
        child: Stack(
          children: <Widget>[
            Positioned(
              left: 260.w,
              bottom: 140.h,
              child: IconButton(
                icon: Icon(Icons.cancel, color: Colors.red, size: ScreenUtil().setSp(40),),
                onPressed: ()async{
                  Navigator.pop(context);
                },
              ),
            ),
            Positioned(
                left: 55.w,
                top: 30.h,
                child: Container(width: 230.w,child: Text("¿Deseas aceptar en la competición al usuario ${user.firstname} ${user.lastname}?", maxLines: 3, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: ScreenUtil().setSp(18),)))
            ),
            Positioned(
              left: 25.w,
              bottom: 20.h,
              child: RawMaterialButton(
                child: Text("Aceptar", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white, fontSize: ScreenUtil().setSp(20,allowFontScalingSelf: true),),),
                fillColor: Color(0xff61b3d8),
                shape: RoundedRectangleBorder(),
                padding: EdgeInsets.only(right: 20.0.w, bottom: 12.0.h,top: 12.0.h,left: 20.w),
                onPressed: ()async{
                  await DBService.dbService.enrrollCompetition(user.id, competitionid);
                  await DBService.dbService.deletePrivate(user.id, competitionid);
                  Navigator.pop(context, "Ok");
                },
              ),
            ),
            Positioned(
              left: 160.w,
              bottom: 20.h,
              child: RawMaterialButton(
                child: Text("Rechazar", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white, fontSize: ScreenUtil().setSp(20,allowFontScalingSelf: true),),),
                fillColor: Color(0xff61b3d8),
                shape: RoundedRectangleBorder(),
                padding: EdgeInsets.only(right: 20.0.w, bottom: 12.0.h,top: 12.0.h,left: 20.w),
                onPressed: ()async{
                  await DBService.dbService.deletePrivate(user.id, competitionid);
                  Navigator.pop(context, "Ok");
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

