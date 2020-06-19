import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:homeraces/model/competition.dart';
import 'package:homeraces/model/user.dart';
import 'package:homeraces/services/dbservice.dart';
import 'package:homeraces/services/storage.dart';
import 'package:homeraces/shared/common_data.dart';
import 'package:homeraces/shared/decos.dart';
import 'package:homeraces/shared/functions.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


class CreateCompetition extends StatefulWidget {
  @override
  _CreateCompetitionState createState() => _CreateCompetitionState();
}

class _CreateCompetitionState extends State<CreateCompetition> {
  final DBService _dbService = DBService();
  final StorageService _storageService = StorageService();
  final _formKey = GlobalKey<FormState>();
  final format = DateFormat("yyyy-MM-dd HH:mm");
  Competition competition;
  User user;
  String image, error, capacity, price, duration;
  bool disableCapacity, promote;

  @override
  void initState() {
    disableCapacity = false;
    promote = false;
    competition = Competition();
    competition.promoted = 'N';
    competition.image = CommonData.defaultCompetition;
    competition.rewards = " ";
    error = "";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String image = CommonData.defaultCompetition;
    user = ModalRoute.of(context).settings.arguments;
    ScreenUtil.init(context, height: CommonData.screenHeight, width: CommonData.screenWidth, allowFontScaling: true);
    return Scaffold(
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
                      padding: EdgeInsets.all(0.0),
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
                      padding: const EdgeInsets.only(right: 230),
                      child: Text("Nombre del evento", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black, fontSize: ScreenUtil().setSp(13)),),
                    ),
                    SizedBox(height: 8.h,),
                    TextFormField(
                      onChanged: (value){
                        setState(() => competition.name = value);
                      },
                      validator: (val) => val.length < 4 || val.length > 120 ? "Mínimo 4 carácteres y menos de 120" : null,
                      decoration: textInputDeco.copyWith(hintText: "Nombre de la competición"),
                    ),
                    SizedBox(height: 20.h,),
                    Padding(
                      padding: const EdgeInsets.only(right: 202),
                      child: Text("Fecha y hora del evento", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black, fontSize: ScreenUtil().setSp(13)),),
                    ),
                    SizedBox(height: 10.h,),
                    DateTimeField(
                      decoration: textInputDeco.copyWith(hintText: "Fecha de la competición"),
                      format: format,
                      validator: (val) => val == null || competition.eventdate.isBefore(DateTime.now()) ? "Fecha del evento ha de ser en el futuro" : null,
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
                      padding: const EdgeInsets.only(right: 130),
                      child: Text("Fecha y hora máxima de inscripción", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black, fontSize: ScreenUtil().setSp(13)),),
                    ),
                    SizedBox(height: 10.h,),
                    DateTimeField(
                      decoration: textInputDeco.copyWith(hintText: "Fecha de inscripción"),
                      validator: (val) => val == null || competition.maxdate.isAfter(competition.eventdate) ? "Fecha de inscripción ha de ser anterior a la del evento" : null,
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
                      padding: const EdgeInsets.only(right: 265),
                      child: Text("Zona horaria", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black, fontSize: ScreenUtil().setSp(13)),),
                    ),
                    SizedBox(height: 10.h,),
                    Padding(
                      padding: const EdgeInsets.only(right: 240),
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
                      padding: const EdgeInsets.only(right: 255),
                      child: Text("Tipo de evento", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black, fontSize: ScreenUtil().setSp(13)),),
                    ),
                    SizedBox(height: 10.h,),
                    Padding(
                      padding: const EdgeInsets.only(right: 170),
                      child: DropdownButton<String>(
                        items: <String>['Público','Privado'].map((String value) {
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
                    SizedBox(height: 20.h,),
                    Padding(
                      padding: const EdgeInsets.only(right: 280),
                      child: Text("Modalidad", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black, fontSize: ScreenUtil().setSp(13)),),
                    ),
                    SizedBox(height: 10.h,),
                    Padding(
                      padding: const EdgeInsets.only(right: 170),
                      child: DropdownButton<String>(
                        items: <String>['Carrera','Fitness', 'Bicicleta'].map((String value) {
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
                    ),
                    SizedBox(height: 20.h,),
                    Padding(
                      padding: const EdgeInsets.only(right: 300),
                      child: Text("Región", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black, fontSize: ScreenUtil().setSp(13)),),
                    ),
                    SizedBox(height: 10.h,),
                    Padding(
                      padding: const EdgeInsets.only(right: 170),
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
                          if(competition.timezone != null && competition.type != null &&
                              competition.modality != null && competition.locality != null){
                            setState(() {
                              error = "";
                            });
                          }
                        },
                      ),
                    ),
                    SizedBox(height: 2.h,),
                    Padding(
                      padding: const EdgeInsets.only(right: 73),
                      child: Text(error, style: TextStyle(color: Colors.red[700], fontSize: ScreenUtil().setSp(12)),),
                    ),
                    SizedBox(height: 20.h,),
                    Padding(
                      padding: const EdgeInsets.only(right: 300),
                      child: Text("Aforo", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black, fontSize: ScreenUtil().setSp(13)),),
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
                            autofocus: true,
                            validator: (val) => val.isEmpty && !disableCapacity ? "No puede estar vacío" : null,
                            decoration: textInputDeco.copyWith(hintText: "Aforo"),
                          ),
                        ),
                        Container(
                          width: 180.w,
                          child: CheckboxListTile(
                            title: Text("Sin límite"),
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
                      padding: const EdgeInsets.only(right: 140),
                      child: Text("Precio en € (Dejar a 0 para Gratis)", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black, fontSize: ScreenUtil().setSp(13)),),
                    ),
                    SizedBox(height: 10.h,),
                    Padding(
                      padding: const EdgeInsets.only(right: 190),
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
                          validator: (val) => val.length < 1 ? "Pon un precio" : null,
                          keyboardType: TextInputType.number,
                          decoration: textInputDeco.copyWith(hintText: "Precio"),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h,),
                    Padding(
                      padding: const EdgeInsets.only(right: 220),
                      child: Text("Duración en minutos", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black, fontSize: ScreenUtil().setSp(13)),),
                    ),
                    SizedBox(height: 10.h,),
                    Padding(
                      padding: const EdgeInsets.only(right: 190),
                      child: Container(
                        width: 150.w,
                        child: TextFormField(
                          onChanged: (value){
                            setState(() {
                              duration = value;
                              if(duration == "")
                                competition.duration = 0;
                              else
                                competition.duration = int.parse(duration);
                            });
                          },
                          validator: (val) => val.length < 1 ? "Pon una duración" : null,
                          keyboardType: TextInputType.number,
                          decoration: textInputDeco.copyWith(hintText: "Duración"),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h,),
                    Padding(
                      padding: const EdgeInsets.only(right: 290),
                      child: Text("Premios", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black, fontSize: ScreenUtil().setSp(13)),),
                    ),
                    SizedBox(height: 10.h,),
                    TextFormField(
                      onChanged: (value){
                        setState(() => competition.rewards = value);
                      },
                      //validator: (val) => val.length < 15 || val.length > 199 ? "Describe el premio con 15-200 carácteres" : null,
                      decoration: textInputDeco.copyWith(hintText: "Premios de la competición"),
                    ),
                    SizedBox(height: 20.h,),
                    Padding(
                      padding: const EdgeInsets.only(right: 252),
                      child: Text("Descripción", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black, fontSize: ScreenUtil().setSp(13)),),
                    ),
                    SizedBox(height: 10.h,),
                    TextFormField(
                      onChanged: (value){
                        setState(() => competition.observations = value);
                      },
                      validator: (val) => val.length < 15 || val.length > 199 ? "Describe las observaciones con 15-200 carácteres" : null,
                      decoration: textInputDeco.copyWith(hintText: "Observaciones"),
                    ),
                    SizedBox(height: 20.h,),
                    Container(
                      width: 180.w,
                      child: CheckboxListTile(
                        title: Text("Promocionar"),
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
                    )
                  ],
                ),
              ),
              SizedBox(height: 10.h,),
              Container(
                width: 180.w,
                child: RawMaterialButton(
                    child: Text("CREAR", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white, fontSize: ScreenUtil().setSp(20),),),
                    fillColor: Color(0xff61b3d8),
                    shape: RoundedRectangleBorder(),
                    padding: EdgeInsets.all(18.0),
                    onPressed: ()async{
                      if(_formKey.currentState.validate()){
                        if(competition.timezone == null || competition.type == null || competition.modality == null || competition.locality == null){
                          setState(() {
                            error = "Los campos de selección no pueden estar vacíos";
                          });
                        }
                        else{
                          setState(() {
                            error = "";
                          });
                          competition.organizer = user.id;
                          DBService().createCompetition(competition);
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
    );
  }
}
