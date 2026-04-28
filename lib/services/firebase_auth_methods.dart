import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:uber_user/global/global.dart';
import '../splashScreen/splash_screen.dart';

class FirebaseAuthMethods {
  final FirebaseAuth _auth;

  FirebaseAuthMethods(this._auth);

  Future<void> _saveUserData(User user) async {
    final Map<String, dynamic> userMap = {
      'id': user.uid,
      'name': user.displayName ?? '',
      'email': user.email ?? '',
      'phone': user.phoneNumber ?? '',
      'latitude': '',
      'longitude': '',
    };

    final DatabaseReference reference = FirebaseDatabase.instance.ref().child('users');
    await reference.child(user.uid).set(userMap);
    currentFirebaseUser = user;
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (err) {
      if (context.mounted) {
        showErrorSnackBar(context, err.message ?? 'An error occurred');
      }
    }
  }

  Future<void> signInWithGoogle({required BuildContext context}) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      if (googleAuth?.accessToken != null && googleAuth?.idToken != null) {
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken,
          idToken: googleAuth?.idToken,
        );

        final UserCredential userCredential = await _auth.signInWithCredential(credential);
        final User? user = userCredential.user;

        if (user != null) {
          await _saveUserData(user);
          
          final bool isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
          Fluttertoast.showToast(msg: isNewUser ? 'Account has been Created.' : 'Login successful.');
          
          if (context.mounted) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const MySplashScreen()));
          }
        }
      }
    } on FirebaseAuthException catch (err) {
      if (context.mounted) {
        showErrorSnackBar(context, err.message ?? 'An error occurred');
      }
    }
  }

  Future<void> signInWithFacebook({required BuildContext context}) async {
    try {
      final LoginResult loginResult = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile', 'user_birthday'],
      );

      if (loginResult.status == LoginStatus.success) {
        final OAuthCredential credential = FacebookAuthProvider.credential(loginResult.accessToken!.token);
        final UserCredential userCredential = await _auth.signInWithCredential(credential);
        final User? user = userCredential.user;

        if (user != null) {
          await _saveUserData(user);
          
          final bool isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
          Fluttertoast.showToast(msg: isNewUser ? 'Account has been Created.' : 'Login successful.');
          
          if (context.mounted) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const MySplashScreen()));
          }
        }
      }
    } on FirebaseAuthException catch (err) {
      if (context.mounted) {
        showErrorSnackBar(context, err.message ?? 'An error occurred');
      }
    } catch (e) {
      if (context.mounted) {
        showErrorSnackBar(context, e.toString());
      }
    }
  }
}