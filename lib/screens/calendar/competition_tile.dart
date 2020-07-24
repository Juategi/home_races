import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:homeraces/model/competition.dart';
import 'package:homeraces/model/race_data.dart';
import 'package:homeraces/model/user.dart';
import 'package:homeraces/shared/common_data.dart';
import 'package:homeraces/shared/functions.dart';
import 'package:provider/provider.dart';

class CompetitionTile extends StatefulWidget {
  Competition competition;
  CompetitionTile({this.competition});
  @override
  _CompetitionTileState createState() => _CompetitionTileState(competition: competition);
}

class _CompetitionTileState extends State<CompetitionTile> {
  Competition competition;
  User user;
  _CompetitionTileState({this.competition});
  @override
  Widget build(BuildContext context) {
    user = Provider.of<User>(context);
    ScreenUtil.init(context, height: CommonData.screenHeight, width: CommonData.screenWidth, allowFontScaling: true);
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, "/competition", arguments: [competition, user]).then((value) => setState(() {})),
      child: Card(
        child: Container(
          height: 135.h,
          //width: 100.w,
          child: Stack(
            children: <Widget>[
              Positioned(
                left: 10.w,
                top: 5.h,
                child: Image.network(competition.image, height: 125.h, width: 125.w,),
              ),
              Positioned(
                left: 160.w,
                top: 10.h,
                child: Text(competition.name.toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: ScreenUtil().setSp(15)),),
              ),
              Positioned(
                left: 160.w,
                top: 33.h,
                child: Text(competition.eventdate == null? "" : Functions.parseDate(competition.eventdate, true), style: TextStyle(fontWeight: FontWeight.bold, fontSize: ScreenUtil().setSp(12), color: const Color(0xff61b3d8)),),
              ),
              Positioned(
                left: 330.w,
                top: 33.h,
                child: Text(competition.eventdate == null? "" : Functions.parseTime(competition.eventdate), style: TextStyle(fontWeight: FontWeight.bold, fontSize: ScreenUtil().setSp(13), color: const Color(0xff61b3d8)),),
              ),
              Positioned(
                left: 160.w,
                top: 50.h,
                child: Text("${competition.modality} - ${competition.locality}", style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(13), color: Colors.grey),),
              ),
              /*Positioned(
                left: 193.w,
                top: 100.h,
                child: Text(competition.numcompetitors == 1? "${competition.numcompetitors} participante" :
                "${competition.numcompetitors} participantes", style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(11), color: Colors.grey),),
              ),*/
              Positioned(
                left: 160.w,
                top: 95.h,
                child: Row(children: _initImages(),
                ),
              ),
              Positioned(
                left: 330.w,
                top: 80.h,
                child: IconButton(
                    icon: user.favorites.contains(competition) ? Icon(Icons.star, size: ScreenUtil().setSp(35), color: Colors.yellow,) :
                        Icon(Icons.star_border, size: ScreenUtil().setSp(35), color: Colors.grey[350],),
                ),
                //child: Icon(Icons.star_border, size: ScreenUtil().setSp(35), color: Colors.grey[350],),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _initImages(){
    List<Widget> list = [];
    if(competition.usersImages.length == 0){
      list.add(Container(
          margin: EdgeInsets.only(right: 1.w),
          height: 20.h,
          width: 20.w,
          decoration: new BoxDecoration(
              shape: BoxShape.circle,
              image: new DecorationImage(
                  fit: BoxFit.fill,
                  image: new NetworkImage(CommonData.defaultProfile)
              )
          )
      ));
    }
    else{
      for(int i = 0; i < competition.usersImages.length && i < 3; i++){
        list.add(Container(
            margin: EdgeInsets.only(right: 1.w),
            height: 20.h,
            width: 20.w,
            decoration: new BoxDecoration(
                shape: BoxShape.circle,
                image: new DecorationImage(
                    fit: BoxFit.fill,
                    image: new NetworkImage(competition.usersImages[i] == "null" || competition.usersImages[i] == null ? CommonData.defaultProfile : competition.usersImages[i])
                )
            )
        ));
      }
    }
    list.add(SizedBox(width: 5,));
    list.add(Text(competition.numcompetitors == 1? "${competition.numcompetitors} participante" :
    "${competition.numcompetitors} participantes", style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(11), color: Colors.grey),));
    return list;
  }

}

class TimesLessTile extends StatelessWidget {
  Competition competition;
  User user;
  RaceData raceData;
  TimesLessTile({this.raceData,this.competition});

  List<Widget> _initImages(){
    List<Widget> list = [];
    if(competition.usersImages.length == 0){
      list.add(Container(
          margin: EdgeInsets.only(right: 1.w),
          height: 20.h,
          width: 20.w,
          decoration: new BoxDecoration(
              shape: BoxShape.circle,
              image: new DecorationImage(
                  fit: BoxFit.fill,
                  image: new NetworkImage(CommonData.defaultProfile)
              )
          )
      ));
    }
    else{
      for(int i = 0; i < competition.usersImages.length && i < 3; i++){
        list.add(Container(
            margin: EdgeInsets.only(right: 1.w),
            height: 20.h,
            width: 20.w,
            decoration: new BoxDecoration(
                shape: BoxShape.circle,
                image: new DecorationImage(
                    fit: BoxFit.fill,
                    image: new NetworkImage(competition.usersImages[i] == "null" || competition.usersImages[i] == null ? CommonData.defaultProfile : competition.usersImages[i])
                )
            )
        ));
      }
    }
    list.add(SizedBox(width: 5,));
    list.add(Text(competition.numcompetitors == 1? "${competition.numcompetitors} participante" :
    "${competition.numcompetitors} participantes", style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(11), color: Colors.grey),));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    user = Provider.of<User>(context);
    ScreenUtil.init(context, height: CommonData.screenHeight, width: CommonData.screenWidth, allowFontScaling: true);
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, "/results", arguments: [competition, user, raceData]),
      child: Card(
        child: Container(
          height: 135.h,
          //width: 100.w,
          child: Stack(
            children: <Widget>[
              Positioned(
                left: 10.w,
                top: 5.h,
                child: Image.network(competition.image, height: 125.h, width: 125.w,),
              ),
              Positioned(
                left: 160.w,
                top: 10.h,
                child: Text(competition.name.toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: ScreenUtil().setSp(15)),),
              ),
              Positioned(
                left: 160.w,
                top: 33.h,
                child: Text("${Functions.parseDate(raceData.racedate, true)} ${raceData.racedate.toString().substring(0,4)}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: ScreenUtil().setSp(12), color: const Color(0xff61b3d8)),),
              ),
              Positioned(
                left: 160.w,
                top: 50.h,
                child: Text("${competition.modality} - ${competition.locality}", style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(13), color: Colors.grey),),
              ),
              /*Positioned(
                left: 193.w,
                top: 100.h,
                child: Text(competition.numcompetitors == 1? "${competition.numcompetitors} participante" :
                "${competition.numcompetitors} participantes", style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(11), color: Colors.grey),),
              ),*/
              Positioned(
                left: 160.w,
                top: 95.h,
                child: Row(children: _initImages(),
                ),
              ),
              Positioned(
                left: 330.w,
                top: 80.h,
                child: IconButton(
                  icon: user.favorites.contains(competition) ? Icon(Icons.star, size: ScreenUtil().setSp(35), color: Colors.yellow,) :
                  Icon(Icons.star_border, size: ScreenUtil().setSp(35), color: Colors.grey[350],),
                ),
                //child: Icon(Icons.star_border, size: ScreenUtil().setSp(35), color: Colors.grey[350],),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
