import 'package:homeraces/model/competition.dart';

class NotificationUser{
  String userid, message;
  int id;
  DateTime notificationDate;
  Competition competition;
  NotificationUser({this.id,this.userid,this.message,this.notificationDate, this.competition});
}