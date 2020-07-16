import 'package:homeraces/model/competition.dart';

class Pool{
  static List<Competition> competitions = List<Competition>();
  static List<int> ids = List<int>();

  static void addCompetition(List<Competition> list){
    for(Competition c in list){
      if(!ids.contains(c.id)){
        competitions.add(c);
        ids.add(c.id);
      }
    }
  }

  static List<Competition> getSubList(List<Competition> list){
    List<Competition> result = List<Competition>();
    for(Competition competition in list){
      if(ids.contains(competition.id)){
        result.add(competitions.firstWhere((c){
          return c.id == competition.id;
        }));
      }
    }
    return result;
  }
  static void clear(){
    competitions.clear();
    ids.clear();
  }

}