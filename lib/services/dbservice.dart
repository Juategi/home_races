import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:homeraces/model/user.dart';
import 'package:http/http.dart' as http;

class DBService{

  String api = "https://home-races.web.app";
  //String api = "http://88.15.140.153:5000";
  String ipUrl = "https://api.ipify.org?format=json";
  String locIpUrl = "https://ipapi.co/";
  static User _user;

  Future getUserdata(String id) async{
    var response = await http.get("$api/users", headers: {"id":id});
    print(response.body);
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
      "password": user.password,
      "device": user.device,
      "ip": user.ip,
      "iplocalization": user.iplocalization.toString(),
      "service": user.service,
      "birthdate": formatter.format(user.birthdate),
      "locality": user.locality
    };
    var response = await http.post("$api/users", body: body);
    print(response.body);
  }
}