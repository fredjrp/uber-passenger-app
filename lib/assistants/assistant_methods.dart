import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:uber_user/assistants/request_assistant.dart';

import '../global/global.dart';
import '../global/map_key.dart';
import '../infoHandler/app_info_handler.dart';
import '../models/direction_details_info.dart';
import '../models/directions.dart';
import '../models/trips_history_model.dart';
import '../models/user_model.dart';

class AssistantMethods {
  static Future<String> searchAddressForGeographicCoOrdinates(Position position, context) async {
    final String apiUrl = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";
    String humanReadableAddress = "";

    final requestResponse = await RequestAssistant.receiveRequest(apiUrl);

    if (requestResponse is Map && requestResponse["results"] != null && requestResponse["results"].isNotEmpty) {
      humanReadableAddress = requestResponse["results"][0]["formatted_address"];

      final Directions userPickUpAddress = Directions(
        locationLatitude: position.latitude,
        locationLongitude: position.longitude,
        locationName: humanReadableAddress,
      );

      Provider.of<AppInfoHandler>(context, listen: false).updatePickUpLocationAddress(userPickUpAddress);
    }

    return humanReadableAddress;
  }

  static Future<void> readCurrentOnlineUserInfo() async {
    currentFirebaseUser = fAuth.currentUser;
    if (currentFirebaseUser == null) return;

    final DatabaseReference userRef = FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(currentFirebaseUser!.uid);
    
    final DatabaseEvent event = await userRef.once();
    if (event.snapshot.value != null) {
      userModelCurrentInfo = UserModel.fromSnapshot(event.snapshot);
    }
  }

  static Future<DirectionDetailsInfo?> obtainOriginToDestinationDirectionDetails(LatLng originPosition, LatLng destinationPosition) async {
    final String url = "https://maps.googleapis.com/maps/api/directions/json?origin=${originPosition.latitude},${originPosition.longitude}&destination=${destinationPosition.latitude},${destinationPosition.longitude}&key=$mapKey";

    final response = await RequestAssistant.receiveRequest(url);

    if (response is String || response == null) {
      return null;
    }

    final route = response["routes"][0];
    final leg = route["legs"][0];

    return DirectionDetailsInfo(
      ePoints: route["overview_polyline"]["points"],
      distanceText: leg["distance"]["text"],
      distanceValue: leg["distance"]["value"],
      durationText: leg["duration"]["text"],
      durationValue: leg["duration"]["value"],
    );
  }

  static double calculateFareAmountFromOriginToDestination(DirectionDetailsInfo directionDetailsInfo) {
    final double timeTraveledFareAmountPerMinute = (directionDetailsInfo.durationValue! / 60) * 0.1;
    final double distanceTraveledFareAmountPerKilometer = (directionDetailsInfo.durationValue! / 1000) * 0.1;

    // USD
    final double totalFareAmount = timeTraveledFareAmountPerMinute + distanceTraveledFareAmountPerKilometer;

    return double.parse(totalFareAmount.toStringAsFixed(1));
  }

  static Future<void> sendNotificationToDriverNow(String deviceRegistrationToken, String userRideRequestId, context) async {
    final String destinationAddress = userDropOffAddress;

    final Map<String, String> headerNotification = {
      'Content-Type': 'application/json',
      'Authorization': cloudMessagingServerToken,
    };

    final Map bodyNotification = {
      "body": "Destination Address: \n$destinationAddress.",
      "title": "New Trip Request"
    };

    final Map dataMap = {
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "id": "1",
      "status": "done",
      "rideRequestId": userRideRequestId
    };

    final Map officialNotificationFormat = {
      "notification": bodyNotification,
      "data": dataMap,
      "priority": "high",
      "to": deviceRegistrationToken,
    };
    
    await http.post(
      Uri.parse("https://fcm.googleapis.com/fcm/send"),
      headers: headerNotification,
      body: jsonEncode(officialNotificationFormat),
    );
  }

  static Future<void> readTripsKeysForOnlineUser(context) async {
    if (userModelCurrentInfo == null) return;

    final DatabaseEvent event = await FirebaseDatabase.instance.ref()
        .child("All Ride Requests")
        .orderByChild("userName")
        .equalTo(userModelCurrentInfo!.name)
        .once();

    if (event.snapshot.value != null) {
      final Map keysTripsId = event.snapshot.value as Map;

      // Count total number trips and share it with Provider
      final int overAllTripsCounter = keysTripsId.length;
      Provider.of<AppInfoHandler>(context, listen: false).updateOverAllTripsCounter(overAllTripsCounter);

      // Share trips keys with Provider
      final List<String> tripsKeysList = keysTripsId.keys.cast<String>().toList();
      Provider.of<AppInfoHandler>(context, listen: false).updateOverAllTripsKeys(tripsKeysList);

      // Get trips keys data
      await readTripsHistoryInformation(context);
    }
  }

  static Future<void> readTripsHistoryInformation(context) async {
    final tripsAllKeys = Provider.of<AppInfoHandler>(context, listen: false).historyTripsKeysList;
    
    final List<Future> futures = [];
    for (String eachKey in tripsAllKeys) {
      futures.add(
        FirebaseDatabase.instance.ref()
            .child("All Ride Requests")
            .child(eachKey)
            .once()
            .then((event) {
          if (event.snapshot.value != null) {
            final eachTripHistory = TripsHistoryModel.fromSnapshot(event.snapshot);
            final data = event.snapshot.value as Map;
            if (data["status"] == "ended") {
              Provider.of<AppInfoHandler>(context, listen: false).updateOverAllTripsHistoryInformation(eachTripHistory);
            }
          }
        })
      );
    }
    await Future.wait(futures);
  }
}