import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:homeraces/model/comment.dart';
import 'package:homeraces/model/competition.dart';
import 'package:homeraces/model/user.dart';
import 'package:homeraces/screens/competition/comments/comment_box.dart';
import 'package:homeraces/services/dbservice.dart';
import 'package:homeraces/shared/alert.dart';
import 'package:homeraces/shared/common_data.dart';
import 'package:homeraces/shared/decos.dart';
import 'package:homeraces/shared/functions.dart';
import 'package:provider/provider.dart';

class CompetitionProfile extends StatefulWidget {
  @override
  _CompetitionProfileState createState() => _CompetitionProfileState();
}

class _CompetitionProfileState extends State<CompetitionProfile> {
  final DBService _dbService = DBService();
  final TextEditingController _commentController = new TextEditingController();
  Competition competition;
  Comment comment;
  List<CommentBox> boxes;
  User user;
  bool loading, init, loadingButton;

  List<Widget> _initGallery() {
    return competition.gallery.map((String url) {
      return GridTile(
          child: FlatButton(
            onPressed: (){
              setState(() {

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
    if(competition.comments == null) {
      Future.delayed(Duration(seconds: 2)).then((_) {
        setState(() {
          print("Loading...");
        });
        _timer();
      });
    }
  }

  void _loadComments()async{
    competition.comments = await _dbService.getParentComments(competition.id);
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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var args = List<Object>.of(ModalRoute.of(context).settings.arguments);
    competition = args.first;
    user = args.last;
    boxes.clear();
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
                  _dbService.deleteFromFavorites(user.id, competition.id);
                }
                else{
                  user.favorites.add(competition);
                  _dbService.addToFavorites(user.id, competition.id);
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
              top: 50.h,
              child: Row(children: <Widget>[
                  Icon(Icons.calendar_today, size: ScreenUtil().setSp(18),),
                  SizedBox(width: 7.w,),
                  Text(Functions.parseDate(competition.eventdate, true), style: TextStyle(fontWeight: FontWeight.bold, fontSize: ScreenUtil().setSp(15), color: const Color(0xff61b3d8)),),
              ],),
            ),
            Positioned(
              left: 155.w,
              top: 85.h,
              child: Row(children: <Widget>[
                  Icon(Icons.access_time, size: ScreenUtil().setSp(20),),
                  SizedBox(width: 7.w,),
                  Text(Functions.parseTime(competition.eventdate), style: TextStyle(fontWeight: FontWeight.bold, fontSize: ScreenUtil().setSp(15), color: const Color(0xff61b3d8)),),
              ],),
            ),
            Positioned(
                left: 155.w,
                top: 120.h,
                child: Text("Fecha máxima de inscripción: ${Functions.parseDate(competition.maxdate, false)} ${Functions.parseTime(competition.maxdate)}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: ScreenUtil().setSp(10), color: Colors.grey),)
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
          padding: EdgeInsets.only(left: 23.w),
          child: Column(children: <Widget>[
            Row(children: <Widget>[
              FaIcon(FontAwesomeIcons.clock, size: ScreenUtil().setSp(14),),
              SizedBox(width: 20.w,),
              Text("Duración:  ", style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(12), color: Colors.black),),
              Text("${competition.duration.toString()} minutos", style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(16), color: Colors.black),),
            ],)
          ],),
        ),
        SizedBox(height: 20.h,),
        Padding(
          padding: EdgeInsets.only(left: 20.w),
          child: Column(children: <Widget>[
            Row(children: <Widget>[
              Icon(Icons.lock, size: ScreenUtil().setSp(20),),
              SizedBox(width: 20.w,),
              Text("Competición:  ", style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(12), color: Colors.black),),
              Text(competition.type == "Public"? "Pública": "Privada", style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(16), color: Colors.black),),
            ],)
          ],),
        ),
        SizedBox(height: 20.h,),
        Padding(
          padding: EdgeInsets.only(left: 20.w),
          child: Column(children: <Widget>[
            Row(children: <Widget>[
              Icon(Icons.person, size: ScreenUtil().setSp(20),),
              SizedBox(width: 20.w,),
              Text("Organizado por:  ", style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(12), color: Colors.black),),
              Text(competition.organizer ?? "", style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(16), color: Colors.black),),
            ],)
          ],),
        ),
        SizedBox(height: 40.h,),
        Padding(
          padding: EdgeInsets.only(left: 20.w),
          child: Column(children: <Widget>[
            Row(children: <Widget>[
              Icon(Icons.people, size: ScreenUtil().setSp(20),),
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
        /*Padding(
          padding: EdgeInsets.only(left: 60.w),
          child: Column(children: <Widget>[
            Row(children: <Widget>[
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
              SizedBox(width: 6.w,),
            ],),
          ],),
        ),*/
        Padding(
          padding: EdgeInsets.only(right: 18.0.w, left: 18.0.w, top: 6.h, bottom: 6.h),
          child: Divider(thickness: 1,),
        ),
        Padding(
          padding: EdgeInsets.only(left: 20.w),
          child: Column(children: <Widget>[
            Row(children: <Widget>[
              FaIcon(FontAwesomeIcons.trophy, size: ScreenUtil().setSp(16),),
              SizedBox(width: 20.w,),
              Text("Premios:  ", style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(12), color: Colors.black),),
            ],)
          ],),
        ),
        SizedBox(height: 10.h,),
        Padding(
          padding: EdgeInsets.only(left: 60.w),
          child: Column(children: <Widget>[
            Row(children: <Widget>[
              Text(competition.rewards, style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(16), color: Colors.black),),
            ],)
          ],),
        ),
        SizedBox(height: 10.h,),
        Padding(
          padding: EdgeInsets.only(left: 20.w),
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
          child: Column(children: <Widget>[
            Row(children: <Widget>[
              Text(competition.observations, style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(16), color: Colors.black),),
            ],)
          ],),
        ),
        SizedBox(height: 30.h,),
        competition.gallery.length == 0? Container(height: 0,): Padding(
          padding: EdgeInsets.only(left: 20.w),
          child: Column(children: <Widget>[
            Row(children: <Widget>[
              FaIcon(FontAwesomeIcons.images, size: ScreenUtil().setSp(15),),
              SizedBox(width: 20.w,),
              Text("Imágenes:  ", style: TextStyle(fontWeight: FontWeight.normal, fontSize: ScreenUtil().setSp(12), color: Colors.black),),
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
            loading? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),),
              ],) :
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
                await DBService().postComment(comment);
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
        competition.comments == null? Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),),
          ],) :
        Column(children: boxes)
      ],),

      bottomNavigationBar: BottomAppBar(
        child: competition.maxdate.isBefore(DateTime.now()) ?
        RawMaterialButton(
          child: Text("No disponible", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white, fontSize: ScreenUtil().setSp(20),),),
          fillColor: Colors.blueGrey,
          shape: RoundedRectangleBorder(),
          padding: EdgeInsets.only(right: 18.0.w, bottom: 18.0.h,top: 18.0.h,left: 18.w),
          onPressed: null,
        )
        : loadingButton? Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),),
          ],) : RawMaterialButton(
            child: Text(user.enrolled.contains(competition)? "Entrar":"Inscribirse   (${competition.price}€)", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white, fontSize: ScreenUtil().setSp(20),),),
            fillColor: Color(0xff61b3d8),
            shape: RoundedRectangleBorder(),
            padding: EdgeInsets.only(right: 18.0.w, bottom: 18.0.h,top: 18.0.h,left: 18.w),
            onPressed: ()async{
              if(!user.enrolled.contains(competition)){
                setState(() {
                  loadingButton = true;
                });

                String result = await _dbService.enrrollCompetition(user, competition);
                if(result == "Ok") {
                  user.enrolled.add(competition);
                  competition.numcompetitors ++;
                  Alerts.toast("Inscrito!");
                }
                setState(() {
                  loadingButton = false;
                });
              }
            },
      ),
    ));
  }
}
