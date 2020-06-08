import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:homeraces/model/user.dart';
import 'package:homeraces/services/auth.dart';
import 'package:homeraces/services/dbservice.dart';



class SignUpExtra extends StatefulWidget {
  @override
  _SignUpExtraState createState() => _SignUpExtraState();
}

class _SignUpExtraState extends State<SignUpExtra> {
  User user;
  DateTime _dateTime;
  final AuthService _authService = AuthService();
  List<bool> _selections = List.generate(2, (index) => false);
  @override
  Widget build(BuildContext context) {
    user = ModalRoute.of(context).settings.arguments;
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    ScreenUtil.init(context, height: h, width: w, allowFontScaling: true);
    return Scaffold(
      body: ListView(
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 50.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'HOME',
                  style: TextStyle(
                    fontFamily: 'Impact',
                    fontSize: ScreenUtil().setSp(40),
                    color: const Color(0xff000000),
                  ),
                  textAlign: TextAlign.left,
                ),
                Text(
                  'RACES',
                  style: TextStyle(
                    fontFamily: 'Ebrima',
                    fontSize: ScreenUtil().setSp(40),
                    color: const Color(0xff61b3d8),
                  ),
                  textAlign: TextAlign.left,
                ),
                Text(
                  'EL NUEVO ESTILO DE COMPETICIÓN',
                  style: TextStyle(
                    fontFamily: 'Consolas',
                    fontSize: ScreenUtil().setSp(11),
                    color: const Color(0xff000000),
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: 45.h,),
                Padding(
                  padding: const EdgeInsets.only(right: 116),
                  child: Text("¿Cuando naciste?", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black, fontSize: ScreenUtil().setSp(22)),),
                ),
                SizedBox(height: 30.h,),
                /*Row(children: <Widget>[
                  Flexible(
                    child: CupertinoPicker(children: <Widget>[Text("1"),Text("2"),Text("3"),Text("4")], itemExtent: 25, magnification: 1.5, looping: true, onSelectedItemChanged: (num){

                    },),
                  ),
                  Flexible(
                    child: CupertinoPicker(children: <Widget>[Text("1"),Text("2"),Text("3"),Text("4")], itemExtent: 25, magnification: 1.5, looping: true, onSelectedItemChanged: (num){

                    },),
                  ),
                  Flexible(
                    child: CupertinoPicker(children: <Widget>[Text("1"),Text("2"),Text("3"),Text("4")], itemExtent: 25, magnification: 1.5, looping: true, onSelectedItemChanged: (num){

                    },),
                  ),
                ],),*/
                SizedBox(
                  height: 100.h,
                    width: 500.w,
                    child: CupertinoDatePicker(
                      initialDateTime: DateTime(1995, 1, 1),
                      onDateTimeChanged: (DateTime newdate) {
                        user.birthdate = newdate;
                      },
                      use24hFormat: true,
                      maximumDate: new DateTime(2020, 12, 30),
                      minimumYear: 1940,
                      maximumYear: 2020,
                      mode: CupertinoDatePickerMode.date,

                    )),
                SizedBox(height: 45.h,),
                Padding(
                  padding: const EdgeInsets.only(right: 116),
                  child: Text("¿Cuál es tu sexo?", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black, fontSize: ScreenUtil().setSp(22)),),
                ),
                SizedBox(height: 30.h,),
                ToggleButtons(
                  focusColor: Colors.blue,
                  selectedColor: Colors.blue,
                  selectedBorderColor: Colors.blue,
                  constraints: BoxConstraints.tight(Size(140.w,140.h)),
                  isSelected: _selections,
                  onPressed: (int index){
                    setState(() {
                      if(index == 0){
                        _selections[0] = !_selections[0];
                        if(_selections[1])
                        _selections[1] = !_selections[1];
                      }
                      else{
                        _selections[1] = !_selections[1];
                        if(_selections[0])
                          _selections[0] = !_selections[0];
                      }
                      if(_selections[0] && !_selections[1])
                        user.sex = "M";
                      else if(_selections[1] && !_selections[0])
                        user.sex = "W";
                      else
                        user.sex = null;
                    });
                  },
                  children: <Widget>[
                  Image.asset("assets/auth/hombre.PNG",width: 140.w, height: 140.h,),
                  Image.asset("assets/auth/mujer.PNG",width: 140.w, height: 140.h),
                ],),

              ],
            ),
          ),
          SizedBox(height: 50.h),
          Divider(thickness: 1,),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              SizedBox(width: 20.w,),
              FlatButton(
                  child: Text("Omitir", style: TextStyle(fontWeight: FontWeight.normal,color: Colors.grey, fontSize: ScreenUtil().setSp(17),),),
                  color: Colors.white12,
                  padding: EdgeInsets.all(18.0),
                  onPressed: ()async{
                    user.sex = null;
                    user.birthdate = null;
                    user.service = "E";
                    DBService().getUserdata("a1aa");
                  }
              ),
              SizedBox(width: 85.w,),
              RawMaterialButton(
                  child: Text("SIGUIENTE", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white, fontSize: ScreenUtil().setSp(20),),),
                  fillColor: Color(0xff61b3d8),
                  shape: RoundedRectangleBorder(),
                  padding: EdgeInsets.all(18.0),
                  onPressed: ()async{
                    user.service = "E";
                    _authService.registerEP(user);
                  }
              ),
              SizedBox(width: 50.w,)
            ],
          ),
        ],
      ),
    );
  }

}
