import 'dart:async';
import 'dart:ui';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uber_user/models/direction_details_info.dart';
import 'package:uber_user/models/user_model.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/driver_data.dart';



final FirebaseAuth fAuth = FirebaseAuth.instance;
User? currentFirebaseUser;
var stripePublishKey = "YOUR_STRIPE_PUBLISHABLE_KEY";
StreamSubscription<Position>? streamSubscriptionPosition;
StreamSubscription<Position>? streamSubscriptionDriverLivePosition;
AssetsAudioPlayer ? audioPlayer = AssetsAudioPlayer();
Position? driverCurrentPosition;
String? driverVehicleType = "";
String titleStarsRating = "Good";
bool isDriverActive = false;
String statusText = "Now Offline";
Color buttonColor = Colors.grey;
List dList = []; // drivers keys list
DirectionDetailsInfo? tripDirectionDetailsInfo;
UserModel? userModelCurrentInfo;
String ? chosenDriverId = "";
String cloudMessagingServerToken = "YOUR_FCM_SERVER_KEY";
String userDropOffAddress = "";
String driverCarDetails="";
String driverName="";
String driverPhone="";
double countRatingStars=0.0;
void showErrorSnackBar(context,text){
  ScaffoldMessenger.of(context).showSnackBar( SnackBar(
    content: Container(
        child: Text(text,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),textAlign: TextAlign.center,)),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.redAccent,
  ));
}

void callNumber(String phone){
  launchUrl(Uri.parse("tel: $phone"));
}


const Color PRIMARY_COLOR =Colors.orange;
const Color SECONDARY_COLOR =Colors.purple;


BorderRadius fullRoundedRadius = BorderRadius.circular(50);
BorderRadius roundedRadiusBy10 = BorderRadius.circular(10);
BorderRadius roundedRadiusBy15 = BorderRadius.circular(15);
BorderRadius roundedRadiusBy30 = BorderRadius.circular(30);
BorderRadius roundedButtonRadius = BorderRadius.circular(30);

BoxDecoration containerDecoration = BoxDecoration(

    color: Colors.white,
    borderRadius: BorderRadius.circular(10)
);
const paddingBy10  = EdgeInsets.all(10);
const paddingBy20  = EdgeInsets.all(20);
const paddingBy5 = EdgeInsets.all(5);
SizedBox sizedBox10 = SizedBox(height: 10,);
SizedBox sizedBox20 = SizedBox(height: 20,);
SizedBox sizedBox30 = SizedBox(height: 30,);
SizedBox sizedBox50 = SizedBox(height: 50,);
SizedBox sizedBox100 = SizedBox(height: 100,);
const TextStyle textSmallStyle = TextStyle(color: Colors.white,fontSize: 12);
const TextStyle textMediumStyle = TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.w900,);
const TextStyle textLargeStyle = TextStyle(color: Colors.black54,fontSize: 32,fontWeight: FontWeight.w900,);
const TextStyle kLabelStyle = TextStyle(color: Color(0xffB9B9B9),fontWeight: FontWeight.bold,fontSize: 16);
var kUnderLineInputBorder = UnderlineInputBorder(borderSide: BorderSide(color: PRIMARY_COLOR));
