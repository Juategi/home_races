import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:homeraces/model/competition.dart';
import 'package:homeraces/model/user.dart';
import 'package:homeraces/shared/common_data.dart';
import 'package:homeraces/shared/functions.dart';
import 'package:provider/provider.dart';

class CompetitionCard extends StatefulWidget {
  CompetitionCard({this.competition});
  Competition competition;
  @override
  _CompetitionCardState createState() => _CompetitionCardState(competition: competition);
}

class _CompetitionCardState extends State<CompetitionCard> {
  _CompetitionCardState({this.competition});
  Competition competition;
  User user;
  @override
  Widget build(BuildContext context) {
    user = Provider.of<User>(context);
    ScreenUtil.init(context, height: CommonData.screenHeight, width: CommonData.screenWidth, allowFontScaling: true);
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, "/competition", arguments: [competition, user]).then((value) => setState(() {})),
      child: Card(
        child: Container(
          width: 190.w,
          child: Stack(
            children: <Widget>[
              Positioned(
                left: 10.w,
                top: 20.h,
                child: Image.network(competition.image, height: 65.h, width: 65.w,),
              ),
              Positioned(
                left: 80.w,
                top: 25.h,
                child: Container(width: 80.w, child: Text(competition.name.toUpperCase(), maxLines: 2, style: TextStyle(fontWeight: FontWeight.bold, fontSize: ScreenUtil().setSp(12)),)),
              ),
              Positioned(
                left: 80.w,
                top: 60.h,
                child: Text(Functions.parseDate(competition.eventdate, true), style: TextStyle(fontWeight: FontWeight.bold, fontSize: ScreenUtil().setSp(8), color: const Color(0xff61b3d8)),),
              ),
              Positioned(
                left: 80.w,
                top: 70.h,
                child: Text(Functions.parseTime(competition.eventdate), style: TextStyle(fontWeight: FontWeight.bold, fontSize: ScreenUtil().setSp(8), color: const Color(0xff61b3d8)),),
              ),
              Positioned(
                left: 10.w,
                top: 95.h,
                child: Text("${competition.modality} - ${competition.locality}", style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(10), color: Colors.black),),
              ),
              Positioned(
                left: 150.w,
                bottom: 138.h,
                child: IconButton(
                  icon: user.favorites.contains(competition) ? Icon(Icons.star, size: ScreenUtil().setSp(21), color: Colors.yellow,) :
                  Icon(Icons.star_border, size: ScreenUtil().setSp(21), color: Colors.grey[350],),
                ),
              ),
              Positioned(
                left: 60.w,
                top: 125.h,
                child: Text("PRECIO:", style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(9), color: Colors.black),),
              ),
              Positioned(
                left: 96.w,
                top: 121.h,
                child: Text("${competition.price}€", style: TextStyle(fontWeight: FontWeight.bold, fontSize: ScreenUtil().setSp(13), color: Colors.black),),
              ),
              Positioned(
                left: 30.w,
                top: 140.h,
                child: Container(width: 130.w, child: Text(competition.rewards, maxLines: 2, style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(9), color: Colors.black),)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
