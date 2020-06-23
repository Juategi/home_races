import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:homeraces/model/comment.dart';
import 'package:homeraces/screens/competition/comments/comment_box.dart';
import 'package:homeraces/shared/common_data.dart';

class CommentSection extends StatefulWidget {
  CommentSection({this.list});
  List<Comment> list = List<Comment>();
  @override
  _CommentSectionState createState() => _CommentSectionState(comments: list);
}

class _CommentSectionState extends State<CommentSection> {
  _CommentSectionState({this.comments});
  List<Comment> comments = List<Comment>();
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, height: CommonData.screenHeight, width: CommonData.screenWidth, allowFontScaling: true);
    return Column(children:
      comments.map((comment){
        return CommentBox(comment: comment);
      }).toList()
    );
  }
}
