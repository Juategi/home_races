import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:homeraces/model/comment.dart';
import 'package:homeraces/model/user.dart';
import 'package:homeraces/services/dbservice.dart';
import 'package:homeraces/shared/alert.dart';
import 'package:homeraces/shared/common_data.dart';

class Report extends StatefulWidget {
  Report({this.comment});
  Comment comment;
  @override
  _ReportState createState() => _ReportState(comment: comment);
}

class _ReportState extends State<Report> {
  _ReportState({this.comment});
  User user;
  String error, report;
  Comment comment;
  bool loading;
  @override
  void initState() {
    user = DBService.userF;
    report = "";
    error = "";
    loading = false;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, height: CommonData.screenHeight, width: CommonData.screenWidth, allowFontScaling: true);
    return Column(children: <Widget>[
      SizedBox(height: 10.h,),
      Text("Reporta el comentario: ", style: TextStyle(fontSize: ScreenUtil().setSp(24), color: Colors.blueAccent,),),
      SizedBox(height: 30.h,),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text("║ ", style: TextStyle(fontWeight: FontWeight.bold,fontSize: ScreenUtil().setSp(18), color: Colors.black45,),),
          Text(comment.comment.length <= 26? comment.comment : "${comment.comment.substring(0,25)}...", style: TextStyle(fontStyle: FontStyle.italic,fontSize: ScreenUtil().setSp(14), color: Colors.black45,),),
        ],
      ),
      SizedBox(height: 30.h,),
      Container(
        width: 320.w,
        child: TextField(
          maxLength: 200,
          //autofocus: true,
          maxLines: 7,
          minLines: 1,
          decoration: InputDecoration(
            hintText: "Escribe tu reporte",
            fillColor: Colors.white30,
            filled: true,
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white, width: 2)
            ),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blueAccent, width: 2)
            ),
          ),
          onChanged: (text){
            report = text;
          },
        ),
      ),
      Text(error, style: TextStyle(fontWeight: FontWeight.normal,fontSize: ScreenUtil().setSp(14), color: Colors.red,),),
      SizedBox(height: 30.h,),
      loading? Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),),
        ],) :
      RawMaterialButton(
        child: Text("Enviar", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white, fontSize: ScreenUtil().setSp(20),),),
        fillColor: Color(0xff61b3d8),
        shape: RoundedRectangleBorder(),
        padding: EdgeInsets.only(right: 18.0.w, bottom: 18.0.h,top: 18.0.h,left: 18.w),
        onPressed: ()async{
          if(report == "")
            setState(() {
              error = "Escribe algo antes de enviar!";
            });
          else{
            setState(() {
              error = "";
              loading = true;
            });
            await DBService().sendReport(user.id, comment.id, report);
            setState(() {
              loading = false;
            });
            Alerts.toast("Reporte enviado!");
            Navigator.pop(context);
          }
        },
      ),
    ],);
  }
}