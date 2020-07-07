import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:homeraces/model/user.dart';
import 'package:homeraces/services/auth.dart';
import 'package:homeraces/services/storage.dart';
import 'package:homeraces/shared/common_data.dart';
import 'package:homeraces/shared/decos.dart';
import 'package:provider/provider.dart';


class EditUser extends StatefulWidget {
  @override
  _EditUserState createState() => _EditUserState();
}

class _EditUserState extends State<EditUser> {
  final _formKey = GlobalKey<FormState>();

  User user;
  bool enabled, init;
  String username,image, firstname, lastname, locality, country, sex;
  int day, year, month, weight, height;
  @override
  void initState() {
    enabled = false;
    init = false;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    user = ModalRoute.of(context).settings.arguments;
    var textInputDeco = InputDecoration(
      fillColor: enabled ? Theme.of(context).scaffoldBackgroundColor : Colors.white,
      filled: true,
      contentPadding: new EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
      enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[200])
      ),
      focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.pink)
      ),
      disabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white)
      ),
    );
    if(!init){
      init = true;
      username = user.username;
      image = user.image;
      firstname = user.firstname;
      lastname = user.lastname;
      locality = user.locality;
      sex = user.sex;
      weight = user.weight;
      height = user.height;
      if(user.birthdate != null){
        day = user.birthdate.day;
        month = user.birthdate.month;
        year = user.birthdate.year;
      }
    }
    ScreenUtil.init(context, height: CommonData.screenHeight, width: CommonData.screenWidth, allowFontScaling: true);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          SizedBox(height: 60.h,),
          Row( mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                  height: 120.h,
                  width: 120.w,
                  decoration: new BoxDecoration(
                      shape: BoxShape.circle,
                      image: new DecorationImage(
                          fit: BoxFit.fill,
                          image: new NetworkImage(user.image)
                      )
                  )
              ),
              Column(
                children: <Widget>[
                  SizedBox(height: 80.h,),
                  IconButton(icon: FaIcon(FontAwesomeIcons.edit, size: ScreenUtil().setSp(26), color: Colors.black,), onPressed: ()async{
                      String image = await StorageService().uploadImage(context,"user");
                      if(image != null) {
                        image = image;
                      }
                  },),
                ],
              )
            ],
          ),
          SizedBox(height: 10.h,),
          Divider(thickness: 1,),
          Container(
            padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 30.w),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text("Nombre", style: TextStyle(fontWeight: FontWeight.normal,color: Colors.grey, fontSize: ScreenUtil().setSp(18)),),
                      SizedBox(width: 28.w,),
                      Flexible(
                        child: TextFormField(
                          onChanged: (value){
                            setState(() => firstname = value);
                          },
                          validator: (val) => val.isEmpty ? "Escribe un nombre": null,
                          maxLength: 30,

                          decoration: textInputDeco.copyWith(hintText: "Nombre"),
                          initialValue: user.firstname,
                          enabled: enabled,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: ScreenUtil().setSp(18), color: Colors.black),
                        ),
                      ),
                      SizedBox(width: 5.w,),
                      Flexible(
                        child: TextFormField(
                          onChanged: (value){
                            setState(() => lastname = value);
                          },
                          validator: (val) => val.isEmpty ? "Escribe un apellido": null,
                          maxLength: 30,
                          decoration: textInputDeco.copyWith(hintText: "Apellido"),
                          initialValue: user.lastname,
                          enabled: enabled,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: ScreenUtil().setSp(18), color: Colors.black),
                        ),
                      ),
                    ],
                  ),

                  Row(
                    children: <Widget>[
                      Text("Usuario", style: TextStyle(fontWeight: FontWeight.normal,color: Colors.grey, fontSize: ScreenUtil().setSp(18)),),
                      SizedBox(width: 31.w,),
                      Expanded(
                        child: TextFormField(
                          onChanged: (value){
                            setState(() => username = value);
                          },
                          validator: (val) => val.isEmpty ? "Escribe un nombre de usuario": null,
                          maxLength: 30,
                          decoration: textInputDeco.copyWith(hintText: "Nombre de usuario"),
                          initialValue: user.username,
                          enabled: enabled,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: ScreenUtil().setSp(18), color: Colors.black),
                        ),
                      ),
                    ],
                  ),

                  Row(
                    children: <Widget>[
                      Text("Localidad", style: TextStyle(fontWeight: FontWeight.normal,color: Colors.grey, fontSize: ScreenUtil().setSp(18)),),
                      SizedBox(width: 15.w,),
                      Expanded(
                        child: TextFormField(
                          onChanged: (value){
                            setState(() => locality = value);
                          },
                          validator: (val) => val.isEmpty ? "Escribe una localidad": null,
                          decoration: textInputDeco.copyWith(hintText: "Localidad"),
                          initialValue: user.locality,
                          enabled: enabled,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: ScreenUtil().setSp(18), color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h,),
                  Row(
                    children: <Widget>[
                      Text("País", style: TextStyle(fontWeight: FontWeight.normal,color: Colors.grey, fontSize: ScreenUtil().setSp(18)),),
                      SizedBox(width: 59.w,),
                      Expanded(
                        child: TextFormField(
                          onChanged: (value){
                            setState(() => country = value);
                          },
                          validator: (val) => val.isEmpty ? "Escribe un país": null,
                          decoration: textInputDeco.copyWith(hintText: "País"),
                          initialValue: user.country,
                          enabled: enabled,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: ScreenUtil().setSp(18), color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15.h,),
                  Row(
                    children: <Widget>[
                      Text("Género", style: TextStyle(fontWeight: FontWeight.normal,color: Colors.grey, fontSize: ScreenUtil().setSp(18)),),
                      SizedBox(width: 36.w,),
                      Container(
                        padding: EdgeInsets.only(top: 6.h, bottom: 6.h),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[200]),
                            color: Theme.of(context).scaffoldBackgroundColor,
                        ),
                        height: 45.h,
                        width: 72.w,
                        child: SvgPicture.asset(
                          "assets/profile/Masculino.svg",
                          allowDrawingOutsideViewBox: true,
                          color: Colors.blue,
                        ),
                      ),
                      SizedBox(width: 10.w,),
                      Container(
                        padding: EdgeInsets.only(top: 6.h, bottom: 6.h),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[200]),
                          color: Theme.of(context).scaffoldBackgroundColor,
                        ),
                        height: 45.h,
                        width: 72.w,
                        child: SvgPicture.asset(
                          "assets/profile/Femenino.svg",
                          allowDrawingOutsideViewBox: true,
                          color: Colors.pink,
                        ),
                      ),
                      SizedBox(width: 10.w,),
                      Container(
                        padding: EdgeInsets.only(top: 6.h, bottom: 6.h),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[200]),
                          color: Theme.of(context).scaffoldBackgroundColor,
                        ),
                        height: 45.h,
                        width: 72.w,
                        child: Row(
                          children: <Widget>[
                            Flexible(
                              child: SvgPicture.asset(
                                "assets/profile/Masculino.svg",
                                allowDrawingOutsideViewBox: true,
                                color: Colors.blue,
                              ),
                            ),
                            Flexible(
                              child: SvgPicture.asset(
                                "assets/profile/Femenino.svg",
                                allowDrawingOutsideViewBox: true,
                                color: Colors.pink,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15.h,),
                  Row(
                    children: <Widget>[
                      Text("Fecha de nacimiento", style: TextStyle(fontWeight: FontWeight.normal,color: Colors.grey, fontSize: ScreenUtil().setSp(18)),),
                    ],
                  ),
                  SizedBox(height: 10.h,),
                  Row(
                    children: <Widget>[
                      Flexible(
                        child: TextFormField(
                          onChanged: (value){
                            setState(() => day = int.parse(value));
                          },
                          validator: (val) => val.isEmpty ? "Escribe un día válido": null,
                          keyboardType: TextInputType.number,
                          decoration: textInputDeco.copyWith(hintText: "Día"),
                          initialValue: day == null? "" : day.toString(),
                          enabled: enabled,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: ScreenUtil().setSp(18), color: Colors.black),
                        ),
                      ),
                      SizedBox(width: 10.w,),
                      Flexible(
                        child: TextFormField(
                          onChanged: (value){
                            setState(() => month = int.parse(value));
                          },
                          validator: (val) => val.isEmpty ? "Escribe un mes válido": null,
                          decoration: textInputDeco.copyWith(hintText: "Mes"),
                          keyboardType: TextInputType.number,
                          initialValue: month == null? "" : month.toString(),
                          enabled: enabled,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: ScreenUtil().setSp(18), color: Colors.black),
                        ),
                      ),
                      SizedBox(width: 10.w,),
                      Flexible(
                        child: TextFormField(
                          onChanged: (value){
                            setState(() => year = int.parse(value));
                          },
                          validator: (val) => val.isEmpty ? "Escribe un año válido": null,
                          decoration: textInputDeco.copyWith(hintText: "Año"),
                          keyboardType: TextInputType.number,
                          initialValue: year == null? "" : year.toString(),
                          enabled: enabled,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: ScreenUtil().setSp(18), color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15.h,),
                  Row(
                    children: <Widget>[
                      Text("Peso", style: TextStyle(fontWeight: FontWeight.normal,color: Colors.grey, fontSize: ScreenUtil().setSp(18)),),
                      SizedBox(width: 15.w,),
                      Expanded(
                        child: TextFormField(
                          onChanged: (value){
                            setState(() => weight = int.parse(value));
                          },
                          validator: (val) => val.isEmpty ? "Pon tu peso": null,
                          decoration: textInputDeco.copyWith(hintText: "P"),
                          initialValue: user.weight == null? "" : user.weight.toString(),
                          enabled: enabled,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: ScreenUtil().setSp(18), color: Colors.black),
                        ),
                      ),
                      SizedBox(width: 10.w,),
                      Text("kg", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black, fontSize: ScreenUtil().setSp(18)),),
                      SizedBox(width: 35.w,),
                      Text("Altura", style: TextStyle(fontWeight: FontWeight.normal,color: Colors.grey, fontSize: ScreenUtil().setSp(18)),),
                      SizedBox(width: 15.w,),
                      Expanded(
                        child: TextFormField(
                          onChanged: (value){
                            setState(() => height = int.parse(value));
                          },
                          validator: (val) => val.isEmpty ? "Pon tu altura": null,
                          decoration: textInputDeco.copyWith(hintText: "A"),
                          initialValue: user.height == null? "" : user.height.toString(),
                          enabled: enabled,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: ScreenUtil().setSp(18), color: Colors.black),
                        ),
                      ),
                      SizedBox(width: 10.w,),
                      Text("cm", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black, fontSize: ScreenUtil().setSp(18)),),

                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
