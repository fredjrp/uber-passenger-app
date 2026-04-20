import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:uber_user/global/global.dart';

import '../splashScreen/splash_screen.dart';

class FirebaseAuthMethods{
  final FirebaseAuth ? auth;
  FirebaseAuthMethods({this.auth});

  // email signup

   Future<void>signUpWithEmail({required String email,required String password,required BuildContext context})async{
    try{
     await auth!.createUserWithEmailAndPassword(email: email, password: password);
    }on FirebaseAuthException catch(err){
      showErrorSnackBar(context, err);
    }

  }
  Future<void>signInWithGoogle({required BuildContext context})async{
    try{
      final GoogleSignInAccount?googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;
      if(googleAuth?.accessToken!=null && googleAuth?.idToken !=null){
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken,
          idToken: googleAuth?.idToken,
        );
        UserCredential userCredential = await auth!.signInWithCredential(credential);
        if(userCredential.user !=null){
          if(userCredential.additionalUserInfo!.isNewUser){
            /// sign up processes here
            Map userMap =
            {
              "id": userCredential.user!.uid,
              "name": userCredential.user!.displayName,
              "email": userCredential.user!.email,
              "phone": userCredential.user!.phoneNumber ??"",
              "latitude":"",
              "longitude":""
            };

            DatabaseReference reference = FirebaseDatabase.instance.ref().child("users");
            reference.child(userCredential.user!.uid,).set(userMap);

            currentFirebaseUser = userCredential.user!;
            print(userCredential.user!.displayName.toString()+"  is the google login nane");
            Fluttertoast.showToast(msg: "Account has been Created.");
            Navigator.push(context, MaterialPageRoute(builder: (c)=> const MySplashScreen()));
          }else{
            ///login processes here
            Map userMap =
            {
              "id": userCredential.user!.uid,
              "name": userCredential.user!.displayName,
              "email": userCredential.user!.email,
              "phone": userCredential.user!.phoneNumber ??"",
              "latitude":"",
              "longitude":""
            };

            DatabaseReference reference = FirebaseDatabase.instance.ref().child("users");
            reference.child(userCredential.user!.uid,).set(userMap);
           currentFirebaseUser = userCredential.user!;
           Fluttertoast.showToast(msg: "Login successful.");
           Navigator.push(context, MaterialPageRoute(builder: (c)=> const MySplashScreen()));
          }
        }
      }
    }on FirebaseAuthException catch(err){
      showErrorSnackBar(context, err);
    }

  }
  Future<void>signInWithFacebook({required BuildContext context})async{
    try{
      final LoginResult loginResult = await FacebookAuth.instance.login(
        permissions: ['email','public_profile','user_birthday']
      );
      final OAuthCredential facebookAuthCredential =
        FacebookAuthProvider.credential(loginResult.accessToken!.token);

      await auth!.signInWithCredential(facebookAuthCredential);

      final userCredential =
      await auth!.signInWithCredential(facebookAuthCredential);

      if(userCredential.user !=null){
        if(userCredential.additionalUserInfo!.isNewUser){
          /// sign up processes here
          Map userMap =
          {
            "id": userCredential.user!.uid,
            "name": userCredential.user!.displayName,
            "email": userCredential.user!.email,
            "phone": userCredential.user!.phoneNumber??"",
            "latitude":"",
            "longitude":""
          };

          DatabaseReference reference = FirebaseDatabase.instance.ref().child("users");
          reference.child(userCredential.user!.uid,).set(userMap);

          currentFirebaseUser = userCredential.user!;
          print(userCredential.user!.displayName.toString()+"  is the facebook login nane");

          Fluttertoast.showToast(msg: "Account has been Created.");
          Navigator.push(context, MaterialPageRoute(builder: (c)=> const MySplashScreen()));
        }else{
          ///login processes here
           currentFirebaseUser = userCredential.user!;
           Map userMap =
           {
             "id": userCredential.user!.uid,
             "name": userCredential.user!.displayName,
             "email": userCredential.user!.email,
             "phone": userCredential.user!.phoneNumber??"",
             "latitude":"",
             "longitude":""
           };

           DatabaseReference reference = FirebaseDatabase.instance.ref().child("users");
           reference.child(userCredential.user!.uid,).set(userMap);

           currentFirebaseUser = userCredential.user!;
           print(userCredential.user!.displayName.toString()+"  is the facebook login nane");

           Fluttertoast.showToast(msg: "Account has been Created.");
           print(userCredential.user!.displayName.toString()+"  is the facebook login nane");
           Navigator.push(context, MaterialPageRoute(builder: (c)=> const MySplashScreen()));


        }
      }

    }on FirebaseAuthException catch(err){
      showErrorSnackBar(context, err.message);
    }

  }




}