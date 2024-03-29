
import 'package:homeraces/model/competition.dart';
import 'package:homeraces/model/follower.dart';
import 'package:homeraces/model/notification.dart';
import 'package:homeraces/model/timeless_competition_data.dart';

class User{
  String id, username, firstname, lastname, image, sex, locality, email, password, device, ip, facebooklinked, apprated, service, country;
  int numcomments, numcompetitions, weight, height, kmTotal, kmOfficial;
  DateTime  registerdate, birthdate;
  var iplocalization;
  List<Competition> enrolled, favorites;
  List<Follower> followers, following;
  List<NotificationUser> notifications;
  List<TimeLessData> tl;
  User({this.country, this.weight, this.height,this.locality, this.service,this.id,this.email,this.image,this.username,this.apprated,this.device,this.facebooklinked,this.firstname,
    this.ip,this.iplocalization,this.lastname,this.numcomments,this.numcompetitions,this.password,this.registerdate,this.birthdate,this.sex, this.favorites, this.enrolled, this.notifications,
    this.following, this.followers, this.kmOfficial, this.kmTotal, this.tl});
}