import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:homeraces/model/competition.dart';
import 'package:homeraces/model/user.dart';
import 'package:homeraces/services/dbservice.dart';
import 'package:homeraces/shared/common_data.dart';
import 'package:homeraces/shared/decos.dart';
import 'package:homeraces/shared/functions.dart';
import 'package:provider/provider.dart';

class CompetitionProfile extends StatefulWidget {
  @override
  _CompetitionProfileState createState() => _CompetitionProfileState();
}

class _CompetitionProfileState extends State<CompetitionProfile> {
  final DBService _dbService = DBService();
  Competition competition;
  User user;
  @override
  Widget build(BuildContext context) {
    var args = List<Object>.of(ModalRoute.of(context).settings.arguments);
    competition = args.first;
    user = args.last;
    ScreenUtil.init(context, height: CommonData.screenHeight, width: CommonData.screenWidth, allowFontScaling: true);
    return Scaffold(backgroundColor: Colors.white, appBar:
      AppBar(
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
                  _dbService.deleteFromFavorites(user.id, competition.id);
                }
                else{
                  user.favorites.add(competition);
                  _dbService.addToFavorites(user.id, competition.id);
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

      body: ListView(children: <Widget>[
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
              top: 50.h,
              child: Row(children: <Widget>[
                  Icon(Icons.calendar_today, size: ScreenUtil().setSp(18),),
                  SizedBox(width: 7.w,),
                  Text(Functions.parseDate(competition.eventdate, true), style: TextStyle(fontWeight: FontWeight.bold, fontSize: ScreenUtil().setSp(15), color: const Color(0xff61b3d8)),),
              ],),
            ),
            Positioned(
              left: 155.w,
              top: 85.h,
              child: Row(children: <Widget>[
                  Icon(Icons.access_time, size: ScreenUtil().setSp(20),),
                  SizedBox(width: 7.w,),
                  Text(Functions.parseTime(competition.eventdate), style: TextStyle(fontWeight: FontWeight.bold, fontSize: ScreenUtil().setSp(15), color: const Color(0xff61b3d8)),),
              ],),
            ),
            Positioned(
                left: 155.w,
                top: 120.h,
                child: Text("Fecha máxima de inscripción: ${Functions.parseDate(competition.maxdate, false)} ${Functions.parseTime(competition.maxdate)}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: ScreenUtil().setSp(10), color: Colors.grey),)
            )
          ],),
        ),
        SizedBox(height: 15.h,),
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Column(children: <Widget>[
            Row(children: <Widget>[
              Icon(Icons.location_on, size: ScreenUtil().setSp(20),),
              SizedBox(width: 20.w,),
              Text("${competition.modality}  -  ${competition.locality}", style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(18), color: Colors.black),),
            ],)
          ],),
        ),
        SizedBox(height: 20.h,),
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Column(children: <Widget>[
            Row(children: <Widget>[
              Icon(Icons.lock, size: ScreenUtil().setSp(20),),
              SizedBox(width: 20.w,),
              Text("Competición:  ", style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(12), color: Colors.black),),
              Text(competition.type == "Public"? "Pública": "Privada", style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(16), color: Colors.black),),
            ],)
          ],),
        ),
        SizedBox(height: 20.h,),
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Column(children: <Widget>[
            Row(children: <Widget>[
              Icon(Icons.person, size: ScreenUtil().setSp(20),),
              SizedBox(width: 20.w,),
              Text("Organizado por:  ", style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(12), color: Colors.black),),
              Text(competition.organizer ?? "", style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(16), color: Colors.black),),
            ],)
          ],),
        ),
        SizedBox(height: 40.h,),
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Column(children: <Widget>[
            Row(children: <Widget>[
              Icon(Icons.people, size: ScreenUtil().setSp(20),),
              SizedBox(width: 20.w,),
              Text("Aforo:  ", style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(12), color: Colors.black),),
              Text(competition.capacity == -1? "Sin límite" : competition.capacity.toString(), style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(16), color: Colors.black),),
            ],)
          ],),
        ),
        SizedBox(height: 10.h,),
        Padding(
          padding: const EdgeInsets.only(left: 60),
          child: Column(children: <Widget>[
            Row(children: <Widget>[
              Text("Inscritos:  ", style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(12), color: Colors.black),),
              Text(competition.numcompetitors == 1? "${competition.numcompetitors} participante" :
              "${competition.numcompetitors} participantes", style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(16), color: const Color(0xff61b3d8)),),
            ],)
          ],),
        ),
        SizedBox(height: 10.h,),
        Padding(
          padding: const EdgeInsets.only(left: 60),
          child: Column(children: <Widget>[
            Row(children: <Widget>[
              Container(
                  height: 35.h,
                  width: 35.w,
                  decoration: new BoxDecoration(
                      shape: BoxShape.circle,
                      image: new DecorationImage(
                          fit: BoxFit.fill,
                          image: new NetworkImage(user.image)
                      )
                  )
              ),
              SizedBox(width: 6.w,),
            ],),
          ],),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 18.0, left: 18.0, top: 6, bottom: 6),
          child: Divider(thickness: 1,),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Column(children: <Widget>[
            Row(children: <Widget>[
              Icon(Icons.monetization_on, size: ScreenUtil().setSp(20),),
              SizedBox(width: 20.w,),
              Text("Premios:  ", style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(12), color: Colors.black),),
            ],)
          ],),
        ),
        SizedBox(height: 10.h,),
        Padding(
          padding: const EdgeInsets.only(left: 60),
          child: Column(children: <Widget>[
            Row(children: <Widget>[
              Text(competition.rewards, style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(16), color: Colors.black),),
            ],)
          ],),
        ),
        SizedBox(height: 10.h,),
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Column(children: <Widget>[
            Row(children: <Widget>[
              Icon(Icons.rate_review, size: ScreenUtil().setSp(20),),
              SizedBox(width: 20.w,),
              Text("Observaciones:  ", style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(12), color: Colors.black),),
            ],)
          ],),
        ),
        SizedBox(height: 10.h,),
        Padding(
          padding: const EdgeInsets.only(left: 60),
          child: Column(children: <Widget>[
            Row(children: <Widget>[
              Text(competition.observations, style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(16), color: Colors.black),),
            ],)
          ],),
        ),
        SizedBox(height: 15.h,),
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text("Comentarios: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: ScreenUtil().setSp(16), color: Colors.black),),
        ),
        SizedBox(height: 10.h,),
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Row(children: <Widget>[
            Container(
                height: 35.h,
                width: 35.w,
                decoration: new BoxDecoration(
                    shape: BoxShape.circle,
                    image: new DecorationImage(
                        fit: BoxFit.fill,
                        image: new NetworkImage(user.image)
                    )
                )
            ),
            SizedBox(width: 20.w,),
            Flexible(
              child: Container(
                width: 285.w,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Añadir comentario público",
                    fillColor: Colors.grey[100],
                    filled: true,
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey[200], width: 1)
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: const Color(0xff61b3d8), width: 2)
                    ),
                  ),
                  onChanged: (comment){},
                ),
              ),
            )
          ],),
        ),
      ],),

      bottomNavigationBar: BottomAppBar(
        child: RawMaterialButton(
            child: Text(user.enrolled.contains(competition)? "Entrar":"Inscribirse   (${competition.price}€)", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white, fontSize: ScreenUtil().setSp(20),),),
            fillColor: Color(0xff61b3d8),
            shape: RoundedRectangleBorder(),
            padding: EdgeInsets.all(18.0),
            onPressed: ()async{},
      ),
    ));
  }
}
