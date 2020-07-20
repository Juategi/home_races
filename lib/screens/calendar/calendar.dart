import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
    ScreenUtil.init(context, height: CommonData.screenHeight, width: CommonData.screenWidth, allowFontScaling: true);
    return Scaffold(
      body: Column(
        children: <Widget>[
          SizedBox(height: 20.h,),
          Container(
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  height: 100.h,
                  width: 100.w,
                  child: Image.asset("assets/auth/Logo.png")
                ),
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
              FlatButton(child: Text( 'Crear competición', style: TextStyle(fontSize: ScreenUtil().setSp(14), color: Colors.black,),),
                onPressed: (){Navigator.pushNamed(context, "/newcompetition", arguments: user);},
              )
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
          /*SizedBox(height: 5.h,),
          Row(mainAxisAlignment:MainAxisAlignment.end,children: <Widget>[
            IconButton(icon: Icon(Icons.format_list_numbered_rtl), iconSize: ScreenUtil().setSp(35),)
          ],),
          SizedBox(height: 5.h,),*/
          Flexible(
            //height: (100*(user.favorites + user.enrolled).toSet().toList().length).h,
            child: TabBarView(
              controller: _controller,
              children: <Widget>[
                ListView(children: _competitionsTiles((user.favorites + user.enrolled).toSet().toList())),
                ListView(children: _competitionsTiles(user.enrolled.where((competition) => (competition.eventdate.difference(DateTime.now()).inDays >= 0) ).toList())),
                ListView(children: _competitionsTiles(user.favorites)),
                ListView(children: _competitionsTiles(user.enrolled.where((competition) => (competition.enddate.difference(DateTime.now()).inDays < 0)).toList()  )),
              ],
            ),
          )
        ],
      ),
    );
  }
}
