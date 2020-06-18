import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:homeraces/model/competition.dart';
import 'package:homeraces/model/user.dart';
import 'package:homeraces/services/dbservice.dart';
import 'package:homeraces/services/storage.dart';
import 'package:homeraces/shared/common_data.dart';
import 'package:homeraces/shared/decos.dart';
import 'package:homeraces/shared/functions.dart';


class CreateCompetition extends StatefulWidget {
  @override
  _CreateCompetitionState createState() => _CreateCompetitionState();
}

class _CreateCompetitionState extends State<CreateCompetition> {
  final DBService _dbService = DBService();
  final StorageService _storageService = StorageService();
  final _formKey = GlobalKey<FormState>();
  Competition competition;
  User user;
  String image = CommonData.defaultCompetition;
  @override
  Widget build(BuildContext context) {
    String image = CommonData.defaultCompetition;
    user = ModalRoute.of(context).settings.arguments;
    ScreenUtil.init(context, height: CommonData.screenHeight, width: CommonData.screenWidth, allowFontScaling: true);
    return Scaffold(
      body: ListView(children: <Widget>[
        Container(
          child: Form(
            key: _formKey,
            child: Column(children: <Widget>[
              SizedBox(height: 20.h,),
              Container(
                  child: FlatButton(
                      onPressed: () async{
                        String aux = await _storageService.uploadImage(context, "competition");
                        if(aux != null){
                          setState(() {
                            image = aux;
                          });
                        }
                      },
                      padding: EdgeInsets.all(0.0),
                      child: Container(
                          constraints: BoxConstraints.expand(
                            height: 130.0.h,
                            width: 130.0.w
                          ),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: Image.network(image).image,
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Stack(
                            children: <Widget>[
                              Positioned(
                                right: 40.w,
                                bottom: 5.0,
                                child: Icon(Icons.collections, size: ScreenUtil().setSp(45), color: Colors.grey[350],),
                              ),
                            ],
                          )
                      )
                  )
              ),
            ],),
          ),
        )
      ],),
    );
  }
}
