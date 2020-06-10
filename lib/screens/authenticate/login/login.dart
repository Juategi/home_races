import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_screenutil/size_extension.dart';

class LogIn extends StatefulWidget {
  @override
  _LogInState createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  final _formKey = GlobalKey<FormState>();
  String email, password;
  bool buttonOn;
  bool passwordVisible;
  InputDecoration textInputDeco = InputDecoration(
    fillColor: Colors.grey[10],
    filled: true,
    enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey[300], width: 2)
    ),
    focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey[350], width: 2)
    ),
  );
  @override
  void initState() {
    buttonOn = false;
    passwordVisible = true;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    ScreenUtil.init(context, height: h, width: w, allowFontScaling: true);
    return Scaffold(backgroundColor: const Color(0xffffffff),
      body: ListView(
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 40.w),
            child: Form(
              key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 40.h,),
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
                    SizedBox(height: 22.h,),
                    RaisedButton(
                      child: Text("Entrar", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white, fontSize: ScreenUtil().setSp(20),), ),
                      color: Color(0xff61b3d8),
                      padding: EdgeInsets.symmetric(horizontal: 128.w, vertical: 14.h),
                      disabledColor: Color.fromRGBO(210, 240, 247, 1),
                      onPressed: buttonOn ? () {
                        if(_formKey.currentState.validate()){
                          print("");
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
                    Text("──────────  o iniciar con  ──────────",  style: TextStyle(fontSize: ScreenUtil().setSp(15), color: Colors.grey[400],)),
                    SizedBox(height: 12.h,),
                    Row(
                      mainAxisAlignment:MainAxisAlignment.center,
                      children: <Widget>[
                      RaisedButton(
                        onPressed: (){print("F");},
                        child: Text("f", style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Klavika Bold',color: Colors.white, fontSize: ScreenUtil().setSp(20),),),
                        color: const Color(0xff61b3d8),
                        shape: CircleBorder(),
                        padding: EdgeInsets.all(11.0),
                      ),
                      RaisedButton(
                        onPressed: (){print("F");},
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
          SizedBox(height: 25.h,),
          Divider(thickness: 1,),
          SizedBox(height: 2.h,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text( '¿No tienes cuenta?',  style: TextStyle(fontSize: ScreenUtil().setSp(16), color: Colors.grey,),),
              FlatButton(child: Text( 'Regístrate.', style: TextStyle(fontSize: ScreenUtil().setSp(16), color: Colors.black,),))
            ],
          )
        ],
      )
    );
  }
}
