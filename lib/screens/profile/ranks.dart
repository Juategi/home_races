import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:homeraces/shared/common_data.dart';

class Ranks extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, height: CommonData.screenHeight, width: CommonData.screenWidth, allowFontScaling: true);
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text("RANGOS", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: ScreenUtil().setSp(25),),),
          centerTitle: true,
          elevation: 1,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.black,),
              onPressed: (){
                Navigator.pop(context);
              }
          ),
        ),
        body: Container(
          padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 10.w),
          child: Column(
            children: <Widget>[
              RankTile(image: "Conejo.svg", kmOfficial: 0, kmTotal: 0, name: "Liebre",),
              SizedBox(height: 12.h,),
              RankTile(image: "Cebra.svg", kmOfficial: 21, kmTotal: 50, name: "Cebra",),
              SizedBox(height: 12.h,),
              RankTile(image: "Zorro.svg", kmOfficial: 84, kmTotal: 150, name: "Zorro",),
              SizedBox(height: 12.h,),
              RankTile(image: "Tigre.svg", kmOfficial: 210, kmTotal: 500, name: "Tigre",),
              SizedBox(height: 12.h,),
              RankTile(image: "Guepardo.svg", kmOfficial: 504, kmTotal: 1000, name: "Guepardo",),
            ],
          ),
        )
    );
  }
  
}

class RankTile extends StatelessWidget {
  String image,name;
  int kmOfficial, kmTotal;
  RankTile({this.kmOfficial,this.kmTotal,this.image, this.name});
  @override
  Widget build(BuildContext context) {
    return Container(
      //color: Theme.of(context).scaffoldBackgroundColor,
      height: 120.h,
      width: 400.w,
      decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border.all(color: Colors.grey[300]),
          borderRadius: new BorderRadius.only(
            topLeft: const Radius.circular(20.0),
            topRight: const Radius.circular(20.0),
            bottomLeft: const Radius.circular(20.0),
            bottomRight: const Radius.circular(20.0),
          )
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 28.h,
            left: 12.w,
            child: Container(
              height: 60.h,
              width: 60.w,
              child: SvgPicture.asset(
                "assets/profile/$image",
              ),
            ),
          ),
          Positioned(
            top: 20.h,
            left: 85.w,
            child: Text(name, style: TextStyle(fontWeight: FontWeight.normal, color: Colors.black, fontSize: ScreenUtil().setSp(17),),),
          ),
          Positioned(
            top: 50.h,
            left: 85.w,
            child: Text("Kilómetros acumulados últimos 12 meses:", style: TextStyle(fontWeight: FontWeight.normal, color: Colors.black, fontSize: ScreenUtil().setSp(10),),),
          ),
          Positioned(
            top: 75.h,
            left: 85.w,
            child: Text("Kilómetros oficiales últimos 12 meses:", style: TextStyle(fontWeight: FontWeight.normal, color: Colors.black, fontSize: ScreenUtil().setSp(10),),),
          ),
          Positioned(
            top: 45.h,
            left: name == "Zorro" || name == "Guepardo"? 292.w : 300.w,
            child: Text("${kmTotal.toString()} km", style: TextStyle(fontWeight: FontWeight.normal, color: Colors.lightBlueAccent, fontSize: ScreenUtil().setSp(16),),),
          ),
          Positioned(
            top: 70.h,
            left: 300.w,
            child: Text("${kmOfficial.toString()} km", style: TextStyle(fontWeight: FontWeight.normal, color: Colors.lightBlueAccent, fontSize: ScreenUtil().setSp(16),),),
          ),
        ],
      ),
    );
  }
}


