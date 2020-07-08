import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:homeraces/model/user.dart';
import 'package:homeraces/services/auth.dart';
import 'package:homeraces/services/dbservice.dart';
import 'package:homeraces/services/storage.dart';
import 'package:homeraces/shared/alert.dart';
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
  bool enabled, init, loading;
  String username,image, firstname, lastname, locality, country, sex, check;
  int day, year, month, weight, height;
  @override
  void initState() {
    enabled = false;
    loading = false;
    init = false;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    user = ModalRoute.of(context).settings.arguments;
    var textInputDeco = InputDecoration(
      fillColor: enabled ? Theme.of(context).scaffoldBackgroundColor : Colors.white,
      filled: true,
      counterText: "",
      contentPadding: new EdgeInsets.symmetric(vertical: 1.0.h, horizontal: 10.0.w),
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
      check = "None";
      username = user.username;
      image = user.image;
      firstname = user.firstname;
      lastname = user.lastname;
      locality = user.locality;
      weight = user.weight;
      height = user.height;
      if(user.sex == null)
        sex = "N";
      else
        sex = user.sex;
      if(user.birthdate != null){
        day = user.birthdate.day;
        month = user.birthdate.month;
        year = user.birthdate.year;
      }
    }
    ScreenUtil.init(context, height: CommonData.screenHeight, width: CommonData.screenWidth, allowFontScaling: true);
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        children: <Widget>[
          SizedBox(height: 2.h,),
          Row( mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              IconButton(
                  icon: Icon(Icons.arrow_back_ios, color: Colors.black,),
                  onPressed: (){
                    Navigator.pop(context);
                  }
              ),
              SizedBox(width: 100.w,),
              Container(
                  height: 100.h,
                  width: 100.w,
                  decoration: new BoxDecoration(
                      shape: BoxShape.circle,
                      image: new DecorationImage(
                          fit: BoxFit.fill,
                          image: new NetworkImage(image ?? CommonData.defaultProfile)
                      )
                  )
              ),
              Column(
                children: <Widget>[
                  SizedBox(height: 80.h,),
                  GestureDetector(
                    onTap: ()async{
                      if(enabled){
                        String imageG = await StorageService().uploadImage(context,"user");
                        if(imageG != null) {
                          setState(() {
                            image = imageG;
                          });
                        }
                      }
                    },
                    child: Row(mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        FaIcon(FontAwesomeIcons.edit, size: ScreenUtil().setSp(20), color: Colors.black,),
                        Text(!enabled? "" : "Cambiar", style: TextStyle(fontWeight: FontWeight.normal, color: Colors.blue, fontSize: ScreenUtil().setSp(14)),),
                      ],
                    ),
                  )
                ],
              )
            ],
          ),
          SizedBox(height: 5.h,),
          Divider(thickness: 1,),
          Container(
            padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 30.w),
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
                  SizedBox(height: 10.h,),
                  Row(
                    children: <Widget>[
                      Text("Usuario", style: TextStyle(fontWeight: FontWeight.normal,color: Colors.grey, fontSize: ScreenUtil().setSp(18)),),
                      SizedBox(width: 31.w,),
                      Expanded(
                        child: TextFormField(
                          onChanged: (value)async{
                            setState(() => username = value);
                            String result = await DBService().checkUsernameEmail(username, user.email);
                            if(result.contains("u") && username != user.username){
                              setState(() {
                                check = "Bad";
                              });
                            }
                            else{
                              setState(() {
                                check = "Ok";
                              });
                            }
                          },
                          validator: (val) => val.isEmpty ? "Escribe un nombre de usuario": null,
                          maxLength: 30,
                          decoration: textInputDeco.copyWith(hintText: "Nombre de usuario", suffixIcon:
                            check == "None" ? Icon(Icons.check, color: enabled ? Theme.of(context).scaffoldBackgroundColor : Colors.white,):
                            check == "Ok" ?
                            Icon(Icons.check, color:Colors.blueAccent):
                            Icon(Icons.clear, color: Colors.red,)
                          ),
                          initialValue: user.username,
                          enabled: enabled,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: ScreenUtil().setSp(18), color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h,),
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
                  SizedBox(height: 10.h,),
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
                  _initGenderRow(),
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
                            if(value == "")
                              day = 0;
                            else
                              day = int.parse(value);
                          },
                          validator: (val) => val.isEmpty || day > 31 || day < 1 ? "Día inválido": null,
                          keyboardType: TextInputType.number,
                          decoration: textInputDeco.copyWith(hintText: "Día"),
                          initialValue: day == null? "" : day.toString(),
                          maxLength: 2,
                          enabled: enabled,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: ScreenUtil().setSp(18), color: Colors.black),
                        ),
                      ),
                      SizedBox(width: 10.w,),
                      Flexible(
                        child: TextFormField(
                          onChanged: (value){
                            if(value == "")
                              month = 0;
                            else
                              month = int.parse(value);
                          },
                          validator: (val) => val.isEmpty || month > 12 || month < 1 ? "Mes inválido": null,
                          decoration: textInputDeco.copyWith(hintText: "Mes"),
                          keyboardType: TextInputType.number,
                          initialValue: month == null? "" : month.toString(),
                          maxLength: 2,
                          enabled: enabled,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: ScreenUtil().setSp(18), color: Colors.black),
                        ),
                      ),
                      SizedBox(width: 10.w,),
                      Flexible(
                        child: TextFormField(
                          onChanged: (value){
                            if(value == "")
                              year = 0;
                            else
                              year = int.parse(value);
                          },
                          validator: (val) => val.isEmpty || year > DateTime.now().year || year < 1900 ? "Año inválido": null,
                          decoration: textInputDeco.copyWith(hintText: "Año"),
                          keyboardType: TextInputType.number,
                          maxLength: 4,
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
                            if(value == "")
                              weight = 0;
                            else
                              weight = int.parse(value);
                          },
                          validator: (val) => val.isEmpty ? "Peso": null,
                          decoration: textInputDeco.copyWith(hintText: "P"),
                          keyboardType: TextInputType.number,
                          maxLength: 3,
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
                            if(value == "")
                              height = 0;
                            else
                              height = int.parse(value);
                          },
                          validator: (val) => val.isEmpty ? "Altura": null,
                          decoration: textInputDeco.copyWith(hintText: "A"),
                          keyboardType: TextInputType.number,
                          maxLength: 3,
                          initialValue: user.height == null? "" : user.height.toString(),
                          enabled: enabled,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: ScreenUtil().setSp(18), color: Colors.black),
                        ),
                      ),
                      SizedBox(width: 10.w,),
                      Text("cm", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black, fontSize: ScreenUtil().setSp(18)),),
                    ],
                  ),
                  SizedBox(height: 30.h,),
                  user.service == "E" ? GestureDetector(
                    child: Text("Cambiar contraseña", style: TextStyle(fontWeight: FontWeight.normal, color: Colors.blue, fontSize: ScreenUtil().setSp(14)),),
                    onTap: (){
                       Navigator.pushNamed(context, "/changepassword", arguments: user);
                    },
                  ) : Container(),
                  SizedBox(height: 30.h,),
                  enabled? loading? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),),
                    ],
                  ): RawMaterialButton(
                    child: Text("GUARDAR", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white, fontSize: ScreenUtil().setSp(24),),),
                    fillColor: Color(0xff61b3d8),
                    shape: StadiumBorder(),
                    elevation: 0,
                    padding: EdgeInsets.only(right: 80.0.w, bottom: 18.0.h, top: 18.0.h, left: 80.w),
                    onPressed: ()async{
                      FocusScope.of(context).unfocus();
                      if(_formKey.currentState.validate()){
                        setState(() {
                          loading = true;
                        });
                        String result = await DBService().checkUsernameEmail(username, user.email);
                        if(result.contains("u") && username != user.username){
                          setState(() {
                            check = "Bad";
                          });
                        }
                        else{
                          setState(() {
                            check = "Ok";
                          });
                          user.username = username;
                          user.firstname = firstname;
                          user.lastname = lastname;
                          user.image = image;
                          user.sex = sex;
                          user.country = country;
                          user.locality = locality;
                          user.weight = weight;
                          user.height = height;
                          user.birthdate = DateTime(year,month,day);
                          await DBService().updateUser(user);
                          Alerts.toast("Perfil actualizado!");
                        }
                        setState(() {
                          loading = false;
                          enabled = false;
                          check = "None";
                        });
                      }
                    },
                  )
                      :GestureDetector(
                          onTap: (){
                            setState(() {
                              enabled = true;
                            });
                          },
                        child: Row(mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            FaIcon(FontAwesomeIcons.edit, size: ScreenUtil().setSp(20), color: Colors.black,),
                            Text("Editar", style: TextStyle(fontWeight: FontWeight.normal, color: Colors.blue, fontSize: ScreenUtil().setSp(14)),),
                          ],
                        ),
                      ),
                  SizedBox(height: 10.h,),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }


  Widget _initGenderRow(){
    List<Widget> list = List<Widget>();
    list.add(Text("Género", style: TextStyle(fontWeight: FontWeight.normal,color: Colors.grey, fontSize: ScreenUtil().setSp(18)),));
    list.add(SizedBox(width: 36.w,),);
    if(!enabled){
      if(sex == "N"){
        list.add(
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
          )
        );
      }
      else if(sex == "M"){
        list.add(
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
        );
      }
      else if(sex == "W"){
        list.add(
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
              color: Colors.blue,
            ),
          ),
        );
      }
      else{
        list.add(Container());
      }
    }
    else{
      list.addAll([
        GestureDetector(
          onTap: (){
            setState(() {
              sex = "M";
            });
          },
          child: Container(
            padding: EdgeInsets.only(top: 6.h, bottom: 6.h),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[200]),
              color: sex == "M"? Colors.lightBlueAccent : Theme.of(context).scaffoldBackgroundColor,
            ),
            height: 45.h,
            width: 72.w,
            child: SvgPicture.asset(
              "assets/profile/Masculino.svg",
              allowDrawingOutsideViewBox: true,
              color: sex == "M"? Colors.white : Colors.lightBlueAccent,
            ),
          ),
        ),
        SizedBox(width: 5.w,),
        GestureDetector(
          onTap: (){
            setState(() {
              sex = "W";
            });
          },
          child: Container(
            padding: EdgeInsets.only(top: 6.h, bottom: 6.h),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[200]),
              color: sex == "W"? Colors.lightBlueAccent : Theme.of(context).scaffoldBackgroundColor,
            ),
            height: 45.h,
            width: 72.w,
            child: SvgPicture.asset(
              "assets/profile/Femenino.svg",
              allowDrawingOutsideViewBox: true,
              color: sex == "W"? Colors.white : Colors.pink,
            ),
          ),
        ),
        SizedBox(width: 5.w,),
        GestureDetector(
          onTap: (){
            setState(() {
              sex = "N";
            });
          },
          child: Container(
            padding: EdgeInsets.only(top: 6.h, bottom: 6.h),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[200]),
              color: sex == "N"? Colors.lightBlueAccent : Theme.of(context).scaffoldBackgroundColor,
            ),
            height: 45.h,
            width: 72.w,
            child: Row(
              children: <Widget>[
                Flexible(
                  child: SvgPicture.asset(
                    "assets/profile/Masculino.svg",
                    allowDrawingOutsideViewBox: true,
                    color: sex == "N"? Colors.white : Colors.lightBlueAccent,
                  ),
                ),
                Flexible(
                  child: SvgPicture.asset(
                    "assets/profile/Femenino.svg",
                    allowDrawingOutsideViewBox: true,
                    color: sex == "N"? Colors.white : Colors.pink,
                  ),
                ),
              ],
            ),
          ),
        )
      ]);
    }
    return Row(children: list,);
  }

}
