import 'dart:convert';
import 'package:homeraces/model/competition.dart';
import 'package:homeraces/services/pool.dart';
import 'package:intl/intl.dart';
import 'package:homeraces/model/user.dart';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;

class DBService{

  //String api = "https://home-races.web.app";
  String api = "http://88.15.140.219:3000";
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
        DateTime registerDate = DateTime(year, month, day);
        print(result['birthdate']);
        DateTime birthDate;
        if (result['birthdate'] != null) {
          year = int.parse(result['birthdate'].toString().substring(0, 4));
          month = int.parse(result['birthdate'].toString().substring(5, 7));
          day = int.parse(result['birthdate'].toString().substring(8, 10));
          birthDate = DateTime(year, month, day);
        }
        List<Competition> favorites = await DBService().getFavorites(result['id']);
        List<Competition> enrolled = await DBService().getEnrolled(result['id']);
        Pool.addCompetition(favorites);
        favorites = Pool.getSubList(favorites);
        Pool.addCompetition(enrolled);
        enrolled = Pool.getSubList(enrolled);
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
            enrolled: enrolled
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
      DateTime registerDate = DateTime(year, month, day);
      print(result['birthdate']);
      DateTime birthDate;
      if (result['birthdate'] != null) {
        year = int.parse(result['birthdate'].toString().substring(0, 4));
        month = int.parse(result['birthdate'].toString().substring(5, 7));
        day = int.parse(result['birthdate'].toString().substring(8, 10));
        birthDate = DateTime(year, month, day);
      }
      List<Competition> favorites = await DBService().getFavorites(result['id']);
      List<Competition> enrolled = await DBService().getEnrolled(result['id']);
      Pool.addCompetition(favorites);
      favorites = Pool.getSubList(favorites);
      Pool.addCompetition(enrolled);
      enrolled = Pool.getSubList(enrolled);
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
          enrolled: enrolled
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

  Future deleteFromFavorites(String userid, int competitionid) async{
    var response = await http.delete("$api/favorites", headers: {"userid": userid, "competitionid": competitionid.toString()});
    print(response.body);
  }

  Future addToFavorites(String userid, int competitionid) async{
    var response = await http.put("$api/favorites", headers: {"userid": userid, "competitionid": competitionid.toString()});
    print(response.body);
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

  Future<List<Competition>> _parseCompetitions(String body) async{
    List<Competition> competitions = List<Competition>();
    List<dynamic> result = json.decode(body);
    for (dynamic element in result){
      int year = int.parse(element['eventdate'].toString().substring(0,4));
      int month = int.parse(element['eventdate'].toString().substring(5,7));
      int day = int.parse(element['eventdate'].toString().substring(8,10));
      int hour = int.parse(element['eventtime'].toString().substring(0,2));
      int minute = int.parse(element['eventtime'].toString().substring(3,5));
      int second = int.parse(element['eventtime'].toString().substring(6,8));
      DateTime eventdate = DateTime(year,month,day,hour,minute,second);
      year = int.parse(element['maxdate'].toString().substring(0,4));
      month = int.parse(element['maxdate'].toString().substring(5,7));
      day = int.parse(element['maxdate'].toString().substring(8,10));
      hour = int.parse(element['maxtime'].toString().substring(0,2));
      minute = int.parse(element['maxtime'].toString().substring(3,5));
      second = int.parse(element['maxtime'].toString().substring(6,8));
      DateTime maxdate = DateTime(year,month,day,hour,minute,second);
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
        numcompetitors: int.parse(element['numcompetitors']),
        eventdate: eventdate,
        maxdate: maxdate,
        organizer: element['organizer']
      );
      competitions.add(competition);
    }
    return competitions;
  }
}