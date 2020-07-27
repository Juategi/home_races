import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:homeraces/model/competition.dart';
import 'package:homeraces/model/user.dart';
import 'package:homeraces/screens/calendar/competition_tile.dart';
import 'package:homeraces/services/dbservice.dart';
import 'package:homeraces/shared/common_data.dart';
import 'package:homeraces/shared/loading.dart';
import 'package:provider/provider.dart';

class OwnedCompetitions extends StatefulWidget {
  @override
  _OwnedCompetitionsState createState() => _OwnedCompetitionsState();
}

class _OwnedCompetitionsState extends State<OwnedCompetitions> with TickerProviderStateMixin{

  User user;
  TabController _controller;
  List<Competition> owned;

  void _timer() {
    if(owned == null) {
      Future.delayed(Duration(seconds: 2)).then((_) {
        setState(() {
          print("Loading...");
        });
        _timer();
      });
    }
  }

  Future _loadOwned() async{
    owned = await DBService.dbService.getCompetitionsOrganizer(user.id);
  }

  @override
  void initState() {
    super.initState();
    _controller = new TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    user = ModalRoute.of(context).settings.arguments;
    _loadOwned();
    _timer();
    ScreenUtil.init(context, height: CommonData.screenHeight, width: CommonData.screenWidth, allowFontScaling: true);
    return Provider<User>.value(
      value: user,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.black,),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: owned == null? Column( mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircularLoading(),
          ],
        ) :Column(
          children: <Widget>[
            Container(
              height: 55.h,
              child: Stack(
                children: <Widget>[
                  TabBar(
                    isScrollable: true,
                    unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
                    controller: _controller,
                    tabs: <Widget>[
                      Tab(child: Container(alignment: Alignment.center, width: 163.w, child: Text("TODOS", style: TextStyle(fontSize: ScreenUtil().setSp(20), color: Colors.black,),))),
                      Tab(child: Container(alignment: Alignment.center, width: 163.w, child: Text("EDITABLES", style: TextStyle(fontSize: ScreenUtil().setSp(20), color: Colors.black,),)),),
                    ],
                  ),
                  Align(alignment: Alignment.bottomCenter, child: Divider(thickness: 2,),)
                ],
              ),
            ),
            Flexible(
              //height: (100*(user.favorites + user.enrolled).toSet().toList().length).h,
              child: TabBarView(
                controller: _controller,
                children: <Widget>[
                  ListView(children: _competitionsTiles(owned)),
                  ListView(children: _competitionsTiles(owned.where((c) => (c.eventdate == null || c.eventdate.isAfter(DateTime.now()))).toList())),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
  List<Widget> _competitionsTiles(List<Competition> competitions){
    List<Widget> list = List<Widget>();
    for(Competition competition in competitions){
      list.add(OwnerTile(competition: competition,),);
    }
    return list;
  }

}
