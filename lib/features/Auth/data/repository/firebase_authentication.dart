import 'package:asset_yug_debugging/features/Auth/data/repository/auth_token_repository_impl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthServices {
  //for authentication
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthTokenRepositoryImpl _authTokenRepository =
      AuthTokenRepositoryImpl();

//      FOR LOGIN
  Future<String> loginUser(
      {required String email, required String password}) async {
    String res = "Some Error Occured";
    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        //Login user
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        res = "success";
        print("Login Successful");
      } else {
        res = "Please fill all the fields";
      }
    } on FirebaseAuthException catch (e) {
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

  Future<void> logoutUser(String userId) async {
    await _authTokenRepository.removeSession(userId);
    await _auth.signOut();
  }
}
