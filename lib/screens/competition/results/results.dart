import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:homeraces/model/comment.dart';
import 'package:homeraces/model/competition.dart';
import 'package:homeraces/model/race.dart';
import 'package:homeraces/model/user.dart';
import 'package:homeraces/screens/competition/comments/comment_box.dart';
import 'package:homeraces/services/dbservice.dart';
import 'package:homeraces/shared/alert.dart';
import 'package:homeraces/shared/common_data.dart';
import 'package:homeraces/shared/functions.dart';

class RaceResults extends StatefulWidget {
  @override
  _RaceResultsState createState() => _RaceResultsState();
}

class _RaceResultsState extends State<RaceResults> {
  User user;
  Competition competition;
  List<RaceData> data;

  void _timer() {
    if(data == null) {
      Future.delayed(Duration(seconds: 2)).then((_) {
        setState(() {
          print("Loading...");
        });
        _timer();
      });
    }
  }
  
  void _loadData() async{
    data = await DBService.dbService.getRaceData(competition.id.toString());
  }

  @override
  Widget build(BuildContext context) {
    var args = List<Object>.of(ModalRoute.of(context).settings.arguments);
    competition = args.first;
    user = args.last;
    _loadData();
    _timer();
    return Scaffold(backgroundColor: Colors.white, appBar:
      AppBar(
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black,),
          onPressed: () => Navigator.pop(context),
        ),
        actions: <Widget>[
          IconButton(
            icon: user.favorites.contains(competition) ? Icon(Icons.star, size: ScreenUtil().setSp(35), color: Colors.yellow,) :
            Icon(Icons.star_border, size: ScreenUtil().setSp(35), color: Colors.grey[350],),
            onPressed: (){
              setState(() {
                if(user.favorites.contains(competition)){
                  user.favorites.remove(competition);
                  DBService.dbService.deleteFromFavorites(user.id, competition.id);
                }
                else{
                  user.favorites.add(competition);
                  DBService.dbService.addToFavorites(user.id, competition.id);
                }
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.share),
          ),
          SizedBox(width: 10.w)
        ],
        backgroundColor: Colors.white,
      ),

      body: Column(
        children: <Widget>[
          Container(
            height: 137.h,
            child: Stack(
              children: <Widget>[
                Positioned(
                    left: 20.w,
                    top: 10.h,
                    child: Image.network(competition.image, height: 120.h, width: 120.w,)
                ),
                Positioned(
                    left: 155.w,
                    top: 12.h,
                    child: Text(competition.name.toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: ScreenUtil().setSp(18)),)
                ),
                Positioned(
                  left: 155.w,
                  top: 35.h,
                  child: competition.eventdate == null? Container(height: 0,) : Container(
                    height: 300.h,
                    width: 220.w,
                    child: Column(
                      children: <Widget>[
                        SizedBox(height: 10.h,),
                        Row(
                          children: <Widget>[
                            Icon(Icons.calendar_today, size: ScreenUtil().setSp(20),),
                            SizedBox(width: 13.w,),
                            Text(Functions.parseDate(competition.eventdate, false), style: TextStyle(fontWeight: FontWeight.bold, fontSize: ScreenUtil().setSp(16), color: const Color(0xff61b3d8)),),
                            SizedBox(width: 6.w,),
                            Text("de  ${competition.eventdate.toString().substring(0,4)}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: ScreenUtil().setSp(16), color: const Color(0xff61b3d8)),),
                          ],
                        ),
                        SizedBox(height: 35.h,),
                        Row(
                          children: <Widget>[
                            Text("CLASIFICACIÓN", style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(16)),),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              ],),
          ),
          Divider(thickness: 1,),
          data == null? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),),
            ],) :
          Expanded(
            child: ListView(
              children: <Widget>[],
            ),
          )
        ],
      ),
    );
  }
}
