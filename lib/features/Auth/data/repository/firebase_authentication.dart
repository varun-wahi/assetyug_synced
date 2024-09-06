import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../presentation/pages/login_page.dart';

class AuthServices{
  //for authentication
  final FirebaseAuth _auth = FirebaseAuth.instance;


//      FOR LOGIN
Future<String> loginUser({required String email, required String password}) async {
  String res = "Some Error Occured";
  try{
    if(email.isNotEmpty || password.isNotEmpty){
      //Login user
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      res = "success";
      print("Login Successful");
    }else{
      res = "Please fill all the fields";
    }
    
  }
  on FirebaseAuthException catch (e) {
  if (e.code == 'weak-password') {
    return 'The password provided is too weak.';
  } else if (e.code == 'email-already-in-use') {
    return 'The account already exists for that email.';
  }
} catch (e) {
  return (e.toString());
}
  
  return res; 
}

Future<void> logoutUser() async {
    await _auth.signOut();
  }


}