import 'dart:io';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:homeraces/shared/common_data.dart';
import 'package:homeraces/shared/loading.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
class StorageService{

  final _uuid = Uuid();

  Future<String> uploadCompetitionImage(BuildContext context, String folder) async{
    File file;
    String fileName = "";
    String url;
    try{
      file = await FilePicker.getFile(type: FileType.image);
      if(file == null)
        return null;
      fileName = path.basename(file.path);
      fileName = fileName.split(".").first + _uuid.v4() + "." + fileName.split(".").last;
      print(fileName);
      Size size = ImageSizGetter.getSize(file);
      if(size.height != 800 || size.width != 800){
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Imagen no válida...'),
                content: Text('La imagen ha de ser de 800x800'),
                actions: <Widget>[
                  FlatButton(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            }
        );
        return null;
      }
      else{
        url = await _uploadImage(file, fileName, folder);
        print(url);
        return url;
      }
    }
    catch(e){
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Sorry...'),
              content: Text('Unsupported exception: $e'),
              actions: <Widget>[
                FlatButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          }
      );
      return "";
    }
  }

  Future<String> uploadImage(BuildContext context, String folder) async{
    File file;
    String fileName = "";
    String url, filePath;

    ScreenUtil.init(context, height: CommonData.screenHeight, width: CommonData.screenWidth, allowFontScaling: true);
    try{
       await showDialog(
          context: context,
          builder: (BuildContext context) {
            bool loading = false;
            return StatefulBuilder(
              builder: (context, setState) { return SimpleDialog(
                title: Container( alignment: Alignment.center,child: Text("Seleccionar una foto", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black, fontSize: ScreenUtil().setSp(22),),)),
                children: <Widget>[
                  Container(
                    height: 150.h,
                    child: loading? CircularLoading() : Row( mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        IconButton(icon: Icon(Icons.camera_alt),iconSize: ScreenUtil().setSp(40), color: Colors.blue, onPressed: ()async{
                          PickedFile f = await ImagePicker().getImage(source: ImageSource.camera);
                          setState((){
                            loading = true;
                          });
                          filePath = f.path;
                          file = File(filePath);
                          fileName = path.basename(filePath);
                          fileName = fileName.split(".").first + _uuid.v4() + "." + fileName.split(".").last;
                          print(fileName);
                          url = await _uploadImage(file, fileName, folder);
                          print(url);
                          Navigator.pop(context);
                        },),
                        IconButton(icon: Icon(Icons.image), iconSize: ScreenUtil().setSp(40), color: Colors.red, onPressed: ()async{
                          file = await FilePicker.getFile(type: FileType.image);
                          setState((){
                            loading = true;
                          });
                          filePath = file.path;
                          fileName = path.basename(filePath);
                          fileName = fileName.split(".").first + _uuid.v4() + "." + fileName.split(".").last;
                          print(fileName);
                          url = await _uploadImage(file, fileName, folder);
                          print(url);
                          Navigator.pop(context);
                        },)
                      ],
                    ),
                  ),
                ],
              );}
            );
          }
      );
       if(file == null)
         return null;
       return url;
    }
    catch(e){
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Sorry...'),
              content: Text('Unsupported exception: $e'),
              actions: <Widget>[
                FlatButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          }
      );
      return "";
    }
  }


  Future<String> _uploadImage(File file, String filename, String folder) async {
    StorageReference storageReference = FirebaseStorage.instance.ref().child("$folder/$filename");
    final StorageUploadTask uploadTask = storageReference.putFile(file);
    final StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);
    final String url = (await downloadUrl.ref.getDownloadURL());
    return url;
  }



  Future removeFile(String url) async {
    StorageReference storageReference = await FirebaseStorage.instance.getReferenceFromUrl(url);
    storageReference.delete();
    print("removed $url");
  }

}