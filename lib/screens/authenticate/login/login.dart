import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:homeraces/services/auth.dart';
import 'package:homeraces/shared/common_data.dart';
import 'package:homeraces/shared/decos.dart';

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
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
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
                    SizedBox(height: 35.h,),
                    Text(
                      'HOME',
                      style: TextStyle(
                        fontFamily: 'Impact',
                        fontSize: ScreenUtil().setSp(52),
                        color: const Color(0xff000000),
                      ),
                      textAlign: TextAlign.left,
                    ),
                    Text(
                      'RACES',
                      style: TextStyle(
                        fontFamily: 'Ebrima',
                        fontSize: ScreenUtil().setSp(56),
                        color: const Color(0xff61b3d8),
                      ),
                      textAlign: TextAlign.left,
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
                    SizedBox(height: 70.h,),
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
                      decoration: textInputDeco.copyWith(hintText: "Correo electrónico"),
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
                      validator: (val) => val.length < 8 ? "Introduce una contraseña de mínimo 8 carácteres" : null,
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
                    SizedBox(height: 4.h,),
                    Text(error, style: TextStyle(fontWeight: FontWeight.normal,color: Colors.red, fontSize: ScreenUtil().setSp(13),), ),
                    SizedBox(height: 18.h,),
                    indicator? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),),
                      ],
                    ) : RaisedButton(
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
                      padding: const EdgeInsets.only(right: 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Text( '¿Has olvidado tus datos de inicio de sesión?',  style: TextStyle(fontSize: ScreenUtil().setSp(11), color: Colors.grey,),),
                          FlatButton(child: Text( 'Recuperar.', style: TextStyle(fontSize: ScreenUtil().setSp(12), color: Colors.black,),))
                        ],
                      ),
                    ),
                    SizedBox(height: 12.h,),
                    Text("────────  o iniciar con  ────────", maxLines: 1 ,style: TextStyle(fontSize: ScreenUtil().setSp(15), color: Colors.grey[400],)),
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
                        padding: EdgeInsets.all(11.0),
                      ),
                      RaisedButton(
                        onPressed: ()async{
                          await _authService.loginGoogle();
                          Navigator.pushNamed(context, "/wrapper");
                          },
                        child: Text("G", style: TextStyle(fontFamily: 'Futura', color: Colors.white, fontSize: ScreenUtil().setSp(20),) ,),
                        color: const Color(0xff61b3d8),
                        shape: CircleBorder(),
                        padding: EdgeInsets.all(11.0),
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
