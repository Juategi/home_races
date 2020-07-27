import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:homeraces/model/user.dart';
import 'package:homeraces/services/auth.dart';
import 'package:homeraces/services/dbservice.dart';
import 'package:homeraces/shared/common_data.dart';
import 'package:provider/provider.dart';

class UserProfile extends StatefulWidget {
  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final TextEditingController _searchQuery = new TextEditingController();
  User user;

  void _timerFollowers(){
    Future.delayed(Duration(seconds: 80)).then((_) async {
      if(user != null){
        user.followers = await DBService.dbService.getFollowers(user.id);
        user.following = await DBService.dbService.getFollowing(user.id);
        setState(() {
          print("Getting follows...");
        });
      }
      _timerFollowers();
    });
  }

  @override
  void initState() {
    //_timerFollowers();
    super.initState();
  }

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
                          image: new NetworkImage(user.image?? CommonData.defaultProfile)
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
                      Text("${user.kmTotal} km", style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(18), color: Colors.lightBlueAccent),),
                    ],
                  ),
                  SizedBox(height: 10.h,),
                  Row(
                    children: <Widget>[
                      Text("Km oficiales: ", style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(14), color: Colors.black),),
                      SizedBox(width: 10.w,),
                      Text("${user.kmOfficial} km", style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(18), color: Colors.lightBlueAccent),),
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
                            "assets/profile/${_getRank()}.svg",
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
              GestureDetector(child: Text("Seguidores  ${user.followers.length}", style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(18), color: Colors.grey),),
                onTap: () => Navigator.pushNamed(context, "/followers", arguments: [user,1]).then((value) => this.setState(() { }))
              ),
              Container(height: 30.h, child: VerticalDivider(thickness: 1, )),
              GestureDetector(child: Text("Siguiendo  ${user.following.length}", style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(18), color: Colors.grey),),
                onTap: () => Navigator.pushNamed(context, "/followers", arguments: [user,2]).then((value) => this.setState(() { }))
              ),
            ],
          ),
          SizedBox(height: 10.h,),
          Divider(thickness: 1,),
          SizedBox(height: 20.h,),
          /*Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Column(children: <Widget>[
                Container(
                  height: 60.h,
                  width: 60.w,
                  child: SvgPicture.asset(
                    "assets/profile/Estadisticas.svg",
                  ),
                ),
                SizedBox(height: 5.h,),
                Text("Premios", style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(15), color: Colors.black),),
              ],),
              //SizedBox(width: 60.w,),
              Column(children: <Widget>[

                SizedBox(height: 5.h,),
                Text("OBJETIVOS", style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(15), color: Colors.black),),
              ],),
              //SizedBox(width: 60.w,),
              Column(children: <Widget>[

                SizedBox(height: 5.h,),
                Text("ACTIVIDADES", style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(15), color: Colors.black),),
              ],)
            ],
          ),
          SizedBox(height: 40.h,),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Column(children: <Widget>[

                SizedBox(height: 5.h,),
                Text("EVENTOS ", style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(15), color: Colors.black),),
              ],),
              Column(children: <Widget>[

                SizedBox(height: 5.h,),
                Text("NOTIFICACIONES", style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(15), color: Colors.black),),
              ],),
              //SizedBox(width: 60.w,),
              Column(children: <Widget>[

                SizedBox(height: 5.h,),
                Text("CONFIGURACIÓN", style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(15), color: Colors.black),),
              ],)
            ],
          ),*/
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
          ),
          RawMaterialButton(
              child: Text("Mis competiciones", style: TextStyle(fontWeight: FontWeight.normal, color: Colors.grey, fontSize: ScreenUtil().setSp(13),),),
              fillColor: Colors.grey[100],
              shape: RoundedRectangleBorder(),
              elevation: 0,
              padding: EdgeInsets.only(right: 28.0.w, bottom: 12.h,top: 12.h, left: 28.w),
              onPressed: ()async{
                Navigator.pushNamed(context, "/owned", arguments: user);
              }
          ),
        ],
      ),
    );
  }

  String _getRank(){

    if(user.kmTotal >= 1000 && user.kmOfficial >= 504)
      return "Guepardo";

    if(user.kmTotal >= 500 && user.kmOfficial >= 210)
      return "Tigre";

    if(user.kmTotal >= 150 && user.kmOfficial >= 84)
      return "Zorro";

    if(user.kmTotal >= 50 && user.kmOfficial >= 21)
      return "Cebra";

    return "Conejo";
  }
}
