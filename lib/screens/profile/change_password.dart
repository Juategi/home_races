import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:homeraces/model/user.dart';
import 'package:homeraces/services/auth.dart';
import 'package:homeraces/shared/alert.dart';
import 'package:homeraces/shared/common_data.dart';
import 'package:homeraces/shared/decos.dart';

class ChangePassword extends StatefulWidget {
  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _auth = AuthService();
  String oldPass,newPass, newPassConfirm;
  bool loading = false;
  User user;
  @override
  Widget build(BuildContext context) {
    user = ModalRoute.of(context).settings.arguments;
    ScreenUtil.init(context, height: CommonData.screenHeight, width: CommonData.screenWidth, allowFontScaling: true);
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.black,),
              onPressed: (){
                Navigator.pop(context);
              }
          )
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 30.w),
        child: Form(
          key: _formKey,
          child: Column( mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                onChanged: (value){
                  setState(() => oldPass = value);
                },
                validator: (val) => val.length < 8 || val != user.password ? "Escribe tu antigua contraseña de al menos 8 carácteres": null,
                maxLength: 100,
                decoration: textInputDeco.copyWith(hintText: "Contraseña antigua", counterText: ""),
                obscureText: true,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: ScreenUtil().setSp(18), color: Colors.black),
              ),
              SizedBox(height: 30.h,),
              TextFormField(
                onChanged: (value){
                  setState(() => newPass = value);
                },
                validator: (val) => val.length < 8 ? "Escribe tu nueva contraseña de al menos 8 carácteres": null,
                maxLength: 100,
                decoration: textInputDeco.copyWith(hintText: "Contraseña nueva", counterText: ""),
                obscureText: true,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: ScreenUtil().setSp(18), color: Colors.black),
              ),
              SizedBox(height: 30.h,),
              TextFormField(
                onChanged: (value){
                  setState(() => newPassConfirm = value);
                },
                validator: (val) => val.length < 8 || val != newPass ? "Las contraseñas han de coincidir": null,
                maxLength: 100,
                decoration: textInputDeco.copyWith(hintText: "Confirma contraseña nueva", counterText: ""),
                obscureText: true,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: ScreenUtil().setSp(18), color: Colors.black),
              ),
              SizedBox(height: 50.h,),
              loading? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),),
                ],
              ):RawMaterialButton(
                child: Text("GUARDAR", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white, fontSize: ScreenUtil().setSp(21),),),
                fillColor: Color(0xff61b3d8),
                shape: StadiumBorder(),
                elevation: 0,
                padding: EdgeInsets.only(right: 80.0.w, bottom: 18.0.h, top: 18.0.h, left: 80.w),
                onPressed: ()async{
                  if(_formKey.currentState.validate()) {
                    setState(() {
                      loading = true;
                    });
                    if(oldPass == user.password && newPass == newPassConfirm){
                      await _auth.changePassword(user, newPass);
                      Alerts.toast("Contraseña actualizada");
                      Navigator.pop(context);
                    }
                    setState(() {
                      loading = false;
                    });
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
