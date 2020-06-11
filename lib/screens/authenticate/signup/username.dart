import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:homeraces/model/user.dart';
import 'package:homeraces/screens/home/home.dart';
import 'package:homeraces/services/dbservice.dart';
import 'package:provider/provider.dart';

class UsernameScreen extends StatefulWidget {
  @override
  _UsernameScreenState createState() => _UsernameScreenState();
}

class _UsernameScreenState extends State<UsernameScreen> {
  final _formKey = GlobalKey<FormState>();
  User user;
  String errorUser = " ";
  bool indicator = false;
  bool flag = true;
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
  Widget build(BuildContext context) {
    user = Provider.of<User>(context);
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    ScreenUtil.init(context, height: h, width: w, allowFontScaling: true);
    print(user);
    return Scaffold(
      body: ListView(
        children: <Widget>[
          Container(
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
                    child: Text("Introduce un nombre de usuario", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black, fontSize: ScreenUtil().setSp(22)),),
                  ),
                  TextFormField(
                    onChanged: (value){
                      setState(() => user.username = value);
                    },
                    validator: (val) => val.isEmpty ? "Escribe un nombre de usuario": null,
                    decoration: textInputDeco.copyWith(hintText: "Nombre de usuario"),
                  ),
                ],
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
          ): Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RawMaterialButton(
                  child: Text("SIGUIENTE", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white, fontSize: ScreenUtil().setSp(20),),),
                  fillColor: Color(0xff61b3d8),
                  shape: RoundedRectangleBorder(),
                  padding: EdgeInsets.all(18.0),
                  onPressed: ()async {
                    if (_formKey.currentState.validate()) {
                      setState(() {
                        indicator = true;
                      });
                      bool result = await DBService().checkUsername(user.username);
                      if(result){
                        setState(() {
                          errorUser = "Nombre de usuario ya escogido";
                          indicator = false;
                        });
                      }
                      else {
                        setState(() {
                          errorUser = "";
                          indicator = false;
                        });
                        await DBService().deleteUser(user);
                        await DBService().createUser(user);
                        Navigator.pushNamed(context, "/home", arguments: user);
                      }
                    }
                  }
              )
            ],
          )
        ],
      ),
    );
  }

}
