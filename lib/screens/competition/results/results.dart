import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:homeraces/model/competition.dart';
import 'package:homeraces/model/race.dart';
import 'package:homeraces/model/user.dart';
import 'package:homeraces/services/dbservice.dart';
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
  int pos;

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
    data.sort(
            (r1,r2){
          return r1.time.compareTo(r2.time);
        }
    );
    pos = data.indexOf(data.firstWhere((rc) => rc.userid == user.id));
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
          data == null? Container() : Column(
            children: <Widget>[
              Divider(thickness: 2,),
              Padding(
                padding: EdgeInsets.only(left: 20.h, right: 20.w, top: 4.h, bottom: 4.h),
                child: Row(
                  children: <Widget>[
                    pos < 3?
                    Container(
                        height: 33.h,
                        width: 33.w,
                        child: Image.asset("assets/competition/Trofeo-${(pos+1).toString()}.png")
                    )
                        :Container(alignment: Alignment.center, width: 33.w,child: Text("${(pos+1).toString()}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: (pos+1).toString().length > 3? ScreenUtil().setSp(13) : ScreenUtil().setSp(17)),)),
                    SizedBox(width: 10.w,),
                    Container(
                        height: 30.h,
                        width: 30.w,
                        decoration: new BoxDecoration(
                            shape: BoxShape.circle,
                            image: new DecorationImage(
                                fit: BoxFit.fill,
                                image: new NetworkImage(user.image?? CommonData.defaultProfile)
                            )
                        )
                    ),
                    SizedBox(width: 10.w,),
                    Container(width: 85.w,child: Text("${data[pos].firstname}", style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(14)),)),
                    SizedBox(width: 30.w,),
                    Text(Functions.parseTimeSeconds(data[pos].time), style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(15)),),
                    SizedBox(width: 20.w,),
                    GestureDetector(
                      child: Text("Ver parciales", style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(13), color: Color(0xff61b3d8)),),
                      onTap: (){
                        Navigator.pushNamed(context, "/partials", arguments: [competition,data[pos],user]);
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
          Divider(thickness: 2,),
          data == null? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),),
            ],) :
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: _initRows()
            ),
          )
        ],
      ),
    );
  }

 List<Widget> _initRows(){
   List<Widget> result = List<Widget>();
   for(int i = 0; i < data.length; i++){
     result.add(Row(
       children: <Widget>[
         i < 3?
         Container(
           height: 33.h,
           width: 33.w,
           child: Image.asset("assets/competition/Trofeo-${(i+1).toString()}.png")
        )
         :Container(alignment: Alignment.center, width: 33.w,child: Text("${(i+1).toString()}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: (i+1).toString().length > 3? ScreenUtil().setSp(13) : ScreenUtil().setSp(17)),)),
         SizedBox(width: 10.w,),
         Container(
             height: 30.h,
             width: 30.w,
             decoration: new BoxDecoration(
                 shape: BoxShape.circle,
                 image: new DecorationImage(
                     fit: BoxFit.fill,
                     image: new NetworkImage(data[i].image?? CommonData.defaultProfile)
                 )
             )
         ),
         SizedBox(width: 10.w,),
         Container(width: 85.w,child: Text("${data[i].firstname}", style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(14)),)),
         SizedBox(width: 30.w,),
         Text(Functions.parseTimeSeconds(data[i].time), style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(15)),),
         SizedBox(width: 20.w,),
         GestureDetector(
           child: Text("Ver parciales", style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(13), color: Color(0xff61b3d8)),),
           onTap: (){
             Navigator.pushNamed(context, "/partials", arguments: [competition,data[i],user]);
           },
         )
       ],
     ));
     result.add(SizedBox(height: 20.h,),);
   }
   return result;
 }
}
