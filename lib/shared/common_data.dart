import 'package:flutter/material.dart';
import 'package:homeraces/model/competition.dart';

class CommonData{
  static final screenHeight = 781;
  static final screenWidth = 392;
  static final String defaultProfile = "https://happytravel.viajes/wp-content/uploads/2020/04/146-1468479_my-profile-icon-blank-profile-picture-circle-hd.png";
  static final String defaultCompetition = "https://firebasestorage.googleapis.com/v0/b/home-races.appspot.com/o/competition%2Fimages.png?alt=media&token=07f30ed7-dc30-4612-811e-5f65e4bafe59";
  static final Image defaultImageCompetition = Image.network(defaultCompetition);
  static Competition competition;
}