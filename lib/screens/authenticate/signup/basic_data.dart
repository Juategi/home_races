import 'package:flutter/material.dart';
import 'package:homeraces/model/user.dart';
import 'package:homeraces/services/auth.dart';
import 'package:homeraces/services/dbservice.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:homeraces/shared/decos.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {

  final _formKey = GlobalKey<FormState>();
  User user;
  String errorUser = " ";
  String errorEmail = " ";
  bool passwordVisible, indicator;

  @override
  void initState() {
    user = User();
    passwordVisible = true;
    indicator = false;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    ScreenUtil.init(context, height: h, width: w, allowFontScaling: true);
    return Scaffold(
      body: ListView(
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 50.w),
            child: Form(
              key: _formKey,
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
                    SizedBox(height: 35.h,),
                    Padding(
                      padding: const EdgeInsets.only(right: 162),
                      child: Text("¿Quién eres?", maxLines: 2, style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black, fontSize: ScreenUtil().setSp(22)),),
                    ),
                    SizedBox(height: 8.h,),
                    TextFormField(
                        onChanged: (value){
                          setState(() => user.firstname = value);
                        },
                        validator: (val) => val.isEmpty ? "Introduce un nombre" : null,
                        decoration: textInputDeco.copyWith(hintText: "Nombre"),
                    ),
                    SizedBox(height: 8.h,),
                    TextFormField(
                        onChanged: (value){
                          setState(() => user.lastname = value);
                        },
                        validator: (val) => val.isEmpty ? "Introduce un apellido" : null,
                      decoration: textInputDeco.copyWith(hintText: "Apellidos"),
                    ),
                    SizedBox(height: 30.h,),
                    Padding(
                      padding: const EdgeInsets.only(right: 110),
                      child: Text("¿Cuál es tu email?", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black, fontSize: ScreenUtil().setSp(22)),),
                    ),
                    SizedBox(height: 8.h,),
                    TextFormField(
                      onChanged: (value){
                        setState(() => user.email = value);
                      },
                      validator: (val) => !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(val) ? "Introduce un email válido" : null,
                      decoration: textInputDeco.copyWith(hintText: "Email"),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 175),
                      child: Text(errorEmail, style: TextStyle(fontWeight: FontWeight.normal,color: Colors.red, fontSize: ScreenUtil().setSp(14)),),
                    ),
                    SizedBox(height: 30.h,),
                    Padding(
                      padding: const EdgeInsets.only(right: 22),
                      child: Text("Elige un nombre de usuario", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black, fontSize: ScreenUtil().setSp(22)),),
                    ),
                    SizedBox(height: 8.h,),
                    TextFormField(
                      onChanged: (value){
                        setState(() => user.username = value);
                      },
                      validator: (val) => val.isEmpty ? "Escribe un nombre de usuario": null,
                      decoration: textInputDeco.copyWith(hintText: "Nombre de usuario"),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 90),
                      child: Text(errorUser, style: TextStyle(fontWeight: FontWeight.normal,color: Colors.red, fontSize: ScreenUtil().setSp(14)),),
                    ),
                    SizedBox(height: 30.h,),
                    Padding(
                      padding: const EdgeInsets.only(right: 15),
                      child: Text("Necesitarás una contraseña", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black, fontSize: ScreenUtil().setSp(22)),),
                    ),
                    SizedBox(height: 8.h,),
                    Padding(
                      padding: const EdgeInsets.only(right: 25),
                      child: Text("Asegurate de que tenga 8 carácteres o más", style: TextStyle(fontWeight: FontWeight.w200,color: Colors.black, fontSize: ScreenUtil().setSp(14)),),
                    ),
                    SizedBox(height: 8.h,),
                    TextFormField(
                      obscureText: passwordVisible,
                      onChanged: (value){
                        setState(() => user.password = value);
                      },
                      validator: (val) => val.length < 8 ? "Introduce una contraseña válida" : null,
                      decoration: textInputDeco.copyWith(hintText: "Contraseña", suffixIcon: IconButton(
                        icon: Icon(
                          passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            passwordVisible = !passwordVisible;
                          });
                        },
                      ),),
                    ),
                    SizedBox(height: 15.h),
                  ]
              ),
            ),
        ),
        Divider(thickness: 1,),
          SizedBox(height: 12.h),
          indicator? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),),
            ],
          ) : Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              RawMaterialButton(
                child: Text("SIGUIENTE", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white, fontSize: ScreenUtil().setSp(20),),),
                fillColor: Color(0xff61b3d8),
                shape: RoundedRectangleBorder(),
                padding: EdgeInsets.all(18.0),
                onPressed: ()async{
                  if(_formKey.currentState.validate()){
                    setState(() {
                      indicator= true;
                    });
                    String result = await DBService().checkUsernameEmail(user.username, user.email);
                    if(result == "") {
                      errorUser = "";
                      errorEmail = "";
                      dynamic result = await AuthService().signUp(user);
                      if(result == null)
                        setState(() {
                          errorEmail = result.toString();
                          indicator= false;
                        });
                      else
                        Navigator.pushNamed(context, "/wrapper");
                    }
                    else{
                      setState(() {
                        indicator= false;
                      });
                      if(result.length == 2) {
                        errorUser = "Nombre de usuario ya escogido";
                        errorEmail = "Email ya escogido";
                      }
                      else if(result == "e") {
                        errorEmail = "Email ya escogido";
                        errorUser = "";
                      }
                      else {
                        errorUser = "Nombre de usuario ya escogido";
                        errorEmail = "";
                      }
                    }
                  }
                  else{
                    if(user.username == null || user.username == "")
                      errorUser = "";
                    if(user.email == null|| user.email == "")
                      errorEmail = "";
                    setState(() {
                    });
                  }
                }
              ),
              SizedBox(width: 50.w,)
            ],
          ),
          SizedBox(height: 20.w,)
        ]
      ),
    );
  }
}
