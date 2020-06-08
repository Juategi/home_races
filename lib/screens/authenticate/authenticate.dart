import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:homeraces/services/app_localizations.dart';
import 'package:homeraces/services/auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_screenutil/size_extension.dart';


class Authenticate extends StatefulWidget {

  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {

  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    ScreenUtil.init(context, height: h, width: w, allowFontScaling: true);
    return Scaffold(
      backgroundColor: const Color(0xffffffff),
      body: Container(
        height: h,
        width: w,
        child: Stack(
          children: <Widget>[
            Positioned(
              top: 140.h,
              left: 115.w,
              child: Text(
                'HOME',
                style: TextStyle(
                  fontFamily: 'Impact',
                  fontSize: ScreenUtil().setSp(52),
                  color: const Color(0xff000000),
                ),
                textAlign: TextAlign.left,
              ),
            ),
            Positioned(
              top: 190.h,
              left: 105.w,
              child: Text(
                'RACES',
                style: TextStyle(
                  fontFamily: 'Ebrima',
                  fontSize: ScreenUtil().setSp(56),
                  color: const Color(0xff61b3d8),
                ),
                textAlign: TextAlign.left,
              ),
            ),
            Positioned(
              top: 267.h,
              left: 60.w,
              child: Text(
                'EL NUEVO ESTILO DE COMPETICIÓN',
                style: TextStyle(
                  fontFamily: 'Consolas',
                  fontSize: ScreenUtil().setSp(16),
                  color: const Color(0xff000000),
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.left,
              ),
            ),
            Positioned(
              top: 400.h,
              left: 63.w,
              child: Text(
                'Regístrate para crear una cuenta',
                style: TextStyle(
                  fontFamily: 'Segoe UI',
                  fontSize: ScreenUtil().setSp(17),
                  color: const Color(0xff242222),
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.left,
              ),
            ),
            Positioned(
              top: 450.h,
              left: 43.w,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  RaisedButton(
                    onPressed: (){print("F");},
                    child: Text("f", style: TextStyle(fontFamily: 'Klavika Bold',color: Colors.white, fontSize: ScreenUtil().setSp(35),),),
                    color: const Color(0xff61b3d8),
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(13.0),
                  ),
                  SizedBox(width: 15.w,),
                  RaisedButton(
                    onPressed: (){print("F");},
                    child: Text("G", style: TextStyle(fontFamily: 'Futura', color: Colors.white, fontSize: ScreenUtil().setSp(35),) ,),
                    color: const Color(0xff61b3d8),
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(13.0),
                  ),
                  SizedBox(width: 15.w,),
                  RaisedButton(
                    onPressed: (){Navigator.pushNamed(context, "/signup");},
                    child: Icon(Icons.mail, color: Colors.white,size: ScreenUtil().setSp(35),),
                    color: const Color(0xff61b3d8),
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(16.0),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 540.h,
              left: 50.w,
              child: Text(
                'Jamás publicaremos sin tu permiso',
                style: TextStyle(
                  fontFamily: 'Segoe UI',
                  fontSize: ScreenUtil().setSp(18),
                  color: const Color(0xff242222),
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.left,
              ),
            ),
            Positioned(
              top: 645.h,
              left: 53.w,
              child: Text(
                'Continuar implica que has leído y aceptado los',
                style: TextStyle(
                  fontFamily: 'Segoe UI',
                  fontSize: ScreenUtil().setSp(13),
                  color: const Color(0xff242222),
                ),
                textAlign: TextAlign.left,
              ),
            ),
            Positioned(
              top: 664.h,
              left: 51.w,
              child: Text(
                'Términos y condiciones y política de privacidad',
                style: TextStyle(
                  fontFamily: 'Segoe UI',
                  fontSize: ScreenUtil().setSp(13),
                  color: const Color(0xff242222),
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.left,
              ),
            ),
            Positioned(
              top: 705.h,
              left: 22.w,
              child: SvgPicture.string(
                _svg_ostajg,
                allowDrawingOutsideViewBox: true,
              ),
            ),
            Positioned(
              top: 725.h,
              left: 37.w,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    '¿Ya tienes una cuenta?',
                    style: TextStyle(
                      fontFamily: 'Segoe UI',
                      fontSize: ScreenUtil().setSp(16),
                      color: const Color(0xff458f8d),
                    ),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(width: 15.w,),
                  RawMaterialButton(
                    onPressed: null,
                    child: Text("INICIA SESIÓN", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white, fontSize: ScreenUtil().setSp(14),),),
                    fillColor: Colors.pinkAccent[400],
                    shape: StadiumBorder(),
                    padding: EdgeInsets.all(8.0),

                  ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}

const String _svg_ostajg =
    '<svg viewBox="17.5 690.5 339.0 1.0" ><path transform="translate(17.5, 690.5)" d="M 0 0 L 13.2421875 0 L 64.88671875 0 L 339 0" fill="none" stroke="#000000" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';


