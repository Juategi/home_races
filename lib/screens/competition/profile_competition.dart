import 'package:flutter/material.dart';
import 'package:flutter_material_pickers/flutter_material_pickers.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:homeraces/model/comment.dart';
import 'package:homeraces/model/competition.dart';
import 'package:homeraces/model/user.dart';
import 'package:homeraces/screens/competition/comments/comment_box.dart';
import 'package:homeraces/services/dbservice.dart';
import 'package:homeraces/shared/alert.dart';
import 'package:homeraces/shared/common_data.dart';
import 'package:homeraces/shared/functions.dart';
import 'package:homeraces/shared/loading.dart';
import 'package:location_permissions/location_permissions.dart';

class CompetitionProfile extends StatefulWidget {
  @override
  _CompetitionProfileState createState() => _CompetitionProfileState();
}
class ImageDialog extends StatelessWidget {
  ImageDialog({this.url});
  String url;
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 200.w,
        height: 200.h,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: Image.network(url).image,
                fit: BoxFit.cover
            )
        ),
        child: Stack(
          children: <Widget>[
            Positioned(
              left: 230.w,
              bottom: 160.h,
              child: IconButton(
                icon: Icon(Icons.cancel, color: Colors.red, size: ScreenUtil().setSp(40),),
                onPressed: () => Navigator.pop(context),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _CompetitionProfileState extends State<CompetitionProfile> {
  final TextEditingController _commentController = new TextEditingController();
  Competition competition;
  Comment comment;
  List<CommentBox> boxes;
  Map<String, String> allowed;
  User user;
  bool loading, init, loadingButton;

  List<Widget> _initGallery() {
    return competition.gallery.map((String url) {
      return GridTile(
          child: FlatButton(
            onPressed: ()async{
              await showDialog(
                  context: context,
                  builder: (_) => ImageDialog(url: url,)
              );
            },
            padding: EdgeInsets.all(0.0),
            child: Container(
                constraints: BoxConstraints.expand(
                    height: 90.h,
                    width: 90.w
                ),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: Image
                        .network(url)
                        .image,
                    fit: BoxFit.cover,
                  ),
                ),
            ),
          )
      );
    }).toList();
  }

  void _timer() {
    if(competition.comments == null || competition.usersImages == null) {
      Future.delayed(Duration(seconds: 2)).then((_) {
        setState(() {
          print("Loading...");
        });
        _timer();
      });
    }
  }

  void _loadUsers() async{
    competition.usersImages = await DBService.dbService.getCompetitorsImage(competition.id.toString());
  }

  void _loadRace() async{
    competition.hasRace = await DBService.dbService.checkRaceDataUser(competition.id.toString(), user.id);
  }

  void _loadComments()async{
    competition.comments = await DBService.dbService.getParentComments(competition.id);
  }

  void _loadAllowed()async{
    setState(() {
      loadingButton = true;
    });
    allowed = await DBService.dbService.getPrivate(competition.id.toString());
    setState(() {
      loadingButton = false;
    });
  }

  @override
  void dispose() {
    competition.comments = null;
    super.dispose();
  }

  @override
  void initState() {
    boxes = List<CommentBox>();
    comment = Comment();
    loading = false;
    loadingButton = false;
    init = false;
    //competition.hasRace = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var args = List<Object>.of(ModalRoute.of(context).settings.arguments);
    competition = args.first;
    user = args.last;
    if(competition.hasRace == null)
      _loadRace();
    if(competition.usersImages == null)
      _loadUsers();
    boxes.clear();
    if(competition.type == "Privado" && allowed == null)
      _loadAllowed();
    if(competition.comments == null)
      _loadComments();
    else {
      init = true;
      for (Comment comment in competition.comments) {
        boxes.add(new CommentBox(comment: comment));
      }
    }
    boxes.sort((c1,c2){
      return c2.comment.id.compareTo(c1.comment.id);
    });
    _timer();
    ScreenUtil.init(context, height: CommonData.screenHeight, width: CommonData.screenWidth, allowFontScaling: true);
    return Scaffold(backgroundColor: Colors.white, appBar:
      AppBar(
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black,),
          onPressed: () => Navigator.pop(context),
        ),
        actions: <Widget>[
          IconButton(
            icon: user.favorites.contains(competition) ? Icon(Icons.star, size: ScreenUtil().setSp(35), color: Colors.yellow,) :
            Icon(Icons.star_border, size: ScreenUtil().setSp(35), color: Colors.grey[350],),
            onPressed: (){
              setState(() {
                if(user.favorites.contains(competition)){
                  user.favorites.remove(competition);
                  DBService.dbService.deleteFromFavorites(user.id, competition.id);
                }
                else{
                  user.favorites.add(competition);
                  DBService.dbService.addToFavorites(user.id, competition.id);
                }
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.share),
          ),
          SizedBox(width: 10.w)
        ],
        backgroundColor: Colors.white,
      ),

      body: ListView(children: <Widget>[
        Container(
          height: 137.h,
          child: Stack(
            children: <Widget>[
            Positioned(
                left: 20.w,
                top: 10.h,
                child: Image.network(competition.image, height: 120.h, width: 120.w,)
            ),
            Positioned(
                left: 155.w,
                top: 12.h,
                child: Text(competition.name.toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: ScreenUtil().setSp(18)),)
            ),
            Positioned(
              left: 155.w,
              top: 35.h,
              child: competition.eventdate == null? Container(height: 0,) : Container(
                height: 300.h,
                width: 250.w,
                child: Column(
                  children: <Widget>[
                    Divider(thickness: 1,),
                    SizedBox(height: 3.h,),
                    Row(
                      children: <Widget>[
                        SizedBox(width: 7.w,),
                        Text("Comienza:", style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(12)),),
                        SizedBox(width: 15.w,),
                        Container(
                          height: 15.h,
                          width: 15.w,
                          child: SvgPicture.asset(
                            "assets/icons/Calendario-competición.svg",
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: 7.w,),
                        Text(Functions.parseDate(competition.eventdate, false), style: TextStyle(fontWeight: FontWeight.bold, fontSize: ScreenUtil().setSp(13), color: const Color(0xff61b3d8)),),
                        SizedBox(width: 10.w,),
                        Icon(Icons.access_time, size: ScreenUtil().setSp(16),),
                        SizedBox(width: 7.w,),
                        Text(Functions.parseTime(competition.eventdate), style: TextStyle(fontWeight: FontWeight.bold, fontSize: ScreenUtil().setSp(13), color: const Color(0xff61b3d8)),),
                      ],
                    ),
                    SizedBox(height: 3.h,),
                    Divider(thickness: 1,),
                    SizedBox(height: 3.h,),
                    Row(
                      children: <Widget>[
                        SizedBox(width: 7.w,),
                        Text("Finaliza:", style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(12)),),
                        SizedBox(width: 28.w,),
                        Container(
                          height: 15.h,
                          width: 15.w,
                          child: SvgPicture.asset(
                            "assets/icons/Calendario-competición.svg",
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: 7.w,),
                        Text(Functions.parseDate(competition.enddate, false), style: TextStyle(fontWeight: FontWeight.bold, fontSize: ScreenUtil().setSp(13), color: const Color(0xff61b3d8)),),
                        SizedBox(width: 10.w,),
                        Icon(Icons.access_time, size: ScreenUtil().setSp(16),),
                        SizedBox(width: 7.w,),
                        Text(Functions.parseTime(competition.enddate), style: TextStyle(fontWeight: FontWeight.bold, fontSize: ScreenUtil().setSp(13), color: const Color(0xff61b3d8)),),
                      ],
                    ),
                    SizedBox(height: 3.h,),
                    Divider(thickness: 1,),
                  ],
                ),
              ),
            )

          ],),
        ),
        SizedBox(height: 15.h,),
        Padding(
          padding: EdgeInsets.only(left: 20.w),
          child: Column(children: <Widget>[
            Row(children: <Widget>[
              Icon(Icons.location_on, size: ScreenUtil().setSp(20),),
              SizedBox(width: 20.w,),
              Text("${competition.modality}  -  ${competition.locality}", style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(18), color: Colors.black),),
            ],)
          ],),
        ),
        SizedBox(height: 20.h,),
        Padding(
          padding: EdgeInsets.only(left: 22.w),
          child: Column(children: <Widget>[
            Row(children: <Widget>[
              Container(
                height: 17.h,
                width: 17.w,
                child: SvgPicture.asset(
                  "assets/icons/Candado-competición.svg",
                  color: Colors.black,
                ),
              ),
              SizedBox(width: 20.w,),
              Text("Competición:  ", style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(12), color: Colors.black),),
              Text(competition.promoted == 'P'? "Oficial" : competition.type == "Public"? "Pública": "Privada", style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(16), color: Colors.black),),
            ],)
          ],),
        ),
        SizedBox(height: 20.h,),
        Padding(
          padding: EdgeInsets.only(left: 22.w),
          child: Column(children: <Widget>[
            Row(children: <Widget>[
              Container(
                height: 17.h,
                width: 17.w,
                child: SvgPicture.asset(
                  "assets/icons/Personal.svg",
                  color: Colors.black,
                ),
              ),
              SizedBox(width: 20.w,),
              Text("Organizado por:  ", style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(12), color: Colors.black),),
              Text(competition.organizer ?? "", style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(16), color: Colors.black),),
            ],)
          ],),
        ),
        SizedBox(height: 40.h,),
        Padding(
          padding: EdgeInsets.only(left: 23.w),
          child: Column(children: <Widget>[
            Row(children: <Widget>[
              Container(
                height: 17.h,
                width: 17.w,
                child: SvgPicture.asset(
                  "assets/icons/Aforo-competición.svg",
                  color: Colors.black,
                ),
              ),
              SizedBox(width: 20.w,),
              Text("Aforo:  ", style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(12), color: Colors.black),),
              Text(competition.capacity == -1? "Sin límite" : competition.capacity.toString(), style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(16), color: Colors.black),),
            ],)
          ],),
        ),
        SizedBox(height: 10.h,),
        Padding(
          padding: EdgeInsets.only(left: 60.w),
          child: Column(children: <Widget>[
            Row(children: <Widget>[
              Text("Inscritos:  ", style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(12), color: Colors.black),),
              Text(competition.numcompetitors == 1? "${competition.numcompetitors} participante" :
              "${competition.numcompetitors} participantes", style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(16), color: const Color(0xff61b3d8)),),
            ],)
          ],),
        ),
        SizedBox(height: 10.h,),
        competition.usersImages == null ? CircularLoading() : Padding(
          padding: EdgeInsets.only(left: 60.w),
          child: Column(children: <Widget>[
            Row(children: competition.usersImages.length == 0 ?
                  [Container(
                  margin: EdgeInsets.only(right: 5.w),
                    height: 35.h,
                    width: 35.w,
                    decoration: new BoxDecoration(
                        shape: BoxShape.circle,
                        image: new DecorationImage(
                            fit: BoxFit.fill,
                            image: new NetworkImage(CommonData.defaultProfile)
                        )
                    )
                )]
                : competition.usersImages.map((image){
                return Container(
                    margin: EdgeInsets.only(right: 5.w),
                    height: 35.h,
                    width: 35.w,
                    decoration: new BoxDecoration(
                        shape: BoxShape.circle,
                        image: new DecorationImage(
                            fit: BoxFit.fill,
                            image: new NetworkImage(image == "null" || image == null ? CommonData.defaultProfile:image)
                        )
                    )
                );
              }).toList(),
            ),
          ],),
        ),
        Padding(
          padding: EdgeInsets.only(right: 18.0.w, left: 18.0.w, top: 6.h, bottom: 6.h),
          child: Divider(thickness: 1,),
        ),
        competition.gallery.length == 0? Container(height: 0,): Padding(
          padding: EdgeInsets.only(left: 20.w),
          child: Column(children: <Widget>[
            Row(children: <Widget>[
              FaIcon(FontAwesomeIcons.images, size: ScreenUtil().setSp(17),),
              SizedBox(width: 20.w,),
              Text("Galería:  ", style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(12), color: Colors.black),),
            ],)
          ],),
        ),
        SizedBox(height: 15.h,),
        competition.gallery.length == 0? Container(height: 0,):Container(
          margin: EdgeInsets.all(30),
          height: (130*competition.gallery.length/3.0).h,
          child: GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            childAspectRatio: 1.0,
            mainAxisSpacing: 8.0,
            crossAxisSpacing: 8.0,
            children: _initGallery(),
          ),
        ),
        SizedBox(height: 15.h,),
        Padding(
          padding: EdgeInsets.only(left: 22.w),
          child: Column(children: <Widget>[
            Row(children: <Widget>[
              Container(
                height: 17.h,
                width: 17.w,
                child: SvgPicture.asset(
                  "assets/icons/Premios-competición.svg",
                  color: Colors.black,
                ),
              ),
              SizedBox(width: 20.w,),
              Text("Premios:  ", style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(12), color: Colors.black),),
            ],)
          ],),
        ),
        SizedBox(height: 10.h,),
        Padding(
          padding: EdgeInsets.only(left: 60.w),
          child: Container(
            width: 150.w,
              child: Text(competition.rewards, style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(16), color: Colors.black),)
          ),
        ),
        SizedBox(height: 10.h,),
        Padding(
          padding: EdgeInsets.only(left: 22.w),
          child: Column(children: <Widget>[
            Row(children: <Widget>[
              FaIcon(FontAwesomeIcons.pen, size: ScreenUtil().setSp(14),),
              SizedBox(width: 20.w,),
              Text("Observaciones:  ", style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(12), color: Colors.black),),
            ],)
          ],),
        ),
        SizedBox(height: 10.h,),
        Padding(
          padding: EdgeInsets.only(left: 60.w),
          child: Container(
              width: 150.w,
              child: Text(competition.observations, style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(16), color: Colors.black),)
          ),
        ),
        SizedBox(height: 30.h,),
        Padding(
          padding: EdgeInsets.only(left: 20.w),
          child: Text("Comentarios: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: ScreenUtil().setSp(16), color: Colors.black),),
        ),
        SizedBox(height: 10.h,),
        Padding(
          padding: EdgeInsets.only(left: 20.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
            Container(
                height: 35.h,
                width: 35.w,
                decoration: new BoxDecoration(
                    shape: BoxShape.circle,
                    image: new DecorationImage(
                        fit: BoxFit.fill,
                        image: new NetworkImage(user.image)
                    )
                )
            ),
            SizedBox(width: 20.w,),
            Flexible(
              child: Container(
                width: 285.w,
                child: TextField(
                  controller: _commentController,
                  maxLength: 200,
                  maxLines: 9,
                  minLines: 1,
                  decoration: InputDecoration(
                    hintText: "Añadir comentario público",
                    fillColor: Colors.grey[100],
                    filled: true,
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey[200], width: 1)
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: const Color(0xff61b3d8), width: 2)
                    ),
                  ),
                  onChanged: (c){
                    comment.comment = c;
                  },
                ),
              ),
            ),
            loading? CircularLoading() :
            IconButton(icon: Icon(Icons.send),
              onPressed: ()async{
                setState(() {
                  loading = true;
                });
                FocusScope.of(context).unfocus();
                _commentController.clear();
                comment.userid = user.id;
                comment.competitionid = competition.id;
                comment.image = user.image;
                await DBService.dbService.postComment(comment);
                setState(() {
                  competition.comments = null;
                  loading = false;
                });
                comment = Comment();
              },
            )
          ],),
        ),
        SizedBox(height: 20.h,),
        competition.comments == null? CircularLoading() :
        Column(children: boxes)
      ],),

      bottomNavigationBar: BottomAppBar(
        child: loadingButton?
        CircularLoading() :
          Container(
            height: 80,
            child: _bottomBarInit()
          )
      )
    );
  }

  Widget _bottomBarInit(){

    //si es sin fechas y no está inscrito
    if(competition.eventdate == null && !user.enrolled.contains(competition))
      return Column(
        children: <Widget>[
          SizedBox(height: 5.h,),
          Row(
            children: <Widget>[
              SizedBox(width: 20.h,),
              Expanded(
                child: RawMaterialButton(
                  child: Text(competition.price == 0.0? "Inscribirse" : "Inscribirse (${competition.price}€)", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white, fontSize: ScreenUtil().setSp(20),),),
                  fillColor: Color(0xff61b3d8),
                  shape: StadiumBorder(),
                  elevation: 0,
                  padding: EdgeInsets.only(right: 18.0.w, bottom: 18.0.h,top: 18.0.h,left: 18.w),
                  onPressed: () async{
                    dynamic result;
                    if(competition.price != 0.0){
                      result = await Navigator.pushNamed(context, "/payment", arguments: competition);
                    }
                    else{
                      result = "Ok";
                    }
                    if(result.toString() == "Ok"){
                      setState(() {
                        loadingButton = true;
                      });
                      String result = await DBService.dbService.enrrollCompetition(user.id, competition.id.toString());
                      if(result == "Ok") {
                        user.enrolled.add(competition);
                        competition.numcompetitors ++;
                        competition.hasRace = false;
                        Alerts.toast("Inscrito!");
                      }
                      setState(() {
                        loadingButton = false;
                      });
                    }
                  },
                ),
              ),
              SizedBox(width: 20.h,),
            ],
          ),
        ],
      );

    //si es sin fechas y está inscrito
    if(competition.eventdate == null && user.enrolled.contains(competition))
      return Column(
        children: <Widget>[
          SizedBox(height: 5.h,),
          Row(
            children: <Widget>[
              SizedBox(width: 20.h,),
              Expanded(
                child: RawMaterialButton(
                  child: Text("Entrar", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white, fontSize: ScreenUtil().setSp(20),),),
                  fillColor: Color(0xff61b3d8),
                  shape: StadiumBorder(),
                  elevation: 0,
                  padding: EdgeInsets.only(right: 18.0.w, bottom: 18.0.h,top: 18.0.h,left: 18.w),
                  onPressed: () {
                    String selected = '5';
                    List<String> distances = <String>[
                      '5','10','21','42'
                    ];
                    showMaterialScrollPicker(
                        context: context,
                        title: "Elige la distancia en km",
                        items: distances,
                        selectedItem: selected,
                        confirmText: "Aceptar",
                        cancelText: "Cancelar",
                        onChanged: (value) => setState(() => selected = value),
                        onConfirmed: ()async{
                          competition.distance = int.parse(selected);
                          PermissionStatus permission = await LocationPermissions().requestPermissions();
                          if(permission == PermissionStatus.granted) {
                            dynamic s = await Navigator.pushNamed(
                                context, "/race", arguments: [user, competition]);
                            setState(() {
                              if(s == "Ok")
                                competition.hasRace = true;
                            });
                          }
                        }
                    );
                  },
                ),
              ),
              SizedBox(width: 20.h,),
            ],
          ),
        ],
      );

    //si es oficial y no está inscrito
    if(competition.promoted == 'P' && !user.enrolled.contains(competition) && competition.maxdate.isAfter(DateTime.now()))
      return Column(
        children: <Widget>[
          SizedBox(height: 5.h,),
          Row(
            children: <Widget>[
              SizedBox(width: 20.h,),
              Expanded(
                child: RawMaterialButton(
                  child: Text(competition.price == 0.0? "Inscribirse" : "Inscribirse (${competition.price}€)", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white, fontSize: ScreenUtil().setSp(20),),),
                  fillColor: Color(0xff61b3d8),
                  shape: StadiumBorder(),
                  elevation: 0,
                  padding: EdgeInsets.only(right: 18.0.w, bottom: 18.0.h,top: 18.0.h,left: 18.w),
                  onPressed: () async{
                    dynamic result;
                    if(competition.price != 0.0){
                      result = await Navigator.pushNamed(context, "/payment", arguments: competition);
                    }
                    else{
                      result = "Ok";
                    }
                    if(result.toString() == "Ok") {
                      setState(() {
                        loadingButton = true;
                      });
                      String result = await DBService.dbService
                          .enrrollCompetition(user.id, competition.id.toString());
                      if (result == "Ok") {
                        user.enrolled.add(competition);
                        competition.numcompetitors ++;
                        competition.hasRace = false;
                        Alerts.toast("Inscrito!");
                      }
                      setState(() {
                        loadingButton = false;
                      });
                    }
                  },
                ),
              ),
              SizedBox(width: 20.h,),
            ],
          ),
        ],
      );

    //si es oficial y está inscrito y no ha competido
    if(competition.promoted == 'P' && user.enrolled.contains(competition) && !competition.hasRace && competition.enddate.isAfter(DateTime.now()))
      return Column(
        children: <Widget>[
          SizedBox(height: 5.h,),
          Row(
            children: <Widget>[
              SizedBox(width: 20.h,),
              Expanded(
                child: RawMaterialButton(
                  child: Text("Entrar", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white, fontSize: ScreenUtil().setSp(20),),),
                  fillColor: Color(0xff61b3d8),
                  shape: StadiumBorder(),
                  elevation: 0,
                  padding: EdgeInsets.only(right: 18.0.w, bottom: 18.0.h,top: 18.0.h,left: 18.w),
                  onPressed: (){
                    String selected = '5';
                    List<String> distances = <String>[
                      '5','10','21','42'
                    ];
                    showMaterialScrollPicker(
                      context: context,
                      title: "Elige la distancia en km",
                      items: distances,
                      selectedItem: selected,
                      confirmText: "Aceptar",
                      cancelText: "Cancelar",
                      onChanged: (value) => setState(() => selected = value),
                      onConfirmed: ()async{
                        competition.distance = int.parse(selected);
                        PermissionStatus permission = await LocationPermissions().requestPermissions();
                        if(permission == PermissionStatus.granted) {
                          dynamic s = await Navigator.pushNamed(
                              context, "/race", arguments: [user, competition]);
                          setState(() {
                            if(s == "Ok")
                              competition.hasRace = true;
                          });
                        }
                      }
                    );
                  },
                ),
              ),
              SizedBox(width: 20.h,),
            ],
          ),
        ],
      );

    //si está fuera de maxdate sin inscribir o fuera de enddate no inscrito
    if( (!user.enrolled.contains(competition) && competition.enddate.isBefore(DateTime.now())) || (!user.enrolled.contains(competition) && competition.maxdate.isBefore(DateTime.now())))
      return Column(
        children: <Widget>[
          SizedBox(height: 5.h,),
          Row(
            children: <Widget>[
              SizedBox(width: 20.h,),
              Expanded(
                child: RawMaterialButton(
                  child: Text("No disponible", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white, fontSize: ScreenUtil().setSp(20),),),
                  fillColor: Colors.blueGrey,
                  shape: StadiumBorder(),
                  padding: EdgeInsets.only(right: 18.0.w, bottom: 18.0.h,top: 18.0.h,left: 18.w),
                  onPressed: null,
                ),
              ),
              SizedBox(width: 20.h,),
            ],
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("Fecha máxima de inscripción: ", style: TextStyle(fontWeight: FontWeight.normal, color: Colors.black, fontSize: ScreenUtil().setSp(11),),),
              Text("${Functions.parseDate(competition.maxdate, false)} ${Functions.parseTime(competition.maxdate)}", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: ScreenUtil().setSp(13),),),
            ],
          )
        ],
      );

    // si está fuera de enddate pero inscrito
    if(user.enrolled.contains(competition) && competition.enddate.isBefore(DateTime.now()))
      return Column(
        children: <Widget>[
          SizedBox(height: 5.h,),
          Row(
            children: <Widget>[
              SizedBox(width: 20.h,),
              Expanded(
                child: RawMaterialButton(
                  child: Text("Ver resultados", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white, fontSize: ScreenUtil().setSp(20),),),
                  fillColor: Color(0xff61b3d8),
                  shape: StadiumBorder(),
                  padding: EdgeInsets.only(right: 18.0.w, bottom: 18.0.h,top: 18.0.h,left: 18.w),
                  onPressed: (){
                    Navigator.pushNamed(context, "/results", arguments: [competition, user, null]);
                  },
                ),
              ),
              SizedBox(width: 20.h,),
            ],
          ),
        ],
      );

    //si es privada y no estas inscrito
    if(competition.type == "Privado" && !allowed.keys.contains(user.id) && !user.enrolled.contains(competition) && competition.maxdate.isAfter(DateTime.now())){
      return Column(
        children: <Widget>[
          SizedBox(height: 5.h,),
          Row(
            children: <Widget>[
              SizedBox(width: 20.h,),
              Expanded(
                child: RawMaterialButton(
                  child: Text("Solicitar inscripción", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white, fontSize: ScreenUtil().setSp(20),),),
                  fillColor: Color(0xff61b3d8),
                  shape: StadiumBorder(),
                  elevation: 0,
                  padding: EdgeInsets.only(right: 18.0.w, bottom: 18.0.h,top: 18.0.h,left: 18.w),
                  onPressed: () async{
                    setState(() {
                      loadingButton = true;
                    });
                    await DBService.dbService.createNotification(competition.organizerid, "El usuario ${user.firstname} ${user.lastname} quiere unirse a tu competición ${competition.name}", competition.id.toString(), user.id);
                    await DBService.dbService.addPrivate(user.id, competition.id, "P");
                    setState(() {
                      allowed[user.id] = "P";
                      loadingButton = false;
                    });
                  },
                ),
              ),
              SizedBox(width: 20.h,),
            ],
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("Fecha máxima de inscripción: ", style: TextStyle(fontWeight: FontWeight.normal, color: Colors.black, fontSize: ScreenUtil().setSp(11),),),
              Text("${Functions.parseDate(competition.maxdate, false)} ${Functions.parseTime(competition.maxdate)}", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: ScreenUtil().setSp(13),),),
            ],
          )
        ],
      );
    }

    //si es privada y ha solicitado
    if(competition.type == "Privado" && allowed.keys.contains(user.id) && allowed[user.id] == "P" && competition.maxdate.isAfter(DateTime.now())){
      return Column(
        children: <Widget>[
          SizedBox(height: 5.h,),
          Row(
            children: <Widget>[
              SizedBox(width: 20.h,),
              Expanded(
                child: RawMaterialButton(
                  child: Text("Inscripción solicitada", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white, fontSize: ScreenUtil().setSp(20),),),
                  fillColor: Colors.blueGrey,
                  shape: StadiumBorder(),
                  elevation: 0,
                  padding: EdgeInsets.only(right: 18.0.w, bottom: 18.0.h,top: 18.0.h,left: 18.w),
                ),
              ),
              SizedBox(width: 20.h,),
            ],
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("Fecha máxima de inscripción: ", style: TextStyle(fontWeight: FontWeight.normal, color: Colors.black, fontSize: ScreenUtil().setSp(11),),),
              Text("${Functions.parseDate(competition.maxdate, false)} ${Functions.parseTime(competition.maxdate)}", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: ScreenUtil().setSp(13),),),
            ],
          )
        ],
      );
    }

    //si no está inscrito y aún puede y no es privada
    if(!user.enrolled.contains(competition) && competition.maxdate.isAfter(DateTime.now()) && competition.type != "Privado")
      return Column(
        children: <Widget>[
          SizedBox(height: 5.h,),
          Row(
            children: <Widget>[
              SizedBox(width: 20.h,),
              Expanded(
                child: RawMaterialButton(
                  child: Text(competition.price == 0.0? "Inscribirse" : "Inscribirse (${competition.price}€)", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white, fontSize: ScreenUtil().setSp(20),),),
                  fillColor: Color(0xff61b3d8),
                  shape: StadiumBorder(),
                  elevation: 0,
                  padding: EdgeInsets.only(right: 18.0.w, bottom: 18.0.h,top: 18.0.h,left: 18.w),
                  onPressed: () async{
                    dynamic result;
                    if(competition.price != 0.0){
                      result = await Navigator.pushNamed(context, "/payment", arguments: competition);
                    }
                    else{
                      result = "Ok";
                    }
                    if(result.toString() == "Ok") {
                      setState(() {
                        loadingButton = true;
                      });
                      String result = await DBService.dbService
                          .enrrollCompetition(
                          user.id, competition.id.toString());
                      if (result == "Ok") {
                        user.enrolled.add(competition);
                        competition.numcompetitors ++;
                        competition.hasRace = false;
                        Alerts.toast("Inscrito!");
                      }
                      setState(() {
                        loadingButton = false;
                      });
                    }
                  },
                ),
              ),
              SizedBox(width: 20.h,),
            ],
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("Fecha máxima de inscripción: ", style: TextStyle(fontWeight: FontWeight.normal, color: Colors.black, fontSize: ScreenUtil().setSp(11),),),
              Text("${Functions.parseDate(competition.maxdate, false)} ${Functions.parseTime(competition.maxdate)}", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: ScreenUtil().setSp(13),),),
            ],
          )
        ],
      );

    //si está inscrito y estamos antes de eventdate
    if(user.enrolled.contains(competition) && competition.eventdate.isAfter(DateTime.now()))
      return Column(
        children: <Widget>[
          SizedBox(height: 5.h,),
          Row(
            children: <Widget>[
              SizedBox(width: 20.h,),
              Expanded(
                child: RawMaterialButton(
                  child: Text("Entrar", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white, fontSize: ScreenUtil().setSp(20),),),
                  fillColor: Colors.grey,
                  shape: StadiumBorder(),
                  elevation: 0,
                  padding: EdgeInsets.only(right: 18.0.w, bottom: 18.0.h,top: 18.0.h,left: 18.w),
                ),
              ),
              SizedBox(width: 20.h,),
            ],
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("Estas inscrito a está competición. Comienza el ", style: TextStyle(fontWeight: FontWeight.normal, color: Colors.black, fontSize: ScreenUtil().setSp(11),),),
              Text("${Functions.parseDate(competition.eventdate, false)} ${Functions.parseTime(competition.eventdate)}", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: ScreenUtil().setSp(13),),),
            ],
          )
        ],
      );

    //si está inscrito y entre eventdate y enddate y no ha hecho carrera
    if(user.enrolled.contains(competition) && competition.eventdate.isBefore(DateTime.now()) && !competition.hasRace)
      return Column(
        children: <Widget>[
          SizedBox(height: 5.h,),
          Row(
            children: <Widget>[
              SizedBox(width: 20.h,),
              Expanded(
                child: RawMaterialButton(
                  child: Text("Entrar", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white, fontSize: ScreenUtil().setSp(20),),),
                  fillColor: Color(0xff61b3d8),
                  shape: StadiumBorder(),
                  elevation: 0,
                  padding: EdgeInsets.only(right: 18.0.w, bottom: 18.0.h,top: 18.0.h,left: 18.w),
                  onPressed: ()async{
                    PermissionStatus permission = await LocationPermissions().requestPermissions();
                    if(permission == PermissionStatus.granted) {
                      dynamic s = await Navigator.pushNamed(
                          context, "/race", arguments: [user, competition]);
                      setState(() {
                        if(s == "Ok")
                          competition.hasRace = true;
                      });
                    }
                  },
                ),
              ),
              SizedBox(width: 20.h,),
            ],
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("Estas inscrito a está competición. Finaliza el ", style: TextStyle(fontWeight: FontWeight.normal, color: Colors.black, fontSize: ScreenUtil().setSp(11),),),
              Text("${Functions.parseDate(competition.enddate, false)} ${Functions.parseTime(competition.enddate)}", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: ScreenUtil().setSp(13),),),
            ],
          )
        ],
      );

    //si está inscrito y entre eventdate y enddate y ha hecho carrera
    if(user.enrolled.contains(competition) && competition.eventdate.isBefore(DateTime.now()) && competition.hasRace)
      return Column(
      children: <Widget>[
        SizedBox(height: 5.h,),
        Row(
          children: <Widget>[
            SizedBox(width: 20.h,),
            Expanded(
              child: RawMaterialButton(
                child: Text("Ver resultados", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white, fontSize: ScreenUtil().setSp(20),),),
                fillColor: Color(0xff61b3d8),
                shape: StadiumBorder(),
                padding: EdgeInsets.only(right: 18.0.w, bottom: 18.0.h,top: 18.0.h,left: 18.w),
                onPressed: (){
                  Navigator.pushNamed(context, "/results", arguments: [competition, user, null]);
                },
              ),
            ),
            SizedBox(width: 20.h,),
          ],
        ),
      ],
    );
  }

}


//            Text(competition.maxdate == null? "": "Fecha máxima de inscripción: ${Functions.parseDate(competition.maxdate, false)} ${Functions.parseTime(competition.maxdate)}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: ScreenUtil().setSp(10), color: Colors.grey),)