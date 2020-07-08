import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:homeraces/model/user.dart';
import 'package:homeraces/services/auth.dart';
import 'package:homeraces/shared/common_data.dart';
import 'package:provider/provider.dart';

class UserProfile extends StatefulWidget {
  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final TextEditingController _searchQuery = new TextEditingController();
  User user;
  @override
  Widget build(BuildContext context) {
    user = Provider.of<User>(context);
    ScreenUtil.init(context, height: CommonData.screenHeight, width: CommonData.screenWidth, allowFontScaling: true);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          SizedBox(height: 55.h,),
          Row(crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(width: 20.w,),
              Container(
                  height: 100.h,
                  width: 100.w,
                  decoration: new BoxDecoration(
                      shape: BoxShape.circle,
                      image: new DecorationImage(
                          fit: BoxFit.fill,
                          image: new NetworkImage(user.image)
                      )
                  )
              ),
              SizedBox(width: 30.w,),
              Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("${user.firstname} ${user.lastname}".length > 17? "${user.firstname} ${user.lastname}".substring(0,17).toUpperCase() :"${user.firstname} ${user.lastname}".toUpperCase(), style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(18), color: Colors.black),),
                  SizedBox(height: 5.h,),
                  Text("@${user.username}", style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(14), color: Colors.black),),
                  SizedBox(height: 10.h,),
                  Row(
                    children: <Widget>[
                      Text("Km totales: ", style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(14), color: Colors.black),),
                      SizedBox(width: 20.w,),
                      Text("${user.kmTotal} km", style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(18), color: Colors.blueAccent),),
                    ],
                  ),
                  SizedBox(height: 10.h,),
                  Row(
                    children: <Widget>[
                      Text("Km oficiales: ", style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(14), color: Colors.black),),
                      SizedBox(width: 10.w,),
                      Text("${user.kmOfficial} km", style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(18), color: Colors.blueAccent),),
                    ],
                  ),
                  SizedBox(height: 15.h,),
                  Row(
                    children: <Widget>[
                      Text("Rango: ", style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(14), color: Colors.black),),
                      SizedBox(width: 5.w,),
                      GestureDetector(
                        onTap: (){
                          Navigator.pushNamed(context, "/ranks");
                        },
                        child: Container(
                          height: 25.h,
                          width: 25.w,
                          child: SvgPicture.asset(
                            "assets/profile/Guepardo.svg",
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(width: 25.w,),
              IconButton(icon: FaIcon(FontAwesomeIcons.edit, size: ScreenUtil().setSp(26), color: Colors.black,), onPressed: (){
                Navigator.pushNamed(context, "/edituser", arguments: user);
              },)
            ],
          ),
          SizedBox(height: 10.h,),
          Divider(thickness: 1,),
          SizedBox(height: 10.h,),
          Row( mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text("Seguidores ", style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(18), color: Colors.grey),),
              Container(height: 30.h, child: VerticalDivider(thickness: 1, )),
              Text("Siguiendo ", style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(18), color: Colors.grey),),
            ],
          ),
          SizedBox(height: 10.h,),
          Divider(thickness: 1,),
          SizedBox(height: 10.h,),
          Container(
            padding: EdgeInsets.only(left: 8.w, right: 8.w),
            margin: EdgeInsets.only(left: 30.w, right: 30.w),
            width: 300.w,
            height: 50.h,
            child: TextField(
              controller: _searchQuery,
              autofocus: false,
              style: new TextStyle(
                color: Colors.white,
              ),
              decoration: new InputDecoration(
                  prefixIcon: new Icon(Icons.search,color: Colors.grey),
                  hintText: "Buscar personas",
                  hintStyle: new TextStyle(color: Colors.black45)
              ),
            ),
            decoration: BoxDecoration(
                color: Colors.grey[300],
                border: Border.all(color: Colors.black45),
                borderRadius: new BorderRadius.only(
                  topLeft: const Radius.circular(10.0),
                  topRight: const Radius.circular(10.0),
                  bottomLeft: const Radius.circular(10.0),
                  bottomRight: const Radius.circular(10.0),
                )
            ),
          ),
          SizedBox(height: 40.h,),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Column(children: <Widget>[
                Image.asset("assets/profile/trophy.PNG", width: 70.w, height: 70.h,),
                SizedBox(height: 5.h,),
                Text("PREMIOS", style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(15), color: Colors.black),),
              ],),
              //SizedBox(width: 60.w,),
              Column(children: <Widget>[
                Image.asset("assets/profile/objectives.PNG", width: 70.w, height: 70.h,),
                SizedBox(height: 5.h,),
                Text("OBJETIVOS", style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(15), color: Colors.black),),
              ],),
              //SizedBox(width: 60.w,),
              Column(children: <Widget>[
                Image.asset("assets/profile/activities.PNG", width: 70.w, height: 70.h,),
                SizedBox(height: 5.h,),
                Text("ACTIVIDADES", style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(15), color: Colors.black),),
              ],)
            ],
          ),
          SizedBox(height: 40.h,),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Column(children: <Widget>[
                Image.asset("assets/profile/events.PNG", width: 70.w, height: 70.h,),
                SizedBox(height: 5.h,),
                Text("    EVENTOS    ", style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(15), color: Colors.black),),
              ],),
              Column(children: <Widget>[
                Image.asset("assets/profile/notifications.PNG", width: 70.w, height: 70.h,),
                SizedBox(height: 5.h,),
                Text("NOTIFICACIONES", style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(15), color: Colors.black),),
              ],),
              //SizedBox(width: 60.w,),
              Column(children: <Widget>[
                Image.asset("assets/profile/config.PNG", width: 70.w, height: 70.h,),
                SizedBox(height: 5.h,),
                Text("CONFIGURACIÓN", style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(15), color: Colors.black),),
              ],)
            ],
          ),
          SizedBox(height: 20.h,),
          Divider(thickness: 1,),
          SizedBox(height: 10.h,),
          RawMaterialButton(
            child: Text("CERRAR SESIÓN", style: TextStyle(fontWeight: FontWeight.normal, color: Colors.grey, fontSize: ScreenUtil().setSp(13),),),
            fillColor: Colors.grey[100],
            shape: RoundedRectangleBorder(),
            elevation: 0,
            padding: EdgeInsets.only(right: 28.0.w, bottom: 12.h,top: 12.h, left: 28.w),
            onPressed: ()async{
              await AuthService().signOut();
            }
      )
        ],
      ),
    );
  }
}
