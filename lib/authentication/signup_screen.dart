import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../global/global.dart';
import '../splashScreen/splash_screen.dart';
import '../widgets/progress_dialog.dart';
import 'package:uber_user/l10n/app_localizations.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController nameTextEditingController = TextEditingController();
  final TextEditingController emailTextEditingController = TextEditingController();
  final TextEditingController phoneTextEditingController = TextEditingController();
  final TextEditingController passwordTextEditingController = TextEditingController();

  Future<void> validateForm() async {
    final name = nameTextEditingController.text.trim();
    final email = emailTextEditingController.text.trim();
    final phone = phoneTextEditingController.text.trim();
    final password = passwordTextEditingController.text.trim();

    if (name.length < 3) {
      Fluttertoast.showToast(msg: 'Name must be at least 3 characters.');
    } else if (!email.contains('@')) {
      Fluttertoast.showToast(msg: 'Email address is not valid.');
    } else if (phone.isEmpty) {
      Fluttertoast.showToast(msg: 'Phone number is required.');
    } else if (password.length < 6) {
      Fluttertoast.showToast(msg: 'Password must be at least 6 characters.');
    } else {
      await saveUserInfoNow();
    }
  }

  Future<void> saveUserInfoNow() async {
    final localizations = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext c) => ProgressDialog(
        message: localizations.processingPleaseWait,
      ),
    );

    try {
      final UserCredential userCredential = await fAuth.createUserWithEmailAndPassword(
        email: emailTextEditingController.text.trim(),
        password: passwordTextEditingController.text.trim(),
      );

      final User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        final Map<String, dynamic> userMap = {
          'id': firebaseUser.uid,
          'name': nameTextEditingController.text.trim(),
          'email': emailTextEditingController.text.trim(),
          'phone': phoneTextEditingController.text.trim(),
          'latitude': '',
          'longitude': '',
        };

        final DatabaseReference reference = FirebaseDatabase.instance.ref().child('users');
        await reference.child(firebaseUser.uid).set(userMap);

        if (!mounted) return;

        currentFirebaseUser = firebaseUser;
        Fluttertoast.showToast(msg: localizations.accountHasBeenCreated);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (c) => const MySplashScreen()),
          (route) => false,
        );
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
    nameTextEditingController.dispose();
    emailTextEditingController.dispose();
    phoneTextEditingController.dispose();
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.asset('assets/images/driver.png'),
              ),
              const SizedBox(height: 10),
              Text(
                localizations.registerAsAuser,
                style: const TextStyle(
                  fontSize: 26,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextField(
                controller: nameTextEditingController,
                style: const TextStyle(color: Colors.grey),
                decoration: InputDecoration(
                  labelText: localizations.name,
                  enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 10),
                  labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
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
                controller: phoneTextEditingController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.grey),
                decoration: InputDecoration(
                  labelText: localizations.phone,
                  enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 10),
                  labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
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
                  localizations.createAccount,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              TextButton(
                child: Text(
                  localizations.alreadyHaveAnAccountLoginHere,
                  style: const TextStyle(color: Colors.grey),
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (c) => const LoginScreen()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
