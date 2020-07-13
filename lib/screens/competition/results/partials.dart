import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:homeraces/model/competition.dart';
import 'package:homeraces/model/race.dart';
import 'package:homeraces/model/user.dart';
import 'package:homeraces/services/dbservice.dart';
import 'package:homeraces/shared/common_data.dart';
import 'package:homeraces/shared/functions.dart';

class PartialsData extends StatefulWidget {
  @override
  _PartialsDataState createState() => _PartialsDataState();
}

class _PartialsDataState extends State<PartialsData> {
  RaceData data;
  User user;
  Competition competition;
  void _timer() {
    if(data.partials == null) {
      Future.delayed(Duration(seconds: 2)).then((_) {
        setState(() {
          print("Loading...");
        });
        _timer();
      });
    }
  }

  void _loadData() async{
    data.partials = await DBService.dbService.getRacePartials(data.id.toString());
  }

  @override
  Widget build(BuildContext context) {
    var args = List<Object>.of(ModalRoute.of(context).settings.arguments);
    competition = args.first;
    user = args.last;
    data = args[1];
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
                            Text("PARCIALES", style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(14)),),
                            SizedBox(width: 30.w,),
                            Container(
                                height: 25.h,
                                width: 25.w,
                                decoration: new BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: new DecorationImage(
                                        fit: BoxFit.fill,
                                        image: new NetworkImage(data.image?? CommonData.defaultProfile)
                                    )
                                )
                            ),
                            SizedBox(width: 10.w,),
                            Container(width: 60.w,child: Text("${data.firstname}", style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(14)),)),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              ],),
          ),
          Divider(thickness: 1,),
        ],
      ),
    );
  }
}
