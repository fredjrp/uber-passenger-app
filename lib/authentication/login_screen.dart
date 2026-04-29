import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uber_user/authentication/signup_screen.dart';
import 'package:uber_user/services/firebase_auth_methods.dart';
import 'package:uber_user/l10n/app_localizations.dart';

import '../global/global.dart';
import '../splashScreen/splash_screen.dart';
import '../widgets/progress_dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailTextEditingController = TextEditingController();
  final TextEditingController passwordTextEditingController = TextEditingController();

  Future<void> validateForm() async {
    final email = emailTextEditingController.text.trim();
    final password = passwordTextEditingController.text.trim();

    if (!email.contains('@')) {
      Fluttertoast.showToast(msg: 'Email address is not Valid.');
    } else if (password.isEmpty) {
      Fluttertoast.showToast(msg: 'Password is required.');
    } else {
      await loginUserNow();
    }
  }

  Future<void> loginUserNow() async {
    final localizations = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext c) => ProgressDialog(
        message: localizations.processingPleaseWait,
      ),
    );

    try {
      final UserCredential userCredential = await fAuth.signInWithEmailAndPassword(
        email: emailTextEditingController.text.trim(),
        password: passwordTextEditingController.text.trim(),
      );

      final User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        final DatabaseReference userRef = FirebaseDatabase.instance.ref().child('users');
        final DatabaseEvent event = await userRef.child(firebaseUser.uid).once();
        
        if (!mounted) return;

        if (event.snapshot.value != null) {
          currentFirebaseUser = firebaseUser;
          Fluttertoast.showToast(msg: localizations.loginSuccessful);
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (c) => const MySplashScreen()),
            (route) => false,
          );
        } else {
          Fluttertoast.showToast(msg: localizations.noRecordExistsWithRecord);
          await fAuth.signOut();
          Navigator.pop(context); // Remove progress dialog
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        Navigator.pop(context); // Remove progress dialog
        Fluttertoast.showToast(msg: '${localizations.error}: ${e.message}');
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Remove progress dialog
        Fluttertoast.showToast(msg: '${localizations.error}: ${e.toString()}');
      }
    }
  }

  @override
  void dispose() {
    emailTextEditingController.dispose();
    passwordTextEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.asset('assets/images/driver.png'),
              ),
              const SizedBox(height: 10),
              Text(
                localizations.loginAsAUser,
                style: const TextStyle(
                  fontSize: 26,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextField(
                controller: emailTextEditingController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.grey),
                decoration: const InputDecoration(
                  labelText: 'Email',
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 10),
                  labelStyle: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
              TextField(
                controller: passwordTextEditingController,
                keyboardType: TextInputType.text,
                obscureText: true,
                style: const TextStyle(color: Colors.grey),
                decoration: const InputDecoration(
                  labelText: 'Password',
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 10),
                  labelStyle: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: validateForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightGreenAccent,
                  foregroundColor: Colors.black,
                ),
                child: Text(
                  localizations.login,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  FirebaseAuthMethods(fAuth).signInWithGoogle(context: context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightGreenAccent,
                  foregroundColor: Colors.black,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    Text(
                      localizations.signInWithGoogle,
                      style: const TextStyle(fontSize: 18),
                    ),
                    const Spacer(),
                    Image.asset('assets/images/googleIcon.png', height: 30, width: 30),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  FirebaseAuthMethods(fAuth).signInWithFacebook(context: context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightGreenAccent,
                  foregroundColor: Colors.black,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    Text(
                      localizations.signInWithFacebook,
                      style: const TextStyle(fontSize: 18),
                    ),
                    const Spacer(),
                    Image.asset('assets/images/facebookIcon.png', height: 30, width: 30),
                  ],
                ),
              ),
              TextButton(
                child: Text(
                  localizations.doNotHaveAnAccount,
                  style: const TextStyle(color: Colors.grey),
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (c) => const SignUpScreen()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
