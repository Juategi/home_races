import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:homeraces/model/competition.dart';
import 'package:homeraces/model/user.dart';
import 'package:homeraces/screens/competition/edit_images.dart';
import 'package:homeraces/services/auth.dart';
import 'package:homeraces/services/dbservice.dart';
import 'package:homeraces/services/pool.dart';
import 'package:homeraces/services/storage.dart';
import 'package:homeraces/shared/alert.dart';
import 'package:homeraces/shared/common_data.dart';
import 'package:homeraces/shared/decos.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:homeraces/shared/loading.dart';
import 'package:intl/intl.dart';

class EditCompetition extends StatefulWidget {
  @override
  _EditCompetitionState createState() => _EditCompetitionState();
}

class _EditCompetitionState extends State<EditCompetition> {
  final StorageService _storageService = StorageService();
  final _formKey = GlobalKey<FormState>();
  final format = DateFormat("yyyy-MM-dd HH:mm");
  Competition newCompetition, oldCompetition;
  User user;
  String image, error, capacity, price, duration;
  bool disableCapacity, promote, loading, timeless, admin, enabled, init;

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
    for(String image in newCompetition.gallery){
      _storageService.removeFile(image);
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    loading = false;
    init = false;
    newCompetition = Competition();
    error = "";
  }

  @override
  Widget build(BuildContext context) {
    //loading = false;
    user = List<Object>.of(ModalRoute.of(context).settings.arguments).last;
    oldCompetition = List<Object>.of(ModalRoute.of(context).settings.arguments).first;
    if(oldCompetition.eventdate != null && oldCompetition.eventdate.isBefore(DateTime.now()))
      enabled = false;
    else
      enabled = true;
    if(!init){
      if(newCompetition.gallery == null){
        newCompetition.gallery = [];
        for(String image in oldCompetition.gallery){
          newCompetition.gallery.add(image);
        }
      }
      if(timeless == null){
        if(oldCompetition.eventdate == null)
          timeless = true;
        else
          timeless = false;
      }
      if(disableCapacity == null){
        if(oldCompetition.capacity == -1)
          disableCapacity = true;
        else
          disableCapacity = false;
      }
      if(promote == null){
        if(oldCompetition.promoted == 'P')
          promote = true;
        else
          promote = false;
      }
      newCompetition.promoted = oldCompetition.promoted;
      newCompetition.eventdate = oldCompetition.eventdate;
      newCompetition.enddate = oldCompetition.enddate;
      newCompetition.maxdate = oldCompetition.maxdate;
      newCompetition.image = oldCompetition.image;
      newCompetition.name = oldCompetition.name;
      newCompetition.id = oldCompetition.id;
      newCompetition.locality = oldCompetition.locality;
      newCompetition.type = oldCompetition.type;
      newCompetition.price = oldCompetition.price;
      newCompetition.observations = oldCompetition.observations;
      newCompetition.rewards = oldCompetition.rewards;
      newCompetition.capacity = oldCompetition.capacity;
      newCompetition.timezone = oldCompetition.timezone;
      newCompetition.distance = oldCompetition.distance;
      newCompetition.organizer = oldCompetition.organizer;
      newCompetition.organizerid = oldCompetition.organizerid;
      newCompetition.usersImages = oldCompetition.usersImages;
      newCompetition.numcompetitors = oldCompetition.numcompetitors;
      newCompetition.modality = oldCompetition.modality;
      init = true;
    }
    _admin();
    _timer();
    ScreenUtil.init(context, height: CommonData.screenHeight, width: CommonData.screenWidth, allowFontScaling: true);
    return WillPopScope(
      //onWillPop: _deleteImagesOnReturn,
      child: Scaffold(
        backgroundColor: enabled? Theme.of(context).scaffoldBackgroundColor: Colors.white,
        appBar:AppBar(
            elevation: 0,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            leading: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: Colors.black,),
                onPressed: (){
                  //_deleteImagesOnReturn();
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
                        onPressed: enabled? () async{
                          String aux = await _storageService.uploadImage(context, "competition");
                          if(aux != null){
                            setState(() {
                              image = aux;
                              newCompetition.image = image;
                            });
                          }
                        } : null,
                        padding: EdgeInsets.only(right: 0.w, bottom: 0.h,top: 0.h,left: 0.w),
                        child: Container(
                            constraints: BoxConstraints.expand(
                                height: 130.0.h,
                                width: 130.0.w
                            ),
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: newCompetition.image == null? CommonData.defaultImageCompetition.image : Image.network(newCompetition.image).image,
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
                          setState(() => newCompetition.name = value);
                        },
                        validator: (val) => val.length < 4 || val.length > 120 ? "Mínimo 4 carácteres y menos de 120" : null,
                        decoration: textInputDeco.copyWith(hintText: "Nombre de la competición"),
                        autofocus: false,
                        maxLength: 120,
                        initialValue: oldCompetition.name,
                        enabled: enabled,
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
                        initialValue: oldCompetition.eventdate,
                        enabled: enabled,
                        validator: (val) => !timeless && ( val == null || newCompetition.eventdate.isBefore(DateTime.now()) )? "Fecha del evento ha de ser en el futuro" : null,
                        onChanged: (date){
                          newCompetition.eventdate = date;
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
                        initialValue: oldCompetition.enddate,
                        enabled: enabled,
                        validator: (val) => !timeless && (val == null || newCompetition.enddate.isBefore(newCompetition.eventdate)) ? "Fin ha de ser posterior al inicio" : null,
                        onChanged: (date){
                          newCompetition.enddate = date;
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
                        validator: (val) => !timeless && (val == null || newCompetition.maxdate.isAfter(newCompetition.enddate)) ? "Fecha de inscripción ha de ser anterior a la de fin de evento" : null,
                        format: format,
                        initialValue: oldCompetition.maxdate,
                        enabled: enabled,
                        onChanged: (date){
                          newCompetition.maxdate = date;
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
                    enabled ? Padding(
                        padding: EdgeInsets.only(right: 240.w),
                        child: DropdownButton<String>(
                          items: <String>['Canarias', 'Península'].map((String value) {
                            return new DropdownMenuItem<String>(
                              value: value,
                              child: new Text(value),
                            );
                          }).toList(),
                          value: newCompetition.timezone ?? oldCompetition.timezone,
                          hint: Text("Selecciona"),
                          onChanged: (String tz) {
                            setState(() {
                              newCompetition.timezone = tz;
                            });
                            if(newCompetition.timezone != null && newCompetition.type != null &&
                                newCompetition.modality != null && newCompetition.locality != null){
                              setState(() {
                                error = "";
                              });
                            }
                          },
                        )
                      ): Text(oldCompetition.timezone, style: TextStyle(fontWeight: FontWeight.normal ,color: Colors.black, fontSize: ScreenUtil().setSp(20)),),
                      SizedBox(height: 20.h,),
                      Padding(
                        padding: EdgeInsets.only(right: 255.w),
                        child: Text("Tipo de evento", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black, fontSize: ScreenUtil().setSp(13)),),
                      ),
                      SizedBox(height: 10.h,),
                      enabled? Padding(
                        padding: EdgeInsets.only(right: 170.w),
                        child: DropdownButton<String>(
                          items: <String>['Publico','Privado'].map((String value) {
                            return new DropdownMenuItem<String>(
                              value: value,
                              child: new Text(value),
                            );
                          }).toList(),
                          value: newCompetition.type ?? oldCompetition.type,
                          isExpanded: true,
                          hint: Text("Selecciona"),
                          onChanged: (String type) {
                            setState(() {
                              newCompetition.type = type;
                            });
                            if(newCompetition.timezone != null && newCompetition.type != null &&
                                newCompetition.modality != null && newCompetition.locality != null){
                              setState(() {
                                error = "";
                              });
                            }
                          },
                        )
                      ): Text(oldCompetition.type, style: TextStyle(fontWeight: FontWeight.normal ,color: Colors.black, fontSize: ScreenUtil().setSp(20)),),
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
                      enabled? Padding(
                        padding: EdgeInsets.only(right: 170.w),
                        child: DropdownButton<String>(
                          items: <String>['Internacional','España', 'Comunidad autónoma', 'Provincia', 'Municipio'].map((String value) {
                            return new DropdownMenuItem<String>(
                              value: value,
                              child: new Text(value),
                            );
                          }).toList(),
                          value: newCompetition.locality ?? oldCompetition.locality,
                          isExpanded: true,
                          hint: Text("Selecciona"),
                          onChanged: (String locality) {
                            setState(() {
                              newCompetition.locality = locality;
                            });
                          },
                        )
                      ): Text(oldCompetition.locality, style: TextStyle(fontWeight: FontWeight.normal ,color: Colors.black, fontSize: ScreenUtil().setSp(20)),),
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
                                  newCompetition.distance = 0;
                                else
                                  newCompetition.distance = double.parse(price).toInt();
                              });
                            },
                            validator: (val) => val.length < 1 || val.contains(".") || val.contains(",")  ? "Sin decimales" : null,
                            keyboardType: TextInputType.numberWithOptions(decimal: false, signed: false),
                            maxLength: 5,
                            decoration: textInputDeco.copyWith(hintText: "Distancia en km", counterText: "",),
                            initialValue: oldCompetition.distance.toString(),
                            enabled: enabled,
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
                        child: Text("Aforo, número máximo de participantes", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black, fontSize: ScreenUtil().setSp(13)),),
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
                                    newCompetition.capacity = 0;
                                  else
                                    newCompetition.capacity = int.parse(capacity);
                                });
                              },
                              keyboardType: TextInputType.number,
                              enabled: !disableCapacity && enabled,
                              autofocus: false,
                              maxLength: 6,
                              validator: (val) => val.isEmpty && !disableCapacity ? "No puede estar vacío" : null,
                              decoration: textInputDeco.copyWith(hintText: "Aforo", counterText: "",),
                              initialValue: oldCompetition.capacity != -1? oldCompetition.capacity.toString() : "",
                            ),
                          ),
                          enabled ? Container(
                            width: 180.w,
                            child: CheckboxListTile(
                              title: Text("Sin límite", style: TextStyle(fontWeight: FontWeight.normal ,color: Colors.black, fontSize: ScreenUtil().setSp(15)),),
                              value: disableCapacity,
                              onChanged: (newValue) {
                                setState(() {
                                  disableCapacity = newValue;
                                  if(newValue)
                                    newCompetition.capacity = -1;
                                  else if(capacity == null){
                                    newCompetition.capacity = null;
                                  }
                                  else if(capacity == "")
                                    newCompetition.capacity = 0;
                                  else
                                    newCompetition.capacity = int.parse(capacity);

                                });
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                            ),
                          ): Container()
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
                          setState(() => newCompetition.rewards = value);
                        },
                        //validator: (val) => val.length < 15 || val.length > 199 ? "Describe el premio con 15-200 carácteres" : null,
                        decoration: textInputDeco.copyWith(hintText: "Premios de la competición"),
                        maxLength: 100,
                        initialValue: oldCompetition.rewards,
                        enabled: enabled,
                      ),
                      SizedBox(height: 20.h,),
                      Padding(
                        padding: EdgeInsets.only(right: 267.w),
                        child: Text("Descripción", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black, fontSize: ScreenUtil().setSp(13)),),
                      ),
                      SizedBox(height: 10.h,),
                      TextFormField(
                        onChanged: (value){
                          setState(() => newCompetition.observations = value);
                        },
                        validator: (val) => val.length < 15 || val.length > 100 ? "Describe las observaciones con 15-100 carácteres" : null,
                        decoration: textInputDeco.copyWith(hintText: "Observaciones, al menos 15 carácteres"),
                        maxLength: 200,
                        initialValue: oldCompetition.observations,
                        enabled: enabled,
                      ),
                      SizedBox(height: 10.h,),
                      Padding(
                        padding: EdgeInsets.only(right: 267.w),
                        child: Text("Imágenes", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black, fontSize: ScreenUtil().setSp(13)),),
                      ),
                      SizedBox(height: 10.h,),
                      Container(
                        height: (300).h,
                        child: enabled? EditImages(competition: newCompetition,) :
                            GridView.count(
                              crossAxisCount: 3,
                                children: oldCompetition.gallery.map((image) => GridTile(
                                  child: Container(
                                      constraints: BoxConstraints.expand(
                                          height: 90.h,
                                          width: 90.w
                                      ),
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: Image.network(image).image,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                  ),
                                )).toList()
                              ,)
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
                                    newCompetition.promoted = 'P';
                                  else
                                    newCompetition.promoted = 'N';
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
                                      newCompetition.price = 0.0;
                                    else
                                      newCompetition.price = double.parse(price);
                                  });
                                },
                                //validator: (val) => val.length < 1 ? "Pon un precio" : null,
                                //validator: (val) => val.length < 1 ? "Pon un precio" : null,
                                keyboardType: TextInputType.number,
                                maxLength: 5,
                                decoration: textInputDeco.copyWith(hintText: "Precio", counterText: "",),
                                initialValue: oldCompetition.price.toString(),
                                enabled: enabled,
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
                      child: Text("ACTUALIZAR", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white, fontSize: ScreenUtil().setSp(20),),),
                      fillColor: Color(0xff61b3d8),
                      shape: RoundedRectangleBorder(),
                      padding: EdgeInsets.only(right: 18.0.w, bottom: 18.0.h,top: 18.0.h,left: 18.w),
                      onPressed: ()async{
                        if(_formKey.currentState.validate()){
                          if(newCompetition.timezone == null || newCompetition.type == null || newCompetition.locality == null ){
                            setState(() {
                              print(newCompetition.distance);
                              error = "Los campos de selección no pueden estar vacíos";
                            });
                          }
                          else{
                            setState(() {
                              error = "";
                              loading = true;
                              newCompetition.organizer = user.username;
                            });
                            if(timeless){
                              newCompetition.eventdate = null;
                              newCompetition.enddate = null;
                              newCompetition.maxdate = null;
                            }
                            oldCompetition = newCompetition;
                            await DBService.dbService.updateCompetition(oldCompetition);
                            setState(() {
                              loading = false;
                              Alerts.toast("Competición ACTUALIZADA!");
                              AuthService().reBirth(context);
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
