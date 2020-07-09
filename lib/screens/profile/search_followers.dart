import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:homeraces/model/follower.dart';
import 'package:homeraces/model/user.dart';
import 'package:homeraces/services/dbservice.dart';
import 'package:homeraces/shared/alert.dart';
import 'package:homeraces/shared/common_data.dart';

class SearchFollowers extends StatefulWidget {
  @override
  _SearchFollowersState createState() => _SearchFollowersState();
}

class _SearchFollowersState extends State<SearchFollowers> {
  final TextEditingController _searchQuery = new TextEditingController();
  User user;
  List<Follower> list, results;
  Timer timer;
  String searchText = "";
  String error = "";
  bool isSearching;

  _SearchFollowersState() {
    _searchQuery.addListener(() {
      if (_searchQuery.text.isEmpty) {
        setState(() {
          isSearching = false;
          searchText = "";
          if(timer != null){
            timer.cancel();
            timer = null;
          }
          results.clear();
        });
      }
      else {
        if(timer != null){
          timer.cancel();
          timer = null;
        }
        timer = Timer(Duration(milliseconds: 800),
                (){
              setState(() {
                isSearching = true;
                searchText = _searchQuery.text;
                results = null;
                _search(searchText);
              });
            }
        );
      }
    });
  }

  Future _search(String query) async{
    results = list.where((follower) {
      return (follower.username.toUpperCase().contains(query.toUpperCase())
        || follower.firstname.toUpperCase().contains(query.toUpperCase())
          || follower.lastname.toUpperCase().contains(query.toUpperCase())
      );
    }).toList();
    setState(() {
      if(results.length == 0)
        error = "No hay resultados";
      else
        error = "";
    });
  }

  @override
  void initState() {
    isSearching = false;
    results = List<Follower>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, height: CommonData.screenHeight, width: CommonData.screenWidth, allowFontScaling: true);
    List<Object> args = ModalRoute.of(context).settings.arguments;
    user = args.first;
    if(args.last == 1) {
      list = user.followers;
    }
    else {
      list = user.following;
    }
    return Scaffold(
      backgroundColor: Colors.white,
        appBar: AppBar(
            title: Text(args.last == 1 ? "SEGUIDORES" : "SIGUIENDO", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: ScreenUtil().setSp(23),),),
            centerTitle: true,
            elevation: 1,
            backgroundColor: Colors.white,
            leading: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: Colors.black,),
                onPressed: (){
                  Navigator.pop(context);
                }
            )
        ),
      body: ListView(
        children: <Widget>[
          SizedBox(height: 20.h,),
          Row(mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
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
                      hintText: "Buscar",
                      hintStyle: new TextStyle(color: Colors.black45)
                  ),
                ),
                decoration: BoxDecoration(
                    color: Colors.grey[100],
                    border: Border.all(color: Colors.black45),
                    borderRadius: new BorderRadius.only(
                      topLeft: const Radius.circular(10.0),
                      topRight: const Radius.circular(10.0),
                      bottomLeft: const Radius.circular(10.0),
                      bottomRight: const Radius.circular(10.0),
                    )
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h,),
          Container(
            height: 600.h,
            child: ListView(
              children: isSearching? results.map((f) =>
                  Container(
                    padding: EdgeInsets.all(10),
                    child: ListTile(
                      leading: Container(
                          height: 45.h,
                          width: 50.w,
                          decoration: new BoxDecoration(
                              shape: BoxShape.circle,
                              image: new DecorationImage(
                                  fit: BoxFit.fill,
                                  image: new NetworkImage(f.image ?? CommonData.defaultProfile)
                              )
                          )
                      ),
                      title: Text("${f.firstname} ${f.lastname}", style: TextStyle(fontWeight: FontWeight.normal, color: Colors.black, fontSize: ScreenUtil().setSp(18),),),
                      trailing: GestureDetector(child: Text("Eliminar", style: TextStyle(fontWeight: FontWeight.normal, color: Colors.lightBlueAccent, fontSize: ScreenUtil().setSp(16),),),
                        onTap: ()async{
                          await showDialog(
                              context: context,
                              builder: (_) => DeleteDialog(follower: f, type: args.last,)
                          ).then((value) => this.setState(() { }));
                        },
                      ),
                    ),
                  )
              ).toList()
                  : list.map((f) =>
                  Container(
                    padding: EdgeInsets.all(10),
                    child: ListTile(
                      leading: Container(
                          height: 45.h,
                          width: 50.w,
                          decoration: new BoxDecoration(
                              shape: BoxShape.circle,
                              image: new DecorationImage(
                                  fit: BoxFit.fill,
                                  image: new NetworkImage(f.image ?? CommonData.defaultProfile)
                              )
                          )
                      ),
                      title: Text("${f.firstname} ${f.lastname}", style: TextStyle(fontWeight: FontWeight.normal, color: Colors.black, fontSize: ScreenUtil().setSp(18),),),
                      trailing: GestureDetector(child: Text("Eliminar", style: TextStyle(fontWeight: FontWeight.normal, color: Colors.lightBlueAccent, fontSize: ScreenUtil().setSp(16),),),
                        onTap: ()async{
                          await showDialog(
                              context: context,
                              builder: (_) => DeleteDialog(follower: f, type: args.last,)
                          ).then((value) => this.setState(() { }));
                        },
                      ),
                    ),
                  )
              ).toList(),
            ),
          )
        ],
      ),
    );
  }
}

class DeleteDialog extends StatelessWidget {
  DeleteDialog({this.follower, this.type});
  Follower follower;
  int type;
  String t;
  @override
  Widget build(BuildContext context) {
    if(type == 1)
      t = "seguidores";
    else
      t = "seguidos";
    return Dialog(
      backgroundColor: Colors.black87,
      child: Container(
        width: 400.w,
        height: 180.h,
        decoration: BoxDecoration(
            color: Colors.black87,
            border: Border.all(color: Colors.black87),
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
              left: 260.w,
              bottom: 140.h,
              child: IconButton(
                icon: Icon(Icons.cancel, color: Colors.red, size: ScreenUtil().setSp(40),),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Positioned(
              left: 55.w,
              top: 35.h,
              child: Container(width: 230.w,child: Text("¿Deseas eliminar a ${follower.firstname} ${follower.lastname} de tus $t?", maxLines: 2, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: ScreenUtil().setSp(18),)))
            ),
            Positioned(
                left: 58.w,
                bottom: 20.h,
                child: RawMaterialButton(
                  child: Text("Eliminar", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white, fontSize: ScreenUtil().setSp(20,allowFontScalingSelf: true),),),
                  fillColor: Color(0xff61b3d8),
                  shape: RoundedRectangleBorder(),
                  padding: EdgeInsets.only(right: 60.0.w, bottom: 12.0.h,top: 12.0.h,left: 60.w),
                  onPressed: (){
                    if(type == 1) {
                      DBService.userF.followers.remove(follower);
                      DBService.dbService.deleteFollower(follower.userid, DBService.userF.id);
                    }
                    else {
                      DBService.userF.following.remove(follower);
                      DBService.dbService.deleteFollower(DBService.userF.id,follower.userid);
                    }
                    Alerts.toast("Eliminado!");
                    Navigator.pop(context);
                  },
                ),
            ),
          ],
        ),
      ),
    );
  }
}
