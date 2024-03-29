import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:homeraces/model/competition.dart';
import 'package:homeraces/model/race_data.dart';
import 'package:homeraces/model/user.dart';
import 'package:homeraces/services/dbservice.dart';
import 'package:homeraces/shared/common_data.dart';
import 'package:homeraces/shared/functions.dart';
import 'package:homeraces/shared/loading.dart';

class PartialsData extends StatefulWidget {
  @override
  _PartialsDataState createState() => _PartialsDataState();
}

class _PartialsDataState extends State<PartialsData> with TickerProviderStateMixin{
  RaceData data;
  User user;
  Competition competition;
  TabController _controller;
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
    if(data.partials == null)
      data.partials = await DBService.dbService.getRacePartials(data.id.toString());
  }

  @override
  void initState() {
    _controller = new TabController(length: 4, vsync: this);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    var args = List<Object>.of(ModalRoute.of(context).settings.arguments);
    competition = args.first;
    user = args.last;
    data = args[1];
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
          Container(
            height: 55.h,
            child: Stack(
              children: <Widget>[
                TabBar(
                  isScrollable: true,
                  unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
                  controller: _controller,
                  tabs: <Widget>[
                    Tab(child: Container(alignment: Alignment.center, width: 65.w, child: Text("1 KM", style: TextStyle(fontSize: ScreenUtil().setSp(16), color: Colors.black,),))),
                    Tab(child: Container(alignment: Alignment.center, width: 65.w, child: Text("2 KM", style: TextStyle(fontSize: ScreenUtil().setSp(16), color: Colors.black,),)),),
                    Tab(child: Container(alignment: Alignment.center, width: 65.w, child: Text("5 KM", style: TextStyle(fontSize: ScreenUtil().setSp(16), color: Colors.black,),)),),
                    Tab(child: Container(alignment: Alignment.center, width: 65.w, child: Text("10 KM", style: TextStyle(fontSize: ScreenUtil().setSp(16), color: Colors.black,),)),),
                  ],
                ),
                Align(alignment: Alignment.bottomCenter, child: Divider(thickness: 2,),)
              ],
            ),
          ),
          data.partials == null? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 200.h,),
              CircularLoading(),
            ],
          ) :Flexible(
            //height: (100*(user.favorites + user.enrolled).toSet().toList().length).h,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: TabBarView(
                controller: _controller,
                children: <Widget>[
                  ListView(children: _initList(1),),
                  ListView(children: _initList(2),),
                  ListView(children: _initList(5),),
                  ListView(children: _initList(10),),
                ],
              ),
            ),
          )
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 5.h),
          child: RawMaterialButton(
              child: Text("Ver recorrido", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white, fontSize: ScreenUtil().setSp(30),),),
              fillColor:  Color(0xff61b3d8),
              shape: RoundedRectangleBorder(),
              elevation: 0,
              padding: EdgeInsets.only(right: 18.0.w, bottom: 10.0.h,top: 10.0.h,left: 18.w),
              onPressed: ()async{
                Navigator.pushNamed(context, "/map", arguments: data);
              }
          ),
        ),
      ),
    );
  }

  List<int> _MinMaxPos(int km){
    int min = 9999999999;
    int max = 0;
    int minPos = 1;
    int maxPos = 1;
    for(int i = 1; i <= data.partials.keys.length; i+=km) {
      num time = 0;
      if(i == data.partials.keys.length){
        time += data.partials[i];
      } else {
        for (int j = i; j < i + km; j++) {
          time += data.partials[j];
        }
      }
      if(time > max){
        max = time;
        maxPos = i;
      }
      if(time < min){
        min = time;
        minPos = i;
      }
    }

    int aux = data.partials.keys.length % km;
    if(aux != 0) {
      num time = 0;
      for (int i = data.partials.keys.length - aux; i <=
          data.partials.keys.length; i++) {
        time += data.partials[i];
      }
      if (time > max) {
        max = time;
        maxPos = data.partials.keys.length - aux;
      }
      if (time < min) {
        min = time;
        minPos = data.partials.keys.length - aux;
      }
    }
      return [minPos,maxPos];
  }

  List<Widget> _initList(int km){
    List<Widget> result = List<Widget>();
    if(km > data.partials.keys.length){
      km = data.partials.keys.length;
    }
    List<int> minMax = _MinMaxPos(km);
    for(int i = 1; i <= data.partials.keys.length; i+=km){
      num time = 0;
      if(i == data.partials.keys.length){
        time += data.partials[i];
      }else {
        for (int j = i; j < i + km; j++) {
          time += data.partials[j];
        }
      }
      result.add(Row(
        children: <Widget>[
          Container(width: 50.w, child: Text("$i km", style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(14)),)),
          SizedBox(width: 37.w,),
          Text(Functions.parseMinKm(time, km), style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(14)),),
          SizedBox(width: 37.w,),
          Text("${(km/(time/3600)).toStringAsFixed(1)} km/h", style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(14)),),
          SizedBox(width: 32.w,),
          i == minMax.first ? Container(
            height: 30.h,
            width: 30.w,
            child: SvgPicture.asset(
              "assets/competition/Rapido.svg",
              color: Colors.lightBlueAccent,
            ),
          ):
              i == minMax.last? Container(
                height: 30.h,
                width: 30.w,
                child: SvgPicture.asset(
                  "assets/competition/Lento.svg",
                  color: Colors.lightBlueAccent,
                ),
              ): Container()
        ],
      ));
      result.add(SizedBox(height: 20.h,),);
    }
    int aux = data.partials.keys.length % km;
    if(aux != 0 && aux != 1){
      num time = 0;
      for(int i = data.partials.keys.length - aux; i <= data.partials.keys.length; i++){
        time += data.partials[i];
      }
      result.add(Row(
        children: <Widget>[
          Container(width: 50.w, child: Text("${data.partials.keys.length - aux} km", style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(14)),)),
          SizedBox(width: 37.w,),
          Text(Functions.parseMinKm(time, aux), style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(14)),),
          SizedBox(width: 37.w,),
          Text("${(aux/(time/3600)).toStringAsFixed(1)} km/h", style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(14)),),
          SizedBox(width: 32.w,),
          data.partials.keys.length - aux == minMax.first ? Container(
            height: 30.h,
            width: 30.w,
            child: SvgPicture.asset(
              "assets/competition/Rapido.svg",
              color: Colors.lightBlueAccent,
            ),
          ):
          data.partials.keys.length - aux == minMax.last? Container(
            height: 30.h,
            width: 30.w,
            child: SvgPicture.asset(
              "assets/competition/Lento.svg",
              color: Colors.lightBlueAccent,
            ),
          ): Container()
        ],
      ));
      result.add(SizedBox(height: 20.h,),);
    }
    return result;
  }
}
