import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:homeraces/model/competition.dart';
import 'package:homeraces/model/user.dart';
import 'package:homeraces/screens/calendar/competition_tile.dart';
import 'package:homeraces/shared/common_data.dart';
import 'package:provider/provider.dart';

class Calendar extends StatefulWidget {
  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> with TickerProviderStateMixin{
  User user;
  TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = new TabController(length: 4, vsync: this);
  }

  List<Widget> _competitionsTiles(List<Competition> competitions){
    List<Widget> list = List<Widget>();
    for(Competition competition in competitions){
      list.add(CompetitionTile(competition: competition,),);
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    user = Provider.of<User>(context);
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    ScreenUtil.init(context, height: CommonData.screenHeight, width: CommonData.screenWidth, allowFontScaling: true);
    return Scaffold(
      body: Column(
        children: <Widget>[
          SizedBox(height: 20.h,),
          Container(
            padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'HOME',
                      style: TextStyle(
                        fontFamily: 'Impact',
                        fontSize: ScreenUtil().setSp(31),
                        color: const Color(0xff000000),
                      ),
                      textAlign: TextAlign.left,
                    ),
                    Text(
                      'RACES',
                      style: TextStyle(
                        fontFamily: 'Ebrima',
                        fontSize: ScreenUtil().setSp(31),
                        color: const Color(0xff61b3d8),
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
                SizedBox(width: 70.w,),
                Container(
                    height: 70.h,
                    width: 70.w,
                  decoration: new BoxDecoration(
                    shape: BoxShape.circle,
                    image: new DecorationImage(
                      fit: BoxFit.fill,
                      image: new NetworkImage(user.image)
                    )
                  )
                )
              ],
            ),
          ),
          Divider(thickness: 1,),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(width: 8.w,),
              Text("TU CALENDARIO", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, fontFamily: "Arial"),),
              SizedBox(width: 115.w,),
              FlatButton(child: Text( 'Crear competición', style: TextStyle(fontSize: ScreenUtil().setSp(14), color: Colors.black,),))
          ],),
          SizedBox(height: 10.h,),
          Container(
            height: 55.h,
            child: Stack(
              children: <Widget>[
                TabBar(
                  isScrollable: true,
                  unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
                  controller: _controller,
                  tabs: <Widget>[
                    Tab(child: Text("TODOS", style: TextStyle(fontSize: ScreenUtil().setSp(14), color: Colors.black,),)),
                    Tab(child: Text("PARTICIPARÉ", style: TextStyle(fontSize: ScreenUtil().setSp(14), color: Colors.black,),),),
                    Tab(child: Text("GUARDADOS", style: TextStyle(fontSize: ScreenUtil().setSp(14), color: Colors.black,),),),
                    Tab(child: Text("PASADOS", style: TextStyle(fontSize: ScreenUtil().setSp(14), color: Colors.black,),),),
                  ],
                ),
                Align(alignment: Alignment.bottomCenter, child: Divider(thickness: 2,),)
              ],
            ),
          ),
          SizedBox(height: 20.h,),
          Container(
            height: 444.h,
            child: TabBarView(
              controller: _controller,
              children: <Widget>[
                ListView(children: _competitionsTiles(user.favorites + user.enrolled)),
                ListView(children: _competitionsTiles(user.enrolled.where((competition) => (competition.eventdate.difference(DateTime.now()).inDays >= 0) ).toList())),
                ListView(children: _competitionsTiles(user.favorites)),
                ListView(children: _competitionsTiles(user.enrolled.where((competition) => (competition.eventdate.difference(DateTime.now()).inDays < 0) ).toList())),
              ],
            ),
          )
        ],
      ),
    );
  }
}
