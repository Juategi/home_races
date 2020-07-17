class RaceData{
  int id, time, steps, distance;
  String userid, image, firstname, lastname, sex, competitionid;
  Map<int, int> partials;
  DateTime birthdate;
  RaceData({this.id,this.distance,this.userid,this.time,this.partials,this.steps, this.firstname, this.lastname, this.image, this.birthdate, this.sex, this.competitionid});
}