import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:homeraces/model/user.dart';
import 'package:http/http.dart' as http;
import 'package:postgres/postgres.dart';

class DBService{

  //String api = "https://home-races.web.app";
  String api = "http://88.15.140.153:3000";
  String ipUrl = "https://api.ipify.org?format=json";
  String locIpUrl = "https://ipapi.co/";
  static User userF;

  Future<User> getUserData(String id) async{
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
      );
      userF = user;
      return user;
    }
    return null;
  }

  Future createUser(User user)async{
    user.device = "ANDROID"; //SACARLO DE ALGUNA FORMA
    var formatter = new DateFormat('dd/MM/yyyy');
    var result = await http.get(ipUrl, headers: {});
    user.ip = json.decode(result.body)['ip'];
    result = await http.get("$locIpUrl${user.ip}/json/", headers: {});
    user.iplocalization = json.decode(result.body);
    user.locality = user.iplocalization["city"];
    user.registerdate = DateTime.now();
    Map body = {
      "id": user.id,
      "username": user.username == null ? "null": user.username,
      "firstname": user.firstname,
      "lastname": user.lastname,
      "email": user.email,
      "password": user.password == null ? "null": user.password,
      "device": user.device,
      "ip": user.ip,
      "iplocalization": user.iplocalization.toString(),
      "service": user.service,
      "birthdate": user.birthdate == null? "null" : formatter.format(user.birthdate),
      "locality": user.locality,
      "sex": user.sex == null ? "null" : user.sex
    };
    user = user;
    var response = await http.post("$api/users", body: body);
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
    var response = await http.get("$api/username", headers: {"username": username});
    print(response.body);
    var aux = json.decode(response.body);
    if(aux[0]['username'] == null)
      return false;
    else
      return true;
  }
}