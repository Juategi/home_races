import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:homeraces/model/competition.dart';
import 'package:homeraces/model/user.dart';
import 'package:homeraces/screens/competition/edit_images.dart';
import 'package:homeraces/services/dbservice.dart';
import 'package:homeraces/services/storage.dart';
import 'package:homeraces/shared/alert.dart';
import 'package:homeraces/shared/common_data.dart';
import 'package:homeraces/shared/decos.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:homeraces/shared/loading.dart';
import 'package:intl/intl.dart';


class CreateCompetition extends StatefulWidget {
  @override
  _CreateCompetitionState createState() => _CreateCompetitionState();
}

class _CreateCompetitionState extends State<CreateCompetition> {
  final StorageService _storageService = StorageService();
  final _formKey = GlobalKey<FormState>();
  final format = DateFormat("yyyy-MM-dd HH:mm");
  Competition competition;
  User user;
  String image, error, capacity, price, duration;
  bool disableCapacity, promote, loading, timeless, admin;

  void _timer() {
    if(admin == null) {
      Future.delayed(Duration(seconds: 2)).then((_) {
        setState(() {
          print("Loading...");
        });
        _timer();
      });
    }
  }

  Future _admin() async{
    admin = await DBService.dbService.checkAdmin(user.id);
  }

  Future<bool> _deleteImagesOnReturn() async{
    for(String image in competition.gallery){
      _storageService.removeFile(image);
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    disableCapacity = false;
    promote = false;
    loading = false;
    timeless = false;
    competition = Competition();
    competition.promoted = 'N';
    competition.modality = "Carrera";
    competition.image = CommonData.defaultCompetition;
    competition.rewards = " ";
    competition.numcompetitors = 0;
    competition.price = 0.0;
    competition.gallery = List<String>();
    error = "";
  }

  @override
  Widget build(BuildContext context) {
    String image = CommonData.defaultCompetition;
    user = ModalRoute.of(context).settings.arguments;
    _admin();
    _timer();
    ScreenUtil.init(context, height: CommonData.screenHeight, width: CommonData.screenWidth, allowFontScaling: true);
    return WillPopScope(
      onWillPop: _deleteImagesOnReturn,
      child: Scaffold(
        appBar:AppBar(
          elevation: 0,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.black,),
              onPressed: (){
                _deleteImagesOnReturn();
                Navigator.pop(context);
              }
          )
        ),
        body: ListView(children: <Widget>[
          Container(
            child: Form(
              key: _formKey,
              child: Column(children: <Widget>[
                SizedBox(height: 20.h,),
                Container(
                    child: FlatButton(
                        onPressed: () async{
                          String aux = await _storageService.uploadImage(context, "competition");
                          if(aux != null){
                            setState(() {
                              image = aux;
                              competition.image = image;
                            });
                          }
                        },
                        padding: EdgeInsets.only(right: 0.w, bottom: 0.h,top: 0.h,left: 0.w),
                        child: Container(
                            constraints: BoxConstraints.expand(
                              height: 130.0.h,
                              width: 130.0.w
                            ),
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: image == null? CommonData.defaultImageCompetition.image : Image.network(image).image,
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Stack(
                              children: <Widget>[
                                Positioned(
                                  right: 50.w,
                                  bottom: 5.0.h,
                                  child: Icon(Icons.collections, size: ScreenUtil().setSp(30), color: Colors.black45,),
                                ),
                              ],
                            )
                        )
                    )
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 25.w),
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 20.h,),
                      Padding(
                        padding: EdgeInsets.only(right: 230.w),
                        child: Text("Nombre del evento", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black, fontSize: ScreenUtil().setSp(13)),),
                      ),
                      SizedBox(height: 8.h,),
                      TextFormField(
                        onChanged: (value){
                          setState(() => competition.name = value);
                        },
                        validator: (val) => val.length < 4 || val.length > 120 ? "Mínimo 4 carácteres y menos de 120" : null,
                        decoration: textInputDeco.copyWith(hintText: "Nombre de la competición"),
                        autofocus: false,
                        maxLength: 120,
                      ),
                      SizedBox(height: 20.h,),
                      Padding(
                        padding: EdgeInsets.only(right: 202.w),
                        child: Text("Fecha y hora de inicio evento", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black, fontSize: ScreenUtil().setSp(13)),),
                      ),
                      SizedBox(height: 10.h,),
                      DateTimeField(
                        decoration: textInputDeco.copyWith(hintText: "Fecha de la competición"),
                        format: format,
                        validator: (val) => !timeless && ( val == null || competition.eventdate.isBefore(DateTime.now()) )? "Fecha del evento ha de ser en el futuro" : null,
                        onChanged: (date){
                          competition.eventdate = date;
                        },
                        onShowPicker: (context, currentValue) async {
                          final date = await showDatePicker(
                              context: context,
                              firstDate: DateTime(1900),
                              initialDate: currentValue ?? DateTime.now(),
                              lastDate: DateTime(2100));
                          if (date != null) {
                            final time = await showTimePicker(
                              context: context,
                              initialTime:
                              TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
                            );
                            return DateTimeField.combine(date, time);
                          } else {
                            return currentValue;
                          }
                        },
                      ),
                      SizedBox(height: 20.h,),
                      Padding(
                        padding: EdgeInsets.only(right: 202.w),
                        child: Text("Fecha y hora de fin del evento", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black, fontSize: ScreenUtil().setSp(13)),),
                      ),
                      SizedBox(height: 10.h,),
                      DateTimeField(
                        decoration: textInputDeco.copyWith(hintText: "Fecha fin de la competición"),
                        format: format,
                        validator: (val) => !timeless && (val == null || competition.enddate.isBefore(competition.eventdate)) ? "Fin ha de ser posterior al inicio" : null,
                        onChanged: (date){
                          competition.enddate = date;
                        },
                        onShowPicker: (context, currentValue) async {
                          final date = await showDatePicker(
                              context: context,
                              firstDate: DateTime(1900),
                              initialDate: currentValue ?? DateTime.now(),
                              lastDate: DateTime(2100));
                          if (date != null) {
                            final time = await showTimePicker(
                              context: context,
                              initialTime:
                              TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
                            );
                            return DateTimeField.combine(date, time);
                          } else {
                            return currentValue;
                          }
                        },
                      ),
                      SizedBox(height: 20.h,),
                      Padding(
                        padding: EdgeInsets.only(right: 130.w),
                        child: Text("Fecha y hora máxima de inscripción", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black, fontSize: ScreenUtil().setSp(13)),),
                      ),
                      SizedBox(height: 10.h,),
                      DateTimeField(
                        decoration: textInputDeco.copyWith(hintText: "Fecha de inscripción"),
                        validator: (val) => !timeless && (val == null || competition.maxdate.isAfter(competition.enddate)) ? "Fecha de inscripción ha de ser anterior a la de fin de evento" : null,
                        format: format,
                        onChanged: (date){
                          competition.maxdate = date;
                        },
                        onShowPicker: (context, currentValue) async {
                          final date = await showDatePicker(
                              context: context,
                              firstDate: DateTime(1900),
                              initialDate: currentValue ?? DateTime.now(),
                              lastDate: DateTime(2100));
                          if (date != null) {
                            final time = await showTimePicker(
                              context: context,
                              initialTime:
                              TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
                            );
                            return DateTimeField.combine(date, time);
                          } else {
                            return currentValue;
                          }
                        },
                      ),
                      SizedBox(height: 20.h,),
                      Padding(
                        padding: EdgeInsets.only(right: 265.w),
                        child: Text("Zona horaria", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black, fontSize: ScreenUtil().setSp(13)),),
                      ),
                      SizedBox(height: 10.h,),
                      Padding(
                        padding: EdgeInsets.only(right: 240.w),
                        child: DropdownButton<String>(
                          items: <String>['Canarias', 'Península'].map((String value) {
                            return new DropdownMenuItem<String>(
                              value: value,
                              child: new Text(value),
                            );
                          }).toList(),
                          value: competition.timezone,
                          hint: Text("Selecciona"),
                          onChanged: (String tz) {
                            setState(() {
                              competition.timezone = tz;
                            });
                            if(competition.timezone != null && competition.type != null &&
                                competition.modality != null && competition.locality != null){
                              setState(() {
                                error = "";
                              });
                            }
                          },
                        ),
                      ),
                      SizedBox(height: 20.h,),
                      Padding(
                        padding: EdgeInsets.only(right: 255.w),
                        child: Text("Tipo de evento", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black, fontSize: ScreenUtil().setSp(13)),),
                      ),
                      SizedBox(height: 10.h,),
                      Padding(
                        padding: EdgeInsets.only(right: 170.w),
                        child: DropdownButton<String>(
                          items: <String>['Publico','Privado'].map((String value) {
                            return new DropdownMenuItem<String>(
                              value: value,
                              child: new Text(value),
                            );
                          }).toList(),
                          value: competition.type,
                          isExpanded: true,
                          hint: Text("Selecciona"),
                          onChanged: (String type) {
                            setState(() {
                              competition.type = type;
                            });
                            if(competition.timezone != null && competition.type != null &&
                                competition.modality != null && competition.locality != null){
                              setState(() {
                                error = "";
                              });
                            }
                          },
                        ),
                      ),
                      /*Padding(
                        padding: EdgeInsets.only(right: 275.w),
                        child: Text("Modalidad", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black, fontSize: ScreenUtil().setSp(13)),),
                      ),
                      SizedBox(height: 10.h,),
                      Padding(
                        padding: EdgeInsets.only(right: 170.w),
                        child: DropdownButton<String>(
                          items: CommonData.modalities.map((String value) {
                            return new DropdownMenuItem<String>(
                              value: value,
                              child: new Text(value),
                            );
                          }).toList(),
                          value: competition.modality,
                          isExpanded: true,
                          hint: Text("Selecciona"),
                          onChanged: (String modality) {
                            setState(() {
                              competition.modality = modality;
                            });
                            if(competition.timezone != null && competition.type != null &&
                                competition.modality != null && competition.locality != null){
                              setState(() {
                                error = "";
                              });
                            }
                          },
                        ),
                      ),*/
                      SizedBox(height: 20.h,),
                      Padding(
                        padding: EdgeInsets.only(right: 300.w),
                        child: Text("Región", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black, fontSize: ScreenUtil().setSp(13)),),
                      ),
                      SizedBox(height: 10.h,),
                      Padding(
                        padding: EdgeInsets.only(right: 170.w),
                        child: DropdownButton<String>(
                          items: <String>['Internacional','España', 'Comunidad autónoma', 'Provincia', 'Municipio'].map((String value) {
                            return new DropdownMenuItem<String>(
                              value: value,
                              child: new Text(value),
                            );
                          }).toList(),
                          value: competition.locality,
                          isExpanded: true,
                          hint: Text("Selecciona"),
                          onChanged: (String locality) {
                            setState(() {
                              competition.locality = locality;
                            });
                          },
                        ),
                      ),
                      SizedBox(height: 10.h,),
                      Padding(
                        padding: EdgeInsets.only(right: 240.w),
                        child: Text("Distancia en km", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black, fontSize: ScreenUtil().setSp(13)),),
                      ),
                      SizedBox(height: 10.h,),
                      Padding(
                        padding: EdgeInsets.only(right: 190.w),
                        child: Container(
                          width: 150.w,
                          child: TextFormField(
                            onChanged: (value){
                              setState(() {
                                price = value;
                                if(price == "")
                                  competition.distance = 0;
                                else
                                  competition.distance = double.parse(price).toInt();
                              });
                            },
                            validator: (val) => val.length < 1 || val.contains(".") || val.contains(",")  ? "Sin decimales" : null,
                            keyboardType: TextInputType.numberWithOptions(decimal: false, signed: false),
                            maxLength: 5,
                            decoration: textInputDeco.copyWith(hintText: "Distancia en km", counterText: "",),
                          ),
                        ),
                      ),
                      SizedBox(height: 2.h,),
                      Padding(
                        padding: EdgeInsets.only(right: 73.w),
                        child: Text(error, style: TextStyle(color: Colors.red[700], fontSize: ScreenUtil().setSp(12)),),
                      ),
                      SizedBox(height: 10.h,),
                      Padding(
                        padding: EdgeInsets.only(right: 100.w),
                        child: Text("Aforo, número máximo de parcitipantes", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black, fontSize: ScreenUtil().setSp(13)),),
                      ),
                      SizedBox(height: 10.h,),
                      Row(
                        children: <Widget>[
                          Container(
                            width: 150.w,
                            child: TextFormField(
                              onChanged: (value){
                                setState(() {
                                  capacity = value;
                                  if(capacity == "")
                                    competition.capacity = 0;
                                  else
                                    competition.capacity = int.parse(capacity);
                                });
                              },
                              keyboardType: TextInputType.number,
                              enabled: !disableCapacity,
                              autofocus: false,
                              maxLength: 6,
                              validator: (val) => val.isEmpty && !disableCapacity ? "No puede estar vacío" : null,
                              decoration: textInputDeco.copyWith(hintText: "Aforo", counterText: "",),
                            ),
                          ),
                          Container(
                            width: 180.w,
                            child: CheckboxListTile(
                              title: Text("Sin límite", style: TextStyle(fontWeight: FontWeight.normal ,color: Colors.black, fontSize: ScreenUtil().setSp(15)),),
                              value: disableCapacity,
                              onChanged: (newValue) {
                                setState(() {
                                  disableCapacity = newValue;
                                  if(newValue)
                                    competition.capacity = -1;
                                  else if(capacity == null){
                                    competition.capacity = null;
                                  }
                                  else if(capacity == "")
                                    competition.capacity = 0;
                                  else
                                    competition.capacity = int.parse(capacity);

                                });
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 20.h,),
                      Padding(
                        padding: EdgeInsets.only(right: 290.w),
                        child: Text("Premios", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black, fontSize: ScreenUtil().setSp(13)),),
                      ),
                      SizedBox(height: 10.h,),
                      TextFormField(
                        onChanged: (value){
                          setState(() => competition.rewards = value);
                        },
                        //validator: (val) => val.length < 15 || val.length > 199 ? "Describe el premio con 15-200 carácteres" : null,
                        decoration: textInputDeco.copyWith(hintText: "Premios de la competición"),
                        maxLength: 100,
                      ),
                      SizedBox(height: 20.h,),
                      Padding(
                        padding: EdgeInsets.only(right: 267.w),
                        child: Text("Descripción", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black, fontSize: ScreenUtil().setSp(13)),),
                      ),
                      SizedBox(height: 10.h,),
                      TextFormField(
                        onChanged: (value){
                          setState(() => competition.observations = value);
                        },
                        validator: (val) => val.length < 15 || val.length > 100 ? "Describe las observaciones con 15-100 carácteres" : null,
                        decoration: textInputDeco.copyWith(hintText: "Observaciones, al menos 15 carácteres"),
                        maxLength: 200,
                      ),
                      SizedBox(height: 10.h,),
                      Padding(
                        padding: EdgeInsets.only(right: 267.w),
                        child: Text("Imágenes", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black, fontSize: ScreenUtil().setSp(13)),),
                      ),
                      SizedBox(height: 10.h,),
                      Container(
                        height: (300).h,
                        child: EditImages(competition: competition,),
                      ),
                      SizedBox(height: 20.h,),
                      admin == null? CircularLoading() : !admin? Container() : Column(
                        children: <Widget>[
                          Container(
                            width: 180.w,
                            child: CheckboxListTile(
                              title: Text("Oficial" , maxLines: 1, style: TextStyle(fontWeight: FontWeight.normal ,color: Colors.black, fontSize: ScreenUtil().setSp(13)),),
                              value: promote,
                              onChanged: (newValue) {
                                setState(() {
                                  promote = newValue;
                                  if(newValue)
                                    competition.promoted = 'P';
                                  else
                                    competition.promoted = 'N';
                                });
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                            ),
                          ),
                          SizedBox(height: 5.h,),
                          Container(
                            width: 180.w,
                            child: CheckboxListTile(
                              title: Text("Atemporal" , maxLines: 1, style: TextStyle(fontWeight: FontWeight.normal ,color: Colors.black, fontSize: ScreenUtil().setSp(13)),),
                              value: timeless,
                              onChanged: (newValue) {
                                setState(() {
                                  timeless = newValue;
                                });
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                            ),
                          ),
                          SizedBox(height: 20.h,),
                          Center(
                            child: Text("Precio en € (Dejar a 0 para Gratis)", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black, fontSize: ScreenUtil().setSp(13)),),
                          ),
                          SizedBox(height: 10.h,),
                          Center(
                            child: Container(
                              width: 150.w,
                              child: TextFormField(
                                onChanged: (value){
                                  setState(() {
                                    price = value;
                                    if(price == "")
                                      competition.price = 0.0;
                                    else
                                      competition.price = double.parse(price);
                                  });
                                },
                                //validator: (val) => val.length < 1 ? "Pon un precio" : null,
                                //validator: (val) => val.length < 1 ? "Pon un precio" : null,
                                keyboardType: TextInputType.number,
                                maxLength: 5,
                                decoration: textInputDeco.copyWith(hintText: "Precio", counterText: "",),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                SizedBox(height: 10.h,),
                Container(
                  width: 180.w,
                  child: loading? CircularLoading() : RawMaterialButton(
                      child: Text("CREAR", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white, fontSize: ScreenUtil().setSp(20),),),
                      fillColor: Color(0xff61b3d8),
                      shape: RoundedRectangleBorder(),
                      padding: EdgeInsets.only(right: 18.0.w, bottom: 18.0.h,top: 18.0.h,left: 18.w),
                      onPressed: ()async{
                        if(_formKey.currentState.validate()){
                          if(competition.timezone == null || competition.type == null || competition.locality == null ){
                            setState(() {
                              error = "Los campos de selección no pueden estar vacíos";
                            });
                          }
                          else{
                            setState(() {
                              error = "";
                              loading = true;
                              competition.organizer = user.username;
                            });
                            if(timeless){
                              competition.eventdate = null;
                              competition.enddate = null;
                              competition.maxdate = null;
                            }
                            competition.modality = "Carrera";
                            await DBService.dbService.createCompetition(competition, user.id);
                            await DBService.dbService.addToFavorites(user.id, competition.id);
                            user.favorites.add(competition);
                            if(!timeless) {
                              await DBService.dbService.enrrollCompetition(
                                  user.id, competition.id.toString());
                              user.enrolled.add(competition);
                              competition.numcompetitors = 1;
                            }
                            setState(() {
                              loading = false;

                              Alerts.toast("Competición creada!");
                              Navigator.pop(context);
                            });
                          }
                        }
                      }
                  ),
                ),
                SizedBox(height: 10.h,),
              ],),
            ),
          )
        ],),
      ),
    );
  }
}
