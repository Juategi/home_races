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
  static User _user;

  Future<User> getUserData(String id) async{
    var response = await http.get("$api/users", headers: {"id":id});
    print(response.body);
    var result = json.decode(response.body);
    User user = User(
      id: result['id'],
      email: result['email'],
      birthdate: result['birthdate'],
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
      registerdate: result['registerdate'],
      sex: result['sex'],
      username: result['username'],
    );

    return user;
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
      "username": user.username,
      "firstname": user.firstname,
      "lastname": user.lastname,
      "email": user.email,
      "password": user.password,
      "device": user.device,
      "ip": user.ip,
      "iplocalization": user.iplocalization.toString(),
      "service": user.service,
      "birthdate": user.birthdate == null? "null" : formatter.format(user.birthdate),
      "locality": user.locality,
      "sex": user.sex == null ? "null" : user.sex
    };
    var response = await http.post("$api/users", body: body);
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
}