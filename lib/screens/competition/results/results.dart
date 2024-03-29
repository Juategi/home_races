import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:homeraces/model/competition.dart';
import 'package:homeraces/model/race_data.dart';
import 'package:homeraces/model/user.dart';
import 'package:homeraces/services/dbservice.dart';
import 'package:homeraces/shared/common_data.dart';
import 'package:homeraces/shared/functions.dart';
import 'package:homeraces/shared/loading.dart';

class RaceResults extends StatefulWidget {
  @override
  _RaceResultsState createState() => _RaceResultsState();
}

class _RaceResultsState extends State<RaceResults> with TickerProviderStateMixin{
  User user;
  Competition competition;
  List<RaceData> data;
  RaceData raceData;
  int pos;
  TabController _controller;

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
    if(data.length == 0){
      pos = 0;
      return;
    }
    if(raceData == null)
      pos = data.indexOf(data.firstWhere((rc) => rc.userid == user.id));
    else
      pos = data.indexOf(data.firstWhere((rc) => rc.id == raceData.id));
  }

  @override
  void initState() {
    _controller = new TabController(length: 5, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var args = List<Object>.of(ModalRoute.of(context).settings.arguments);
    competition = args.first;
    user = args[1];
    raceData = args.last;
    _loadData();
    _timer();
    ScreenUtil.init(context, height: CommonData.screenHeight, width: CommonData.screenWidth, allowFontScaling: true);
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

      body:Column(
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
          data == null || (data != null && data.length == 0)? Container() : Column(
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
              SizedBox(height: 200.h,),
              CircularLoading(),
            ],
          ) : data != null && data.length == 0? Container() :
          Container(
            height: 55.h,
            child: Stack(
              children: <Widget>[
                TabBar(
                  isScrollable: true,
                  unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
                  controller: _controller,
                  tabs: <Widget>[
                    Tab(child: Container(alignment: Alignment.center, width: 75.w, child: Text("TODOS", style: TextStyle(fontSize: ScreenUtil().setSp(14), color: Colors.black,),))),
                    Tab(child: Container(alignment: Alignment.center, width: 100.w, child: Text("SENIOR MASC.", style: TextStyle(fontSize: ScreenUtil().setSp(14), color: Colors.black,),)),),
                    Tab(child: Container(alignment: Alignment.center, width: 85.w, child: Text("SENIOR FEM.", style: TextStyle(fontSize: ScreenUtil().setSp(14), color: Colors.black,),)),),
                    Tab(child: Container(alignment: Alignment.center, width: 105.w, child: Text("JUVENIL MASC.", style: TextStyle(fontSize: ScreenUtil().setSp(14), color: Colors.black,),)),),
                    Tab(child: Container(alignment: Alignment.center, width: 95.w, child: Text("JUVENIL FEM.", style: TextStyle(fontSize: ScreenUtil().setSp(14), color: Colors.black,),)),),
                  ],
                ),
                Align(alignment: Alignment.bottomCenter, child: Divider(thickness: 2,),)
              ],
            ),
          ),
          data == null? Container(height: 0,):Flexible(
            //height: (100*(user.favorites + user.enrolled).toSet().toList().length).h,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: TabBarView(
                controller: _controller,
                children: <Widget>[
                  ListView(children: _initRows("N", "N"),),
                  ListView(children: _initRows("M", "S"),),
                  ListView(children: _initRows("W", "S"),),
                  ListView(children: _initRows("M", "J"),),
                  ListView(children: _initRows("W", "J"),),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

 List<Widget> _initRows(String sex, String senior){
   List<Widget> result = List<Widget>();
   for(int i = 0; i < data.length; i++){
    if( (sex == "N" && senior == "N") ||
        (sex == "M" && data[i].sex == "M" && senior == "S" && data[i].birthdate.year < 1990) ||
        (sex == "W" && data[i].sex == "W" && senior == "S" && data[i].birthdate.year < 1990) ||
        (sex == "M" && data[i].sex == "M" && senior == "J" && data[i].birthdate.year > 1990) ||
        (sex == "W" && data[i].sex == "W" && senior == "J" && data[i].birthdate.year > 1990)
    ) {
      result.add(Row(
        children: <Widget>[
          i < 3 ?
          Container(
              height: 33.h,
              width: 33.w,
              child: Image.asset(
                  "assets/competition/Trofeo-${(i + 1).toString()}.png")
          )
              : Container(alignment: Alignment.center,
              width: 33.w,
              child: Text("${(i + 1).toString()}",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: (i + 1)
                    .toString()
                    .length > 3 ? ScreenUtil().setSp(13) : ScreenUtil().setSp(
                    17)),)),
          SizedBox(width: 10.w,),
          Container(
              height: 30.h,
              width: 30.w,
              decoration: new BoxDecoration(
                  shape: BoxShape.circle,
                  image: new DecorationImage(
                      fit: BoxFit.fill,
                      image: new NetworkImage(
                          data[i].image ?? CommonData.defaultProfile)
                  )
              )
          ),
          SizedBox(width: 10.w,),
          Container(width: 85.w,
              child: Text("${data[i].firstname}", style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: ScreenUtil().setSp(14)),)),
          SizedBox(width: 30.w,),
          Text(Functions.parseTimeSeconds(data[i].time), style: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: ScreenUtil().setSp(15)),),
          SizedBox(width: 20.w,),
          GestureDetector(
            child: Text("Ver parciales", style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: ScreenUtil().setSp(13),
                color: Color(0xff61b3d8)),),
            onTap: () {
              Navigator.pushNamed(context, "/partials",
                  arguments: [competition, data[i], user]);
            },
          )
        ],
      ));
      result.add(SizedBox(height: 20.h,),);
    }
   }
   return result;
 }
}
