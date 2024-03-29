import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:homeraces/services/auth.dart';
import 'package:homeraces/shared/common_data.dart';
import 'package:homeraces/shared/decos.dart';
import 'package:homeraces/shared/loading.dart';

class LogIn extends StatefulWidget {
  @override
  _LogInState createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  String email, password, error;
  bool passwordVisible, buttonOn, indicator;
  @override
  void initState() {
    error = "";
    buttonOn = false;
    passwordVisible = true;
    indicator = false;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, height: CommonData.screenHeight, width: CommonData.screenWidth, allowFontScaling: true);
    return Scaffold(
      body: ListView(
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 40.w),
            child: Form(
              key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Container(
                        height: 150.h,
                        width: 150.w,
                        child: Image.asset("assets/auth/Logo.png")
                    ),
                    Text(
                      'EL NUEVO ESTILO DE COMPETICIÓN',
                      style: TextStyle(
                        fontFamily: 'Consolas',
                        fontSize: ScreenUtil().setSp(16),
                        color: const Color(0xff000000),
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(height: 60.h,),
                    TextFormField(
                      onChanged: (value){
                        setState(() {
                          email = value;
                          if(password != null && password != "")
                            buttonOn = true;
                          if(email == null || email == "")
                            buttonOn = false;
                        });
                      },
                      validator: (val) => !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(val) ? "Introduce un email válido" : null,
                      decoration: textInputDeco.copyWith(hintText: "Correo electrónico", counterText: ""),
                      maxLength: 100,
                    ),
                    SizedBox(height: 22.h,),
                    TextFormField(
                      obscureText: passwordVisible,
                      onChanged: (value){
                        setState(() {
                          password = value;
                          if(email != null && email != "")
                            buttonOn = true;
                          if(password == null || password == "")
                            buttonOn = false;
                        });
                      },
                      validator: (val) => val.length < 6 ? "Introduce una contraseña de al menos 6 carácteres" : null,
                      maxLength: 100,
                      decoration: textInputDeco.copyWith(hintText: "Contraseña", counterText: "", suffixIcon: IconButton(
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
                    SizedBox(height: 4.h,),
                    Text(error, style: TextStyle(fontWeight: FontWeight.normal,color: Colors.red, fontSize: ScreenUtil().setSp(13),), ),
                    SizedBox(height: 18.h,),
                    indicator? CircularLoading() : RaisedButton(
                      child: Text("Entrar", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white, fontSize: ScreenUtil().setSp(20),), ),
                      color: Color(0xff61b3d8),
                      padding: EdgeInsets.symmetric(horizontal: 128.w, vertical: 14.h),
                      disabledColor: Color.fromRGBO(210, 240, 247, 1),
                      onPressed: buttonOn ? () async {
                        if(_formKey.currentState.validate()){
                          setState(() {
                            indicator = true;
                          });
                          dynamic result = await _authService.logIn(email, password);
                          if(result == null)
                            setState(() {
                              error = "Email o contraseña incorrectos";
                              indicator = false;
                            });
                          else {
                            setState(() {
                              indicator = false;
                              error = "";
                            });
                            Navigator.pop(context);
                          }
                        }
                      } : null,
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 0.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Text( '¿Has olvidado tus datos de inicio de sesión?',  style: TextStyle(fontSize: ScreenUtil().setSp(11), color: Colors.grey,),),
                          FlatButton(child: Text( 'Recuperar.', style: TextStyle(fontSize: ScreenUtil().setSp(12), color: Colors.black,),), onPressed: ()async{
                              Navigator.pushNamed(context, "/reset");
                          },)
                        ],
                      ),
                    ),
                    SizedBox(height: 12.h,),
                    Text(" o iniciar con ", maxLines: 1 ,style: TextStyle(fontSize: ScreenUtil().setSp(15), color: Colors.grey[400],)),
                    SizedBox(height: 12.h,),
                    Row(
                      mainAxisAlignment:MainAxisAlignment.center,
                      children: <Widget>[
                      RaisedButton(
                        onPressed: ()async{
                          await _authService.loginFB();
                          Navigator.pushNamed(context, "/wrapper");
                          },
                        child: Text("f", style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Klavika Bold',color: Colors.white, fontSize: ScreenUtil().setSp(20),),),
                        color: const Color(0xff61b3d8),
                        shape: CircleBorder(),
                        padding: EdgeInsets.only(right: 11.0.w, bottom: 11.0.h,top: 11.0.h,left: 11.w),
                      ),
                      RaisedButton(
                        onPressed: ()async{
                          await _authService.loginGoogle();
                          Navigator.pushNamed(context, "/wrapper");
                          },
                        child: Text("G", style: TextStyle(fontFamily: 'Futura', color: Colors.white, fontSize: ScreenUtil().setSp(20),) ,),
                        color: const Color(0xff61b3d8),
                        shape: CircleBorder(),
                        padding: EdgeInsets.only(right: 11.0.w, bottom: 11.0.h,top: 11.0.h,left: 11.w),
                      ),
                    ],)
                  ],
                ),
            ),
          ),
          SizedBox(height: 35.h,),
          Divider(thickness: 1,),
          SizedBox(height: 7.h,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text( '¿No tienes cuenta?',  style: TextStyle(fontSize: ScreenUtil().setSp(16), color: Colors.grey,),),
              FlatButton(child: Text( 'Regístrate.', style: TextStyle(fontSize: ScreenUtil().setSp(16), color: Colors.black,),), onPressed: (){Navigator.pushNamed(context, "/signup");},)
            ],
          )
        ],
      )
    );
  }
}
