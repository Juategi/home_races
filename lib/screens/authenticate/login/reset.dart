import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:homeraces/services/auth.dart';
import 'package:homeraces/shared/common_data.dart';
import 'package:homeraces/shared/decos.dart';
import 'package:homeraces/shared/loading.dart';

class ResetPassword extends StatefulWidget {
  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  String email;
  bool indicator;
  @override
  void initState() {
    indicator = false;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, height: CommonData.screenHeight, width: CommonData.screenWidth, allowFontScaling: true);
    return Scaffold(
        body: Container(
          padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 40.w),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 50.h,),
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
                SizedBox(height: 160.h,),
                TextFormField(
                  onChanged: (value){
                    setState(() {
                      email = value;
                    });
                  },
                  validator: (val) => !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(val) ? "Introduce un email válido" : null,
                  decoration: textInputDeco.copyWith(hintText: "Correo electrónico", counterText: ""),
                  maxLength: 100,
                ),
                SizedBox(height: 50.h,),
                indicator? CircularLoading() : RaisedButton(
                  child: Text("Enviar email", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white, fontSize: ScreenUtil().setSp(20),), ),
                  color: Color(0xff61b3d8),
                  padding: EdgeInsets.symmetric(horizontal: 100.w, vertical: 14.h),
                  disabledColor: Color.fromRGBO(210, 240, 247, 1),
                  onPressed: () async {
                    if(_formKey.currentState.validate()){
                      setState(() {
                        indicator = true;
                      });
                      await _authService.resetPassword(email);
                      setState(() {
                        indicator = false;
                      });
                      Navigator.pop(context);
                    }
                  }
                ),
          ],
        )
          )
        )
    );
  }
}
