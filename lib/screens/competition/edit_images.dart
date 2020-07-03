import 'package:flutter/material.dart';
import 'package:homeraces/model/competition.dart';
import 'package:homeraces/services/storage.dart';
import 'package:homeraces/shared/common_data.dart';
import 'package:reorderables/reorderables.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_screenutil/size_extension.dart';

class EditImages extends StatefulWidget {
  Competition competition;
  EditImages({this.competition});
  @override
  _EditImagesState createState() => _EditImagesState(competition: competition);
}

class _EditImagesState extends State<EditImages> {
  _EditImagesState({this.competition});
  final StorageService _storageService = StorageService();
  Competition competition;

  List<Widget> _initItems(){
    List<Widget> items = competition.gallery.map((String url) {
      return GridTile(
          child: FlatButton(
            onPressed: (){
              setState(() {
                competition.gallery.remove(url);
                _storageService.removeFile(url);
              });
            },
            padding: EdgeInsets.all(0.0),
            child: Container(
                constraints: BoxConstraints.expand(
                    height: 90.h,
                    width: 90.w
                ),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: Image.network(url).image,
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      right: 35.w,
                      bottom: 3.0.h,
                      child: Icon(Icons.delete, size: ScreenUtil().setSp(20), color: Colors.black,),
                    ),
                  ],
                )
            ),
          )
      );
    }).toList();
    items.add(
     GridTile(
        child: competition.gallery.length >= 16? Container(height: 0,) : IconButton(
          icon: Icon(Icons.add_circle_outline, color: Colors.grey[500],),
          iconSize: ScreenUtil().setSp(73),
          onPressed: ()async{
            String image = await _storageService.uploadImage(context,"gallery");
            if(image != null){
              setState((){
                competition.gallery.add(image);
              });
            }
          },
        ),
      )
    );
    return items;
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, height: CommonData.screenHeight, width: CommonData.screenWidth, allowFontScaling: true);
    return Column(children: <Widget>[
      Expanded(child:
        ReorderableWrap(
            spacing: 8.0,
            runSpacing: 4.0,
            padding: const EdgeInsets.all(8),
            onReorder: (a,b){
              setState(() {
                var tmp = competition.gallery.removeAt(a);
                competition.gallery.insert(b, tmp);
              });
            },
          children: _initItems()),
      ),
    ],);
  }
}