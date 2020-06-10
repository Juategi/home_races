import 'package:firebase_auth/firebase_auth.dart';
import 'package:homeraces/model/user.dart';
import 'package:homeraces/services/dbservice.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
//import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService{

  final FirebaseAuth _auth = FirebaseAuth.instance;

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
      await DBService().createUser(user);
      return user;
    } catch(e){
      print(e);
      return null;
    }
  }

  /*Future loginFB()async{
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
    //User fuser = _userFromFirebaseUser(credential.user);
    String picture = profile["picture"]["data"]["url"];
    //await DBService().createUser(fuser.uid,fuser.email, profile["name"],picture,"FB");
    //return fuser;
  }*/

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
    User finalUser = await DBService().getUserData(user.uid);
    if(finalUser != null) {
      finalUser.image = authResult.additionalUserInfo.profile['picture'];
      finalUser.service = "G";
      finalUser.firstname = authResult.additionalUserInfo.profile['given_name'];
      finalUser.lastname = authResult.additionalUserInfo.profile['family_name'];
      await DBService().deleteUser(finalUser);
      await DBService().createUser(finalUser);
    }
    else {
      finalUser = User(id: user.uid, email: user.email, image: authResult.additionalUserInfo.profile['picture'], service: "G", firstname: authResult.additionalUserInfo.profile['given_name'], lastname: authResult.additionalUserInfo.profile['family_name'] );
      //pantalla de username
    }
    return finalUser;
  }

  Future signOut() async{
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
      return null;
    }
    try{
      return await _auth.signOut();
    }catch(e){
      print(e);
      return null;
    }
  }
}