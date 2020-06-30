import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:homeraces/model/comment.dart';
import 'package:homeraces/screens/competition/comments/comment_report.dart';
import 'package:homeraces/screens/competition/comments/comment_respond.dart';
import 'package:homeraces/services/dbservice.dart';
import 'package:homeraces/shared/common_data.dart';

class CommentBox extends StatefulWidget {
  Comment comment;
  CommentBox({this.comment});
  @override
  _CommentBoxState createState() => _CommentBoxState(comment: comment);
}

class _CommentBoxState extends State<CommentBox> {
  _CommentBoxState({this.comment});
  Comment comment;
  List<Comment> subComments;
  bool loading = false;

  @override
  void dispose() {
    comment = null;
    subComments = null;
    super.dispose();
  }

  @override
  void initState() {
    subComments = List<Comment>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, height: CommonData.screenHeight, width: CommonData.screenWidth, allowFontScaling: true);
    return Column(
      children: <Widget>[
        Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(right: 15.0.w, left: 15.0.w, top: 15.h, bottom: 15.h),
              padding: EdgeInsets.only(top: 15.h, bottom: 15.h, right: 5.0.w),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black45),
                  borderRadius: new BorderRadius.only(
                    topLeft: const Radius.circular(10.0),
                    topRight: const Radius.circular(10.0),
                    bottomLeft: const Radius.circular(10.0),
                    bottomRight: const Radius.circular(10.0),
                  )
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(width: 20.w,),
                  Container(
                      height: 35.h,
                      width: 35.w,
                      decoration: new BoxDecoration(
                          shape: BoxShape.circle,
                          image: new DecorationImage(
                              fit: BoxFit.fill,
                              image: new NetworkImage(comment.image ?? CommonData.defaultProfile)
                          )
                      )
                  ),
                  SizedBox(width: 20.w,),
                  Flexible(child: Text(comment.comment, maxLines: 15 ,overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(12), color: Colors.black),)),
                ],),),
            loading? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),),
              ],) :
            Row(children: <Widget>[
              SizedBox(width: 15.w,),
              Container( height:13.h,child: FlatButton(child: Text( 'Responder ', style: TextStyle(fontSize: ScreenUtil().setSp(11), color: Colors.blueAccent,),), onPressed: (){
                showModalBottomSheet(context: context, builder: (BuildContext bc){
                  return Respond(comment: comment, subComments: subComments, answer: comment,);
                }).then((value){setState(() {
                });});
              },)),
              subComments.length > 0 ? Container(height: 0,) :
              Container(height:13.h,child: FlatButton(child: Text( 'Ver más respuestas (${comment.numanswers})', style: TextStyle(fontSize: ScreenUtil().setSp(11), color: Colors.blueAccent,),), onPressed: ()async{
                setState(() {
                  loading = true;
                });
                print(subComments);
                if(subComments.length == 0)
                  subComments = await DBService().getSubComments(comment.competitionid, comment.id);
                setState(() {
                  loading = false;
                });
              },)),
              Container(height:13.h,child: FlatButton(child: Text( 'Reportar', style: TextStyle(fontSize: ScreenUtil().setSp(11), color: Colors.blueAccent,),), onPressed: (){
                showModalBottomSheet(context: context, builder: (BuildContext bc){
                  return Report(comment: comment);
                }).then((value){setState(() {
                });});
              },)),
            ],),
            SizedBox(height: 15.h,),
            subComments.length == 0? Container(height: 0,) : Column(children:
            subComments.map((sc){
              return Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(right: 15.0.w, left: 50.0.w, top: 15.h, bottom: 15.h),
                    padding: EdgeInsets.only(top: 15.h, bottom: 15.h, right: 5.0.w),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black45),
                        borderRadius: new BorderRadius.only(
                          topLeft: const Radius.circular(10.0),
                          topRight: const Radius.circular(10.0),
                          bottomLeft: const Radius.circular(10.0),
                          bottomRight: const Radius.circular(10.0),
                        )
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(width: 20.w,),
                        Container(
                            height: 35.h,
                            width: 35.w,
                            decoration: new BoxDecoration(
                                shape: BoxShape.circle,
                                image: new DecorationImage(
                                    fit: BoxFit.fill,
                                    image: new NetworkImage(sc.image ?? CommonData.defaultProfile)
                                )
                            )
                        ),
                        SizedBox(width: 20.w,),
                        Flexible(child: Text(sc.comment, maxLines: 15 ,overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(12), color: Colors.black),)),
                      ],),),
                  Row( mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(width: 45.w,),
                      Container( height:13.h,child: FlatButton(child: Text( 'Responder ', style: TextStyle(fontSize: ScreenUtil().setSp(11), color: Colors.blueAccent,),), onPressed: (){
                        showModalBottomSheet(context: context, builder: (BuildContext bc){
                          return Respond(comment: comment, subComments: subComments, answer: sc,);
                        }).then((value){setState(() {
                        });});
                      },)),
                      Container(height:13.h,child: FlatButton(child: Text( 'Reportar', style: TextStyle(fontSize: ScreenUtil().setSp(11), color: Colors.blueAccent,),), onPressed: (){
                        showModalBottomSheet(context: context, builder: (BuildContext bc){
                          return Report(comment: sc);
                        }).then((value){setState(() {
                        });});
                      },)),
                    ],
                  ),
                ],
              );
            }).toList()
              ,)
          ],
        ),
        SizedBox(height: 20.h,),
      ],
    );
  }
}
