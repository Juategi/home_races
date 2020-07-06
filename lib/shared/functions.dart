class Functions{

  static String parseDate(DateTime date, bool wd){
    String day = date.day.toString();
    int monthInt = date.month;
    String month;
    String weekday;
    switch(monthInt){
      case 1: month = "Enero"; break;
      case 2: month = "Febrero"; break;
      case 3: month = "Marzo"; break;
      case 4: month = "Abril"; break;
      case 5: month = "Mayo"; break;
      case 6: month = "Junio"; break;
      case 7: month = "Julio"; break;
      case 8: month = "Agosto"; break;
      case 9: month = "Septiembre"; break;
      case 10: month = "Octubre"; break;
      case 11: month = "Noviembre"; break;
      case 12: month = "Diciembre"; break;
    }
    switch(date.weekday){
      case 1: weekday = "Lunes"; break;
      case 2: weekday = "Martes"; break;
      case 3: weekday = "Miércoles"; break;
      case 4: weekday = "Jueves"; break;
      case 5: weekday = "Viernes"; break;
      case 6: weekday = "Sábado"; break;
      case 7: weekday = "Domingo"; break;
    }

    return wd? "$weekday $day $month":"$day $month";
  }


  static String parseTime(DateTime date){
    String hour = date.hour.toString();
    String minutes = date.minute.toString();
    if(minutes == "0")
      minutes = "00";
    return "$hour:$minutes";
  }
}