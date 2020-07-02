import 'dart:convert';
import 'package:homeraces/model/comment.dart';
import 'package:homeraces/model/competition.dart';
import 'package:homeraces/model/notification.dart';
import 'package:homeraces/services/pool.dart';
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
        print(result['birthdate']);
        DateTime birthDate;
        if (result['birthdate'] != null) {
          year = int.parse(result['birthdate'].toString().substring(0, 4));
          month = int.parse(result['birthdate'].toString().substring(5, 7));
          day = int.parse(result['birthdate'].toString().substring(8, 10));
          birthDate = DateTime(year, month, day).add(Duration(days: 1));
        }
        List<Competition> favorites = await DBService().getFavorites(result['id']);
        List<Competition> enrolled = await DBService().getEnrolled(result['id']);
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
            favorites: favorites,
            enrolled: enrolled,
            notifications: await DBService().getNotifications(result['id'])
        );
        userF = user;
        return user;
      }
    }
    else {
      return userF;
    }
  }

  Future<User> getUserDataChecker(String id) async{
    var response = await http.get("$api/users", headers: {"id":id});
    print(response.body);
    if(response.body != "[]") {
      var result = json.decode(response.body)[0];
      int year = int.parse(result['registerdate'].toString().substring(0, 4));
      int month = int.parse(result['registerdate'].toString().substring(5, 7));
      int day = int.parse(result['registerdate'].toString().substring(8, 10));
      DateTime registerDate = DateTime(year, month, day).add(Duration(days: 1));
      print(result['birthdate']);
      DateTime birthDate;
      if (result['birthdate'] != null) {
        year = int.parse(result['birthdate'].toString().substring(0, 4));
        month = int.parse(result['birthdate'].toString().substring(5, 7));
        day = int.parse(result['birthdate'].toString().substring(8, 10));
        birthDate = DateTime(year, month, day).add(Duration(days: 1));
      }
      List<Competition> favorites = await DBService().getFavorites(result['id']);
      List<Competition> enrolled = await DBService().getEnrolled(result['id']);
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
          favorites: favorites,
          enrolled: enrolled,
          notifications: await DBService().getNotifications(result['id'])
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
      "image": user.image == null ? "null": user.image
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
    user.locality = user.iplocalization["city"];
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
      "birthdate": user.birthdate == null? "null" : user.birthdate,
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

  Future createCompetition(Competition competition, String organizerid)async{
    Map body = {
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
      "duration": competition.duration.toString(),
      "gallery": competition.gallery.toString().replaceAll("[", "{").replaceAll("]", "}") ?? List<String>().toString(),
      "eventdate": competition.eventdate.toString().substring(0,10),
      "eventtime": competition.eventdate.toString().substring(11,19),
      "maxdate": competition.maxdate.toString().substring(0,10),
      "maxtime": competition.maxdate.toString().substring(11,19),
    };
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
    await DBService().addToFavorites(organizerid, competition.id);
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
    print(response.body);
    List<Competition> aux = await _parseCompetitions(response.body);
    return aux.first;
  }

  Future<List<Competition>> getFavorites(String id) async{
    var response = await http.get("$api/favorites", headers: {"id": id});
    print(response.body);
    return await _parseCompetitions(response.body);
  }

  Future<List<Competition>> getEnrolled(String id) async{
    var response = await http.get("$api/competitions", headers: {"id": id});
    print(response.body);
    return await _parseCompetitions(response.body);
  }

  Future<List<Competition>> getPromoted(String locality, int limit) async{
    var response = await http.get("$api/promoted", headers: {"locality": locality, "limit": limit.toString()});
    print(response.body);
    return await _parseCompetitions(response.body);
  }
  Future<List<Competition>> getPopular(String locality, int limit) async{
    var response = await http.get("$api/popular", headers: {"locality": locality, "limit": limit.toString()});
    print(response.body);
    return await _parseCompetitions(response.body);
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
    if(comment.parentid != null)
      await DBService().createNotification(comment.userid, "Alguien ha respondido tu comentario!", comment.competitionid.toString());
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

  Future<String> enrrollCompetition(User user, Competition competition)async{
    var result = await http.get(ipUrl, headers: {});
    String ip = json.decode(result.body)['ip'];
    result = await http.get("$locIpUrl${ip}/json/", headers: {});
    dynamic iplocalization = json.decode(result.body);
    Map body = {
      "userid": user.id,
      "competitionid": competition.id.toString(),
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
        notificationDate: _parseDate(element['ndate'].toString(), element['ntime'].toString()),
        competition: await DBService().getCompetitionById(element['competitionid'].toString())
      );
      notifications.add(notification);
    }
    return notifications;
  }

  Future deleteNotification(String id) async{
    var response = await http.delete("$api/notifications", headers: {"id": id});
    print(response.body);
  }

  Future createNotification(String userid, String message, String competitionid) async{
    var response = await http.post("$api/notifications", body: {"userid": userid, "message": message, "competitionid": competitionid});
    print(response.body);
  }

  Future<List<Competition>> query(String locality, String query, String option, int limit) async {
    query = "%" + removeDiacritics(query) + "%";
    var response = await http.get(
        "$api/search",
        headers: {"query": query, "option": option, "locality":locality.toUpperCase(), "limit": limit.toString()});
    return _parseCompetitions(response.body);
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
  Future<List<Competition>> _parseCompetitions(String body) async{
    List<Competition> competitions = List<Competition>();
    List<dynamic> result = json.decode(body);
    for (dynamic element in result){
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
        numcompetitors: element['numcompetitors'] == null? 0 :  int.parse(element['numcompetitors']),
        eventdate: _parseDate(element['eventdate'].toString(), element['eventtime'].toString()),
        maxdate: _parseDate(element['maxdate'].toString(), element['maxtime'].toString()),
        organizer: element['organizer'],
        duration: element['duration'],
        gallery: element['gallery'] == null ? List<String>() : List<String>.from(element['gallery']),
      );
      competitions.add(competition);
    }
    Pool.addCompetition(competitions);
    competitions = Pool.getSubList(competitions);
    return competitions;
  }
}