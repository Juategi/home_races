
class User{
  String id, username, firstname, lastname, image, sex, locality, email, password, device, ip, facebooklinked, apprated, service;
  int numcomments, numcompetitions;
  DateTime  registerdate, birthdate;
  var iplocalization;
  User({this.locality, this.service,this.id,this.email,this.image,this.username,this.apprated,this.device,this.facebooklinked,this.firstname,this.ip,this.iplocalization,this.lastname,this.numcomments,this.numcompetitions,this.password,this.registerdate,this.birthdate,this.sex});
}