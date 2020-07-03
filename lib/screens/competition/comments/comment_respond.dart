import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:homeraces/model/comment.dart';
import 'package:homeraces/model/user.dart';
import 'package:homeraces/services/dbservice.dart';
import 'package:homeraces/shared/common_data.dart';

class Respond extends StatefulWidget {
  Respond({this.comment, this.subComments, this.answer});
  Comment comment,answer;
  List<Comment> subComments;
  @override
  _RespondState createState() => _RespondState(parent: comment, subComments: subComments, answer: answer);
}

class _RespondState extends State<Respond> {
  _RespondState({this.parent, this.subComments, this.answer});
  User user;
  String error;
  Comment parent, comment, answer;
  List<Comment> subComments;
  bool loading;
  @override
  void initState() {
    comment = Comment();
    user = DBService.userF;
    comment.parentid = parent.id;
    comment.userid = user.id;
    comment.image = user.image;
    comment.numanswers = 0;
    error = "";
    comment.comment = "";
    comment.competitionid = parent.competitionid;
    loading = false;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, height: CommonData.screenHeight, width: CommonData.screenWidth, allowFontScaling: true);
    return Column(children: <Widget>[
      SizedBox(height: 10.h,),
      Text("Responde al comentario: ", style: TextStyle(fontSize: ScreenUtil().setSp(24), color: Colors.blueAccent,),),
      SizedBox(height: 30.h,),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text("║ ", style: TextStyle(fontWeight: FontWeight.bold,fontSize: ScreenUtil().setSp(18), color: Colors.black45,),),
          Text(answer.comment.length <= 26? answer.comment : "${answer.comment.substring(0,25)}...", style: TextStyle(fontStyle: FontStyle.italic,fontSize: ScreenUtil().setSp(14), color: Colors.black45,),),
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
              hintText: "Escribe tu comentario",
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
            comment.comment = text;
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
          if(comment.comment.length == 0)
            setState(() {
              error = "Escribe algo antes de enviar!";
            });
          else{
            setState(() {
              error = "";
              loading = true;
            });
            if(subComments.length == 0){
              subComments.addAll(await DBService().getSubComments(comment.competitionid, comment.parentid));
            }
            subComments.add(comment);
            await DBService().postComment(comment);
            if(parent.userid != DBService.userF.id){
              await DBService().createNotification(parent.userid, "Alguien ha respondido tu comentario!", comment.competitionid.toString());
            }
            setState(() {
              loading = false;
            });
            Navigator.pop(context);
          }
        },
      ),
    ],);
  }
}
