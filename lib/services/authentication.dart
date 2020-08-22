import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

class User {
  final String uid;

  User({this.uid});
}

//This class only contains the signature of the methods and this ensures minimal changes 
// if we decided to change from Firebase to something else.
abstract class BaseAuth {
  Future<void> signIn(String email, String password);

  Future<String> signUp(String email, String password);

  Future<FirebaseUser> getCurrentUser();

  Future<void> sendEmailVerification();

  Future<void> signOut();

  Future<bool> isEmailVerified();
}

// This is where we define what the methods in the abstract class do.
class Auth implements BaseAuth {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User _userFromFirebaseUser(FirebaseUser user) {
    return user != null ? User(uid: user.uid) : null;
  }

  Stream<User> get user {
    return _auth.onAuthStateChanged
    //.map((FirebaseUser user) => _userFromFirebaseUser(user));
    .map(_userFromFirebaseUser);
    }

  Future<void> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    } catch(e) {
      print(e.toString());
      return null;
    }
  }

  Future<String> signUp(String email, String password) async {
    try {
      AuthResult result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      FirebaseUser user = result.user;
      return user.uid;
      } catch(e) {
      print(e.toString());
      return null;
    }
  }

  Future<FirebaseUser> getCurrentUser() async {
    FirebaseUser user = await _auth.currentUser();
    return user;
  }

  Future<void> signOut() async {
    return _auth.signOut();
  }

  Future<void> sendEmailVerification() async {
    FirebaseUser user = await _auth.currentUser();
    user.sendEmailVerification();
  }

  Future<bool> isEmailVerified() async {
    FirebaseUser user = await _auth.currentUser();
    return user.isEmailVerified;
  }
}