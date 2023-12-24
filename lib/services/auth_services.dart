import 'package:communityapp/helper/helper_function.dart';
import 'package:communityapp/services/database_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  //creating instance of the firebase
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  //sign in method
  Future signInWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      User user = (await _firebaseAuth.signInWithEmailAndPassword(
              email: email, password: password))
          .user!;
      if (user != null) {
        return true;
      }
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  //sign out method
  Future signOut() async {
    try {
      await HelperFunctions.saveUserLoggedInStatus(false);
      await HelperFunctions.saveUserEmailSF("");
      await HelperFunctions.saveUserNameSF("");
      await _firebaseAuth.signOut();
    } catch (e) {
      return null;
    }
  }

  //sign up method
  Future signUpUserWithCredentials(
    String fullName,
    String email,
    String password,
  ) async {
    try {
      User user = (await _firebaseAuth.createUserWithEmailAndPassword(
              email: email, password: password))
          .user!;
      if (user != null) {
        await DatabaseServices(uid: user.uid).savingUserData(fullName, email);
        return true;
      }
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }
}
