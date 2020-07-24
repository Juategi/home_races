import 'package:flutter/material.dart';

class CommonData{
  static final screenHeight = 781;
  static final screenWidth = 392;
  static final String defaultProfile = "https://firebasestorage.googleapis.com/v0/b/home-races.appspot.com/o/user%2FUsuario.png?alt=media&token=12f7cb55-8574-44aa-9cf7-50afb66516f4";
  static final String defaultCompetition = "https://firebasestorage.googleapis.com/v0/b/home-races.appspot.com/o/competition%2Fimages.png?alt=media&token=07f30ed7-dc30-4612-811e-5f65e4bafe59";
  static final Image defaultImageCompetition = Image.network(defaultCompetition);
  static final List<String> modalities = ['Carrera','Fitness', 'Bicicleta', 'Comba', 'Circuito de resistencia'];
}


/*
Divider(thickness: 1,),
        SizedBox(height: 3.h,),
        Row(mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(width: 15.w,),
            Text('Buscar competiciones cercanas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: ScreenUtil().setSp(10), color: Colors.grey,),),
          ],
        ),
        Row(mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(width: 15.w,),
            Text(user.locality, style: TextStyle(fontWeight: FontWeight.bold, fontSize: ScreenUtil().setSp(14), color: Colors.black,),),SizedBox(width: 10.w,),
            SizedBox(width: 210.w,),
            FlatButton(child: Row(
              children: <Widget>[
                Icon(Icons.location_on, color: const Color(0xff61b3d8), size: ScreenUtil().setSp(18),),
                Text('Cambiar', style: TextStyle(fontSize: ScreenUtil().setSp(13), color: const Color(0xff61b3d8),),),
              ],
            ), onPressed: (){
            },)
          ],
        ),
        Container(
          height: 100.h,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: CommonData.modalities.map((String value) {
              return Card(
                child: Container(
                  width: 90.w,
                  child: Column( mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: ScreenUtil().setSp(10), color: Colors.black,),),
                    ],
                  ),
                ),
              );
            }
          ).toList(),
        ),),

 */