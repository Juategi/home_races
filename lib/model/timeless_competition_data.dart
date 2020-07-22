import 'package:homeraces/model/competition.dart';
import 'package:homeraces/model/race_data.dart';

class TimeLessData{
  Competition competition;
  List<RaceData> raceData, userStats;
  TimeLessData({this.competition,this.raceData,this.userStats});
}