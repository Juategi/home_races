import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:homeraces/model/competition.dart';
import 'package:homeraces/model/user.dart';
import 'package:homeraces/screens/calendar/competition_tile.dart';
import 'package:homeraces/screens/explorer/competition_card.dart';
import 'package:homeraces/services/dbservice.dart';
import 'package:homeraces/shared/common_data.dart';
import 'package:provider/provider.dart';
import 'package:flappy_search_bar/flappy_search_bar.dart';

class Explorer extends StatefulWidget {
  @override
  _ExplorerState createState() => _ExplorerState();
}

class _ExplorerState extends State<Explorer> {
  final DBService _dbService = DBService();
  User user;
  List<Competition> promoted, popular;
  bool popularLoading, promotedLoading, isSearching;

  final key = new GlobalKey<ScaffoldState>();
  final TextEditingController _searchQuery = new TextEditingController();
  String searchText = "";
  String error = "";
  List<Competition> results;

  _ExplorerState() {
    _searchQuery.addListener(() {
      if (_searchQuery.text.isEmpty) {
        setState(() {
          isSearching = false;
          searchText = "";
        });
      }
      else {
        setState(() {
          isSearching = true;
          searchText = _searchQuery.text;
          results = null;
          _search(searchText, "None");
        });
      }
    });
  }

  Future _search(String query, String option) async{
    print(query);
    results = await DBService().query(user.locality, query, option, 10);
    setState(() {
      if(results.length == 0)
        error = "No results";
      else
        error = "";
    });
  }

  void _timer() {
    if(!popularLoading && !promotedLoading) {
      Future.delayed(Duration(seconds: 2)).then((_) {
        setState(() {
          print("Loading...");
        });
        _timer();
      });
    }
  }

  void _getPopular()async{
    popular = await _dbService.getPopular(user.locality, 10);
    popularLoading = true;
  }

  void _getPromoted()async{
    promoted = await _dbService.getPromoted(user.locality, 6);
    promotedLoading = true;
  }

  @override
  void initState() {
    promotedLoading = false;
    popularLoading = false;
    isSearching = false;
    _timer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    user = Provider.of<User>(context);
    if(!promotedLoading){
      _getPromoted();
    }

    if(!popularLoading){
      _getPopular();
    }
    ScreenUtil.init(context, height: CommonData.screenHeight, width: CommonData.screenWidth, allowFontScaling: true);
    return Scaffold(
      key: key,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(115.h),
        child: AppBar(
          elevation: 1,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          centerTitle: true,
          title: Text('EXPLORAR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: ScreenUtil().setSp(17), color: Colors.black,),),
          flexibleSpace: Column(
            children: <Widget>[
              SizedBox(height: 80.h,),
              Container(
                padding: EdgeInsets.only(left: 8.w, right: 8.w),
                margin: EdgeInsets.only(left: 30.w, right: 30.w),
                width: 300.w,
                child: TextField(
                  controller: _searchQuery,
                  /*onSubmitted: (s){
                    setState(() {
                      isSearching = false;
                    });
                    FocusScope.of(context).unfocus();
                  },*/
                  autofocus: false,
                  style: new TextStyle(
                    color: Colors.white,
                  ),
                  decoration: new InputDecoration(
                      prefixIcon: new Icon(Icons.search,color: Colors.grey),
                      hintText: "Buscar competiciones",
                      hintStyle: new TextStyle(color: Colors.black45)
                  ),
                ),
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    border: Border.all(color: Colors.black45),
                    borderRadius: new BorderRadius.only(
                      topLeft: const Radius.circular(10.0),
                      topRight: const Radius.circular(10.0),
                      bottomLeft: const Radius.circular(10.0),
                      bottomRight: const Radius.circular(10.0),
                    )
                ),
              ),
            ],
          ),
        ),
      ),
      body: isSearching?
          results == null?
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),),
            ],
          ):
          results.length == 0?
          Text(error, style: TextStyle(fontSize: ScreenUtil().setSp(13), color: Colors.red,),)
      :ListView(children: _competitionsTiles(results),)

      :Column(children: <Widget>[
        Row(mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Row(mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(width: 15.w,),
                Text("Competiciones oficiales", style: TextStyle(fontWeight: FontWeight.bold, fontSize: ScreenUtil().setSp(14), color: Colors.black,),),SizedBox(width: 10.w,),
                SizedBox(width: 125.w,),
                FlatButton(child: Text('Ver todas', style: TextStyle(fontSize: ScreenUtil().setSp(13), color: const Color(0xff61b3d8),),), onPressed: (){
                },)
              ],
            ),
          ],
        ),
        Container(
          margin: EdgeInsets.symmetric(vertical: 10.0.h),
          height: 190.h,
          child: !promotedLoading? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),),
            ],
          ) : ListView(
            scrollDirection: Axis.horizontal,
            children: _competitionsCards(promoted),
          ),
        ),
        Divider(thickness: 1,),
        Row(mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(width: 15.w,),
            Text("Competiciones populares", style: TextStyle(fontWeight: FontWeight.bold, fontSize: ScreenUtil().setSp(14), color: Colors.black,),),SizedBox(width: 10.w,),
            SizedBox(width: 105.w,),
            FlatButton(child: Text('Ver todas', style: TextStyle(fontSize: ScreenUtil().setSp(13), color: const Color(0xff61b3d8),),), onPressed: (){
            },)
          ],
        ),
        !popularLoading? Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),),
          ],
        ): Flexible(
          child: ListView(
            children: _competitionsTiles(popular),
          ),
        )
      ],),
    );
  }

  List<Widget> _competitionsCards(List<Competition> competitions){
    List<Widget> list = List<Widget>();
    for(Competition competition in competitions){
      list.add(CompetitionCard(competition: competition,),);
    }
    return list;
  }

  List<Widget> _competitionsTiles(List<Competition> competitions){
    List<Widget> list = List<Widget>();
    for(Competition competition in competitions){
      list.add(CompetitionTile(competition: competition,),);
    }
    return list;
  }
}
