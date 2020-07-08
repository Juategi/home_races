import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:homeraces/model/user.dart';
import 'package:homeraces/services/dbservice.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService{

  final FirebaseAuth _auth = FirebaseAuth.instance;
  DBService _dbService = DBService();

  Stream<String> get user {
    return _auth.onAuthStateChanged.map((user){
      return user != null ? user.uid : null;
    });
  }

  Future logIn(String email, String password) async{
    try{
      AuthResult result =	await _auth.signInWithEmailAndPassword(email: email, password: password);
      FirebaseUser user = result.user;
      return user;
    } catch(e){
      print(e);
      return null;
    }
  }

  Future signUp(User user) async{
    try{
      AuthResult result =	await _auth.createUserWithEmailAndPassword(email: user.email, password: user.password);
      FirebaseUser fuser = result.user;
      user.id = fuser.uid;
      user.service = "E";
      await _dbService.createUser(user);
      return user;
    } catch(e){
      print(e);
      return e;
    }
  }

  Future loginFB()async{
    final facebookLogin = FacebookLogin();
    //facebookLogin.loginBehavior = FacebookLoginBehavior.webViewOnly;
    final result = await facebookLogin.logIn(['email']);
    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        print("Login Correct");
        break;
      case FacebookLoginStatus.cancelledByUser:
        print("Login cancelled by user");
        break;
      case FacebookLoginStatus.error:
        print(result.errorMessage);
        break;
    }
    final token = result.accessToken.token;
    final graphResponse = await http.get(
        'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email,picture.height(200)&access_token=$token');
    final profile = json.decode(graphResponse.body);
    final facebookAuthCred = FacebookAuthProvider.getCredential(accessToken: token);
    final credential = await _auth.signInWithCredential(facebookAuthCred);
    final FirebaseUser currentUser = credential.user;
    print(currentUser.email);
    User finalUser = await _dbService.getUserDataChecker(currentUser.uid);
    String email = "todotrofeoapps@gmail.com"; //ARREGLAR EL EMAIL CON FB
    if(finalUser != null) {
      finalUser.image = profile["picture"]["data"]["url"];
      finalUser.service = "F";
      finalUser.firstname = profile["first_name"];
      finalUser.lastname = profile["last_name"];
      await _dbService.updateUser(finalUser);
      return finalUser;
    }
    else{
      while(true){
        String username = profile["first_name"].toString().trim() + profile["last_name"].toString().trim() + (Random().nextInt(10000).toString());
        if(await _dbService.checkUsername(username)){
          username = profile["first_name"].toString().trim() + profile["last_name"].toString().trim() + (Random().nextInt(10000).toString());
        }
        else{
          finalUser = User(username: username, id: currentUser.uid, image: profile["picture"]["data"]["url"], firstname: profile["first_name"], lastname: profile["last_name"], service: "F", email: email);
          await _dbService.createUser(finalUser);
          return finalUser;
        }
      }
    }
  }

  Future loginGoogle()async{
    final GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: [
        'email',
        'https://www.googleapis.com/auth/userinfo.profile',
      ],
    );
    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final AuthResult authResult = await _auth.signInWithCredential(credential);
    final FirebaseUser user = authResult.user;
    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);
    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);
    User finalUser = await _dbService.getUserDataChecker(user.uid);
    if(finalUser != null) {
      finalUser.image = authResult.additionalUserInfo.profile['picture'];
      finalUser.service = "G";
      finalUser.firstname = authResult.additionalUserInfo.profile['given_name'];
      finalUser.lastname = authResult.additionalUserInfo.profile['family_name'];
      await _dbService.updateUser(finalUser);
      return finalUser;
    }
    else {
      while(true){
        String username = authResult.additionalUserInfo.profile['given_name'].toString().trim() + authResult.additionalUserInfo.profile['family_name'].toString().trim() + (Random().nextInt(10000).toString());
        if(await _dbService.checkUsername(username)){
          username = authResult.additionalUserInfo.profile['given_name'].toString().trim() + authResult.additionalUserInfo.profile['family_name'].toString().trim() + (Random().nextInt(10000).toString());
        }
        else {
          finalUser = User(username: username, id: user.uid, email: user.email, image: authResult.additionalUserInfo.profile['picture'], service: "G", firstname: authResult.additionalUserInfo.profile['given_name'], lastname: authResult.additionalUserInfo.profile['family_name'] );
          await _dbService.createUser(finalUser);
          return finalUser;
        }
      }
    }
  }

  Future changePassword(User user, String newPassword) async{
    try{
      FirebaseUser fuser = await _auth.currentUser();
      AuthCredential authCredential = EmailAuthProvider.getCredential(
        email: user.email,
        password: user.password,
      );
      AuthResult result = await fuser.reauthenticateWithCredential(authCredential);
      fuser = result.user;
      await fuser.updatePassword(newPassword);
      user.password = newPassword;
      await _dbService.updateUser(user);
    } catch(e){
      print(e);
    }
  }

  Future signOut() async{
    DBService.userF = null;
    try{
      final facebookLogin = FacebookLogin();
      facebookLogin.logOut();
    }catch(e){
      print(e);
      //return null;
    }
    try{
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: [
          'email',
          'https://www.googleapis.com/auth/userinfo.profile',
        ],
      );
      await googleSignIn.signOut();
    }catch(e){
      print(e);
      //return null;
    }
    try{
      return await _auth.signOut();
    }catch(e){
      print(e);
      //return null;
    }
    return null;
  }
}