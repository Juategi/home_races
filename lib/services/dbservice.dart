import 'dart:convert';
import 'package:homeraces/model/comment.dart';
import 'package:homeraces/model/competition.dart';
import 'package:homeraces/model/follower.dart';
import 'package:homeraces/model/notification.dart';
import 'package:homeraces/model/race_data.dart';
import 'package:homeraces/model/timeless_competition_data.dart';
import 'package:homeraces/services/pool.dart';
import 'package:homeraces/shared/common_data.dart';
import 'package:intl/intl.dart';
import 'package:homeraces/model/user.dart';
import 'package:diacritic/diacritic.dart';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;

class DBService{

  //String api = "https://home-races.web.app";
  String api = "http://37.14.57.15:3000";
  String ipUrl = "https://api.ipify.org?format=json";
  String locIpUrl = "https://ipapi.co/";
  static User userF;
  static final DBService dbService = DBService();

  Future<User> getUserDataProvider(String id) async{
    if(userF == null){
      var response = await http.get("$api/users", headers: {"id":id});
      print(response.body);
      while(response.body == "[]"){
        Future.delayed(const Duration(milliseconds: 900), () {});
        response = await http.get("$api/users", headers: {"id":id});
      }
      if(response.body != "[]") {
        var result = json.decode(response.body)[0];
        int year = int.parse(result['registerdate'].toString().substring(0, 4));
        int month = int.parse(result['registerdate'].toString().substring(5, 7));
        int day = int.parse(result['registerdate'].toString().substring(8, 10));
        DateTime registerDate = DateTime(year, month, day).add(Duration(days: 1));
        DateTime birthDate;
        if (result['birthdate'] != null) {
          year = int.parse(result['birthdate'].toString().substring(0, 4));
          month = int.parse(result['birthdate'].toString().substring(5, 7));
          day = int.parse(result['birthdate'].toString().substring(8, 10));
          birthDate = DateTime(year, month, day).add(Duration(days: 1));
        }
        List<int> kms = await getKm(result['id']);
        //List<int> kms = [0,0];
        User user = User(
            id: result['id'],
            email: result['email'],
            birthdate: result['birthdate'] != null ? birthDate : null,
            image: result['image'] == "null"? CommonData.defaultProfile : result['image'],
            service: result['service'],
            apprated: result['apprated'],
            device: result['device'],
            facebooklinked: result['facebooklinked'],
            firstname: result['firstname'],
            lastname: result['lastname'],
            ip: result['ip'],
            iplocalization: result['iplocalization'],
            locality: result['locality'],
            password: result['password'],
            registerdate: registerDate,
            sex: result['sex'],
            username: result['username'],
            height: result['height'],
            weight: result['weight'],
            country: result['country'],
            kmOfficial: kms.last,
            kmTotal: kms.first,
            //favorites: await dbService.getFavorites(result['id']),
            //enrolled: await dbService.getEnrolled(result['id']),
            notifications: await dbService.getNotifications(result['id']),
            followers: await dbService.getFollowers(result['id']),
            following: await dbService.getFollowing(result['id']),
        );
        userF = user;
        userF.enrolled = await dbService.getEnrolled(result['id']);
        userF.favorites = await dbService.getFavorites(result['id']);
        return user;
      }
    }
    else {
      return userF;
    }
  }

  Future<List<int>> getKm(String userid) async{
    var response = await http.get("$api/km", headers: {"userid": userid});
    int total,official;
    if(json.decode(response.body).length < 2){
      official = 0;
      total = 0;
    }
    else{
      official = int.parse(json.decode(response.body)[0]['km']);
      total = int.parse(json.decode(response.body)[1]['km']);
    }
    return [total,official];
  }

  Future<User> getUserDataChecker(String id) async{
    var response = await http.get("$api/users", headers: {"id":id});
    //print(response.body);
    if(response.body != "[]") {
      var result = json.decode(response.body)[0];
      int year = int.parse(result['registerdate'].toString().substring(0, 4));
      int month = int.parse(result['registerdate'].toString().substring(5, 7));
      int day = int.parse(result['registerdate'].toString().substring(8, 10));
      DateTime registerDate = DateTime(year, month, day).add(Duration(days: 1));
      DateTime birthDate;
      if (result['birthdate'] != null) {
        year = int.parse(result['birthdate'].toString().substring(0, 4));
        month = int.parse(result['birthdate'].toString().substring(5, 7));
        day = int.parse(result['birthdate'].toString().substring(8, 10));
        birthDate = DateTime(year, month, day).add(Duration(days: 1));
      }
      User user = User(
          id: result['id'],
          email: result['email'],
          birthdate: result['birthdate'] != null ? birthDate : null,
          image: result['image'],
          service: result['service'],
          apprated: result['apprated'],
          device: result['device'],
          facebooklinked: result['facebooklinked'],
          firstname: result['firstname'],
          lastname: result['lastname'],
          ip: result['ip'],
          iplocalization: result['iplocalization'],
          locality: result['locality'],
          password: result['password'],
          registerdate: registerDate,
          sex: result['sex'],
          username: result['username'],
          height: result['height'],
          weight: result['weight'],
          country: result['country'],
      );
      return user;
    }
    return null;
  }

  Future createUser(User user)async{
    if (Platform.isAndroid) {
      user.device = "ANDROID";
    } else if (Platform.isIOS) {
      user.device = "IOS";
    }
    var formatter = new DateFormat('dd/MM/yyyy');
    var result = await http.get(ipUrl, headers: {});
    user.ip = json.decode(result.body)['ip'];
    result = await http.get("$locIpUrl${user.ip}/json/", headers: {});
    user.iplocalization = json.decode(result.body);
    user.locality = user.iplocalization["city"];
    user.country = user.iplocalization["country_name"];
    user.registerdate = DateTime.now();
    Map body = {
      "id": user.id,
      "username": user.username,
      "firstname": user.firstname,
      "lastname": user.lastname,
      "email": user.email,
      "password": user.password == null ? "null": user.password,
      "device": user.device,
      "ip": user.ip,
      "iplocalization": user.iplocalization.toString(),
      "service": user.service,
      "locality": user.locality,
      "image": user.image == null ? "null": user.image,
      "country": user.country
    };
    var response = await http.post("$api/users", body: body);
    print(response.body);
  }

  Future updateUser(User user)async{
    if (Platform.isAndroid) {
      user.device = "ANDROID";
    } else if (Platform.isIOS) {
      user.device = "IOS";
    }
    var formatter = new DateFormat('dd/MM/yyyy');
    var result = await http.get(ipUrl, headers: {});
    user.ip = json.decode(result.body)['ip'];
    result = await http.get("$locIpUrl${user.ip}/json/", headers: {});
    user.iplocalization = json.decode(result.body);
    if(user.locality == null)
      user.locality = user.iplocalization["city"];
    if(user.country == null)
      user.country = user.iplocalization["country_name"];
    user.registerdate = DateTime.now();
    Map body = {
      "id": user.id,
      "username": user.username,
      "firstname": user.firstname,
      "lastname": user.lastname,
      "email": user.email,
      "password": user.password == null ? "null": user.password,
      "device": user.device,
      "ip": user.ip,
      "iplocalization": user.iplocalization.toString(),
      "service": user.service,
      "locality": user.locality,
      "image": user.image == null ? "null": user.image,
      "sex" : user.sex == null? "N" : user.sex,
      "birthdate": user.birthdate == null? "null" : user.birthdate.toString(),
      "country": user.country,
      "height": user.height == null ? "0" : user.height.toString(),
      "weight": user.weight == null ? "0" : user.weight.toString()
    };
    var response = await http.put("$api/users", body: body);
    print(response.body);
  }

  Future deleteUser(User user)async{
    var response = await http.delete("$api/users", headers: {"id":user.id});
    print(response.body);
  }

  Future<String> checkUsernameEmail(String username, String email) async{
    String em, us;
    String result = "";
    var response = await http.get("$api/email", headers: {"email": email});
    print(response.body);
    var response2 = await http.get("$api/username", headers: {"username": username});
    print(response2.body);
    try {
      var aux = json.decode(response.body);
      em = aux[0]['email'];
    } catch(e){}
    try {
      var aux = json.decode(response2.body);
      us = aux[0]['username'];
    }catch(e){}
    if(us != null)
      result += "u";
    if(em != null)
      result += "e";
    return result;
  }

  Future<bool> checkAdmin(String userid) async{
    var response = await http.get("$api/admin", headers: {"id": userid});
    var result = response.body;
    if(result == "True"){
      return true;
    }else if(result == "False"){
      return false;
    }
  }

  Future<bool> checkUsername(String username) async{
    String us;
    var response = await http.get("$api/username", headers: {"username": username});
    print(response.body);
    try {
      var aux = json.decode(response.body);
      us = aux[0]['username'];
    }catch(e){}
    if(us == null)
      return false;
    else
      return true;
  }

  Future addFollower(String followerid)async{
    var response = await http.post("$api/followers", body: {"userid":userF.id, "followerid":followerid});
    print(response.body);
  }

  Future deleteFollower(String userid, String followerid)async{
    var response = await http.delete("$api/followers", headers: {"userid":userid, "followerid":followerid});
    print(response.body);
  }

  Future<List<Follower>> getFollowers(String userid)async{
    var response = await http.get("$api/followers", headers: {"userid":userid});
    List<dynamic> result = json.decode(response.body);
    List<Follower> followers = List<Follower>();
    for(dynamic element in result){
      Follower follower = Follower(
        userid: element['userid'],
        image: element['image'],
        lastname: element['lastname'],
        firstname: element['firstname'],
        username: element['username']
      );
      followers.add(follower);
    }
    return followers;
  }

  Future<List<Follower>> getFollowing(String userid)async{
    var response = await http.get("$api/following", headers: {"userid":userid});
    List<dynamic> result = json.decode(response.body);
    List<Follower> following = List<Follower>();
    for(dynamic element in result){
      Follower follower = Follower(
          userid: element['followerid'],
          image: element['image'],
          lastname: element['lastname'],
          firstname: element['firstname'],
          username: element['username']
      );
      following.add(follower);
    }
    return following;
  }

  Future createCompetition(Competition competition, String organizerid)async{
    Map body;
    if(competition.eventdate == null){
      body = {
        "name": competition.name,
        "image": competition.image,
        "type": competition.type,
        "modality": competition.modality,
        "locality": competition.locality,
        "price": competition.price.toString(),
        "capacity": competition.capacity.toString(),
        "timezone": competition.timezone,
        "rewards": competition.rewards,
        "observations": competition.observations,
        "promoted": competition.promoted,
        "gallery": competition.gallery.toString().replaceAll("[", "{").replaceAll("]", "}") ?? List<String>().toString(),
        "distance": competition.distance.toString(),
        "eventdate":  "null",
        "eventtime": "null",
        "enddate": "null",
        "endtime": "null",
        "maxdate": "null",
        "maxtime": "null",
      };
    }
    else{
      body = {
        "name": competition.name,
        "image": competition.image,
        "type": competition.type,
        "modality": competition.modality,
        "locality": competition.locality,
        "price": competition.price.toString(),
        "capacity": competition.capacity.toString(),
        "timezone": competition.timezone,
        "rewards": competition.rewards,
        "observations": competition.observations,
        "promoted": competition.promoted,
        "gallery": competition.gallery.toString().replaceAll("[", "{").replaceAll("]", "}") ?? List<String>().toString(),
        "distance": competition.distance.toString(),
        "eventdate":  competition.eventdate.toString().substring(0,10),
        "eventtime": competition.eventdate.toString().substring(11,19),
        "enddate": competition.enddate.toString().substring(0,10),
        "endtime": competition.enddate.toString().substring(11,19),
        "maxdate": competition.maxdate.toString().substring(0,10),
        "maxtime": competition.maxdate.toString().substring(11,19),
      };
    }
    var response = await http.post("$api/competitions", body: body);
    List<dynamic> getId = json.decode(response.body);
    competition.id = int.parse(getId.first["id"].toString());
    print("Competition added with id ${competition.id}");
    var result = await http.get(ipUrl, headers: {});
    String ip = json.decode(result.body)['ip'];
    result = await http.get("$locIpUrl${ip}/json/", headers: {});
    dynamic iplocalization = json.decode(result.body);
    body = {
      "userid": organizerid,
      "competitionid": competition.id.toString(),
      "ip": ip,
      "iplocalization": iplocalization.toString()
    };
    response = await http.post("$api/organizer", body: body);
    print(response.body);
    Pool.addCompetition([competition]);
  }

  Future<List<String>> getCompetitorsImage(String competitionid) async{
    var response = await http.get("$api/competitorsimages", headers: {"competitionid": competitionid});
    List<dynamic> aux = json.decode(response.body);
    List<String> images = [];
    for(dynamic element in aux){
      images.add(element["image"]);
    }
    return images;
  }

  Future<Map<String, String>> getPrivate(String id) async{
    Map<String, String> result = Map<String, String>();
    var response = await http.get("$api/private", headers: {"competitionid": id});
    print(response.body);
    var aux = json.decode(response.body);
    for(dynamic element in aux){
      result[element["userid"]] = element["state"];
    }
    return result;
  }

  Future addPrivate(String userid, int competitionid, String state) async{
    var response = await http.post("$api/private", body: {"userid": userid, "competitionid": competitionid.toString(), "state": state});
    print(response.body);
  }

  Future deletePrivate(String userid, String competitionid) async{
    var response = await http.delete("$api/private", headers: {"userid": userid, "competitionid": competitionid.toString()});
    print(response.body);
  }

  Future deleteFromFavorites(String userid, int competitionid) async{
    var response = await http.delete("$api/favorites", headers: {"userid": userid, "competitionid": competitionid.toString()});
    print(response.body);
  }

  Future addToFavorites(String userid, int competitionid) async{
    var response = await http.put("$api/favorites", headers: {"userid": userid, "competitionid": competitionid.toString()});
    print(response.body);
  }

  Future<Competition> getCompetitionById(String id) async{
    var response = await http.get("$api/competitionsid", headers: {"id": id});
    //print(response.body);
    List<Competition> aux = await _parseCompetitions(response.body, false);
    return aux.first;
  }

  Future<List<Competition>> getFavorites(String id) async{
    var response = await http.get("$api/favorites", headers: {"id": id});
    //print(response.body);
    return await _parseCompetitions(response.body, false);
  }

  Future<List<Competition>> getEnrolled(String id) async{
    var response = await http.get("$api/competitions", headers: {"id": id});
    //print(response.body);
    return await _parseCompetitions(response.body, true);
  }

  Future<List<Competition>> getPromoted(String locality, int limit) async{
    var response = await http.get("$api/promoted", headers: {"locality": locality, "limit": limit.toString()});
    //print(response.body);
    return await _parseCompetitions(response.body, false);
  }
  Future<List<Competition>> getPopular(String locality, int limit) async{
    var response = await http.get("$api/popular", headers: {"locality": locality, "limit": limit.toString()});
    //print(response.body);
    return await _parseCompetitions(response.body, false);
  }

  Future<String> postComment(Comment comment)async{
    var result = await http.get(ipUrl, headers: {});
    String ip = json.decode(result.body)['ip'];
    result = await http.get("$locIpUrl${ip}/json/", headers: {});
    dynamic iplocalization = json.decode(result.body);
    Map body = {
      "userid": comment.userid,
      "competitionid": comment.competitionid.toString(),
      "comment": comment.comment,
      "ip": ip,
      "iplocalization": iplocalization.toString(),
      "parentid": comment.parentid.toString() ?? "null"
    };
    var response = await http.post("$api/comments", body: body);
    print(response.body);
    List<dynamic> getId = json.decode(response.body);
    comment.id = int.parse(getId.first["id"].toString());
    comment.ip = ip;
    comment.iplocalization = iplocalization.toString();
    comment.date = DateTime.now();
    comment.numanswers = 0;
    print("Comment added with id: ${comment.id}");
    return "Ok";
  }

  Future<List<Comment>> getParentComments(int competitionid) async{
    var response = await http.get("$api/comments", headers: {"competitionid": competitionid.toString()});
    print(response.body);
    List<Comment> comments = List<Comment>();
    List<dynamic> result = json.decode(response.body);
    for (dynamic element in result){
      Comment comment = Comment(
        comment: element['comment'],
        id: element['id'],
        numanswers: element['numanswers'] == null? 0: int.parse(element['numanswers']),
        image: element['image'],
        ip: element['ip'],
        userid: element['userid'],
        competitionid: element['competitionid'],
        iplocalization: element['iplocalization'],
        parentid: element['parentid'],
        date: _parseDate(element['commentdate'].toString(), element['commenttime'].toString())
      );
      comments.add(comment);
    }
    comments.sort((c1,c2){
      return c2.id.compareTo(c1.id);
    });
    return comments;
  }

  Future<List<Comment>> getSubComments(int competitionid, int parentid) async{
    var response = await http.get("$api/subcomments", headers: {"competitionid": competitionid.toString(), "parentid": parentid.toString()});
    print(response.body);
    List<Comment> comments = List<Comment>();
    List<dynamic> result = json.decode(response.body);
    for (dynamic element in result){
      Comment comment = Comment(
          comment: element['comment'],
          id: element['id'],
          image: element['image'],
          ip: element['ip'],
          userid: element['userid'],
          competitionid: element['competitionid'],
          iplocalization: element['iplocalization'],
          parentid: element['parentid'],
          date: _parseDate(element['commentdate'].toString(), element['commenttime'].toString())
      );
      comments.add(comment);
    }
    comments.sort((c1,c2){
      return c1.id.compareTo(c2.id);
    });
    return comments;
  }

  Future sendReport(String userid, int commentid, String report) async{
    Map body = {
      "userid": userid,
      "commentid": commentid.toString(),
      "report": report
    };
    print(body);
    var response = await http.post("$api/report", body: body);
    print(response.body);
  }

  Future<String> enrrollCompetition(String userid, String competitionid)async{
    var result = await http.get(ipUrl, headers: {});
    String ip = json.decode(result.body)['ip'];
    result = await http.get("$locIpUrl${ip}/json/", headers: {});
    dynamic iplocalization = json.decode(result.body);
    Map body = {
      "userid": userid,
      "competitionid": competitionid,
      "ip": ip,
      "iplocalization": iplocalization.toString()
    };
    var response = await http.post("$api/enrroll", body: body);
    print(response.body);
    return response.body;
  }

  Future<List<NotificationUser>> getNotifications(String userid)async{
    var response = await http.get("$api/notifications", headers: {"userid": userid});
    print(response.body);
    List<NotificationUser> notifications = List<NotificationUser>();
    List<dynamic> result = json.decode(response.body);
    for (dynamic element in result){
      NotificationUser notification = NotificationUser(
        userid: userid,
        id: element['id'],
        message: element['message'],
        userreference: element['userreference'],
        notificationDate: _parseDate(element['ndate'].toString(), element['ntime'].toString()),
        competition: await dbService.getCompetitionById(element['competitionid'].toString())
      );
      notifications.add(notification);
    }
    return notifications;
  }

  Future deleteNotification(String id) async{
    var response = await http.delete("$api/notifications", headers: {"id": id});
    print(response.body);
  }

  Future createNotification(String userid, String message, String competitionid, String userreference,) async{
    var response = await http.post("$api/notifications", body: {"userid": userid, "message": message, "competitionid": competitionid, "userreference":userreference});
    print(response.body);
  }

  Future<List<Competition>> query(String locality, String query, String option, int limit) async {
    query = "%" + removeDiacritics(query) + "%";
    var response = await http.get(
        "$api/search",
        headers: {"query": query, "option": option, "locality":locality.toUpperCase(), "limit": limit.toString()});
    return await _parseCompetitions(response.body, false);
  }

  Future saveRaceData(RaceData raceData) async{
    Map<String, int> map = {};
    raceData.partials.forEach((key, value) {
      map["\"$key\""] = value;
    });
    Map body = {
      "userid": raceData.userid,
      "competitionid": raceData.competitionid,
      "time": raceData.time.toString(),
      "distance": raceData.distance.toString(),
      "steps": raceData.steps.toString(),
      "partials": map.toString()
    };
    var response = await http.post("$api/races", body: body);
    print(response.body);
  }

  Future<List<RaceData>> getRaceData(String competitionid) async{
    var response = await http.get("$api/races", headers: {"competitionid": competitionid});
    print(response.body);
    List<RaceData> raceData = List<RaceData>();
    List<dynamic> result = json.decode(response.body);
    DateTime birthDate, raceDate;
    for (dynamic element in result){
      if (element['birthdate'] != null) {
        int year = int.parse(element['birthdate'].toString().substring(0, 4));
        int month = int.parse(element['birthdate'].toString().substring(5, 7));
        int day = int.parse(element['birthdate'].toString().substring(8, 10));
        birthDate = DateTime(year, month, day).add(Duration(days: 1));
      }
      int yearR = int.parse(element['racedate'].toString().substring(0, 4));
      int monthR = int.parse(element['racedate'].toString().substring(5, 7));
      int dayR = int.parse(element['racedate'].toString().substring(8, 10));
      raceDate = DateTime(yearR, monthR, dayR).add(Duration(days: 1));
      RaceData rc = RaceData(
        id: element['id'],
        userid: element['userid'],
        distance: element['distance'],
        steps: element['steps'],
        time: element['time'],
        firstname: element['firstname'],
        lastname: element['lastname'],
        image: element['image'],
        sex: element['sex'],
        birthdate: birthDate,
        racedate: raceDate
      );
      raceData.add(rc);
    }
    return raceData;
  }

  Future<List<RaceData>> getRaceDataUser(String competitionid, String userid) async{
    var response = await http.get("$api/raceuser", headers: {"competitionid": competitionid, "userid":userid});
    print(response.body);
    List<RaceData> raceData = List<RaceData>();
    List<dynamic> result = json.decode(response.body);
    DateTime birthDate, raceDate;
    for (dynamic element in result){
      if (element['birthdate'] != null) {
        int year = int.parse(element['birthdate'].toString().substring(0, 4));
        int month = int.parse(element['birthdate'].toString().substring(5, 7));
        int day = int.parse(element['birthdate'].toString().substring(8, 10));
        birthDate = DateTime(year, month, day).add(Duration(days: 1));
      }
      int yearR = int.parse(element['racedate'].toString().substring(0, 4));
      int monthR = int.parse(element['racedate'].toString().substring(5, 7));
      int dayR = int.parse(element['racedate'].toString().substring(8, 10));
      raceDate = DateTime(yearR, monthR, dayR).add(Duration(days: 1));
      RaceData rc = RaceData(
          id: element['id'],
          userid: element['userid'],
          distance: element['distance'],
          steps: element['steps'],
          time: element['time'],
          firstname: element['firstname'],
          lastname: element['lastname'],
          image: element['image'],
          sex: element['sex'],
          birthdate: birthDate,
          racedate: raceDate
      );
      raceData.add(rc);
    }
    return raceData;
  }

  Future<bool> checkRaceDataUser(String competitionid, String userid) async{
    var response = await http.get("$api/raceuser", headers: {"competitionid": competitionid, "userid":userid});
    List<RaceData> raceData = List<RaceData>();
    List<dynamic> result = json.decode(response.body);
    return !(result.length == 0);
  }

  Future<Map<int,int>> getRacePartials(String raceid) async{
    var response = await http.get("$api/partials", headers: {"id": raceid});
    List<dynamic> result = json.decode(response.body);
    String element = result.first["partials"];
    Map<String, dynamic> aux = json.decode(element);
    Map<int, int> partials = {};
    aux.forEach((k, v) {
      partials[int.parse(k)] = int.parse(v.toString());
    });
    print((partials));
    return partials;
  }

  DateTime _parseDate(String date, String time){
    int year = int.parse(date.substring(0,4));
    int month = int.parse(date.substring(5,7));
    int day = int.parse(date.substring(8,10));
    int hour = int.parse(time.substring(0,2));
    int minute = int.parse(time.substring(3,5));
    int second = int.parse(time.substring(6,8));
    return DateTime(year,month,day,hour,minute,second).add(Duration(days: 1));
  }

  Future<List<Competition>> _parseCompetitions(String body, bool hasRace) async{
    List<Competition> competitions = List<Competition>();
    List<dynamic> result = json.decode(body);
    for (dynamic element in result){
      List<String> images = await DBService.dbService.getCompetitorsImage(element['id'].toString());
      Competition competition = Competition(
        id: element['id'],
        image: element['image'],
        name: element['name'],
        locality: element['locality'],
        observations: element['observations'],
        type: element['type'],
        modality: element['modality'],
        promoted: element['promoted'],
        rewards: element['rewards'],
        timezone: element['timezone'],
        price: element['price'].toDouble(),
        capacity: element['capacity'],
        numcompetitors: element['numcompetitors'] == null? 0: int.parse(element['numcompetitors']),
        eventdate: element['eventdate'] == null? null : _parseDate(element['eventdate'].toString(), element['eventtime'].toString()),
        enddate: element['enddate'] == null? null : _parseDate(element['enddate'].toString(), element['endtime'].toString()),
        maxdate: element['maxdate'] == null? null : _parseDate(element['maxdate'].toString(), element['maxtime'].toString()),
        organizer: element['organizer'],
        organizerid: element['organizerid'],
        gallery: element['gallery'] == null ? List<String>() : List<String>.from(element['gallery']),
        distance: element['distance'],
        usersImages: images,
        hasRace: hasRace? await DBService.dbService.checkRaceDataUser(element['id'].toString(), userF.id): null,
      );
      competitions.add(competition);
    }
    Pool.addCompetition(competitions);
    competitions = Pool.getSubList(competitions);
    return competitions;
  }
}