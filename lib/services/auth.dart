import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // sign in anon
  Future<User?> signInAnon() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      User? user = result.user;
      return user; // Return the user object if sign-in is successful
    } on FirebaseAuthException catch (e) {
      print(e.toString());
      return null; // Return null if there is an error
    }
  }

// sign in with email & password

// register with email & password

// sign out
}
