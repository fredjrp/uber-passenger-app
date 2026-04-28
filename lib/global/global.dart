import 'dart:async';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uber_user/models/direction_details_info.dart';
import 'package:uber_user/models/user_model.dart';
import 'package:url_launcher/url_launcher.dart';

// Firebase
final FirebaseAuth fAuth = FirebaseAuth.instance;
User? currentFirebaseUser;

// Stripe & FCM
const String stripePublishKey = "YOUR_STRIPE_PUBLISHABLE_KEY";
const String cloudMessagingServerToken = "YOUR_FCM_SERVER_KEY";

// Stream Subscriptions
StreamSubscription<Position>? streamSubscriptionPosition;
StreamSubscription<Position>? streamSubscriptionDriverLivePosition;

// Global State
AssetsAudioPlayer? audioPlayer = AssetsAudioPlayer();
Position? driverCurrentPosition;
String? driverVehicleType = "";
String titleStarsRating = "Good";
bool isDriverActive = false;
String statusText = "Now Offline";
Color buttonColor = Colors.grey;
List dList = []; // drivers data list
DirectionDetailsInfo? tripDirectionDetailsInfo;
UserModel? userModelCurrentInfo;
String? chosenDriverId = "";
String userDropOffAddress = "";
String driverCarDetails = "";
String driverName = "";
String driverPhone = "";
double countRatingStars = 0.0;

// Global Methods
void showErrorSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        textAlign: TextAlign.center,
      ),
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.redAccent,
    ),
  );
}

Future<void> callNumber(String phone) async {
  final Uri url = Uri.parse("tel:$phone");
  if (await canLaunchUrl(url)) {
    await launchUrl(url);
  }
}

// UI Constants - Theme Colors
const Color kPrimaryColor = Colors.orange;
const Color kSecondaryColor = Colors.purple;

// UI Constants - Radius
final BorderRadius kFullRoundedRadius = BorderRadius.circular(50);
final BorderRadius kRoundedRadius10 = BorderRadius.circular(10);
final BorderRadius kRoundedRadius15 = BorderRadius.circular(15);
final BorderRadius kRoundedRadius30 = BorderRadius.circular(30);
final BorderRadius kRoundedButtonRadius = BorderRadius.circular(30);

// UI Constants - Decoration
final BoxDecoration kContainerDecoration = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(10),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 10,
      offset: const Offset(0, 5),
    ),
  ],
);

// UI Constants - Padding
const EdgeInsets kPadding10 = EdgeInsets.all(10);
const EdgeInsets kPadding20 = EdgeInsets.all(20);
const EdgeInsets kPadding5 = EdgeInsets.all(5);

// UI Constants - Spacing
const SizedBox kSizedBox10 = SizedBox(height: 10);
const SizedBox kSizedBox20 = SizedBox(height: 20);
const SizedBox kSizedBox30 = SizedBox(height: 30);
const SizedBox kSizedBox50 = SizedBox(height: 50);
const SizedBox kSizedBox100 = SizedBox(height: 100);

// UI Constants - TextStyles
const TextStyle kTextSmallStyle = TextStyle(color: Colors.white, fontSize: 12);
const TextStyle kTextMediumStyle = TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900);
const TextStyle kTextLargeStyle = TextStyle(color: Colors.black54, fontSize: 32, fontWeight: FontWeight.w900);
const TextStyle kLabelStyle = TextStyle(color: Color(0xffB9B9B9), fontWeight: FontWeight.bold, fontSize: 16);

final InputBorder kUnderLineInputBorder = UnderlineInputBorder(borderSide: BorderSide(color: kPrimaryColor));
