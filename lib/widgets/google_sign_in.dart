

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../main.dart';

signInWithGoogle() async {
  try{
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    if(googleUser!=null){
      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      // Once signed in, return the UserCredential
      final user = await FirebaseAuth.instance.signInWithCredential(credential);

      return user;
    }else{
      return null;
    }

  }catch(e){
    print("object");
  }
}

signOut() async {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final GoogleSignIn googleUser = await GoogleSignIn(scopes: <String>["email"]);

  await _firebaseAuth.signOut();
  googleUser.signOut();

//  storage.write('login', false);
}