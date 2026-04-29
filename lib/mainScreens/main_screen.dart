import 'dart:async';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:uber_user/mainScreens/rate_driver_screen.dart';
import 'package:uber_user/mainScreens/search_places_screen.dart';
import 'package:uber_user/mainScreens/select_nearest_active_driver_screen.dart';
import 'package:uber_user/l10n/app_localizations.dart';

import '../assistants/assistant_methods.dart';
import '../assistants/geofire_assistant.dart';
import '../global/global.dart';
import '../infoHandler/app_info_handler.dart';
import '../models/active_nearby_available_drivers.dart';
import '../widgets/my_drawer.dart';
import '../widgets/pay_fare_amount_dialog.dart';
import '../widgets/progress_dialog.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final TextEditingController txtPrice = TextEditingController();
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController? newGoogleMapController;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  final GlobalKey<ScaffoldState> sKey = GlobalKey<ScaffoldState>();
  double searchLocationContainerHeight = 265;
  double waitingResponseFromDriverContainerHeight = 0;
  double assignedDriverInfoContainerHeight = 0;

  Position? userCurrentPosition;
  double bottomPaddingOfMap = 0;

  List<LatLng> pLineCoOrdinatesList = [];
  Set<Polyline> polyLineSet = {};
  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};

  String userName = "your Name";
  String userEmail = "your Email";

  bool openNavigationDrawer = true;
  bool activeNearbyDriverKeysLoaded = false;
  BitmapDescriptor? activeNearbyIcon;

  List<ActiveNearbyAvailableDrivers> onlineNearByAvailableDriversList = [];
  DatabaseReference? referenceRideRequest;
  String driverRideStatus = "Driver is Coming";
  StreamSubscription<DatabaseEvent>? tripRideRequestInfoStreamSubscription;
  String userRideRequestStatus = "";
  bool requestPositionInfo = true;

  void blackThemeGoogleMap() {
    newGoogleMapController?.setMapStyle('''
[
  {
    "elementType": "geometry",
    "stylers": [{"color": "#242f3e"}]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#746855"}]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [{"color": "#242f3e"}]
  },
  {
    "featureType": "administrative.locality",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#d59563"}]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#d59563"}]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [{"color": "#263c3f"}]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#6b9a76"}]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [{"color": "#38414e"}]
  },
  {
    "featureType": "road",
    "elementType": "geometry.stroke",
    "stylers": [{"color": "#212a37"}]
  },
  {
    "featureType": "road",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#9ca5b3"}]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [{"color": "#746855"}]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry.stroke",
    "stylers": [{"color": "#1f2835"}]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#f3d19c"}]
  },
  {
    "featureType": "transit",
    "elementType": "geometry",
    "stylers": [{"color": "#2f3948"}]
  },
  {
    "featureType": "transit.station",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#d59563"}]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [{"color": "#17263c"}]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#515c6d"}]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.stroke",
    "stylers": [{"color": "#17263c"}]
  }
]
    ''');
  }

  Future<void> locateUserPosition() async {
    final Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    userCurrentPosition = position;

    final LatLng latLngPosition = LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);
    final CameraPosition cameraPosition = CameraPosition(target: latLngPosition, zoom: 14);

    newGoogleMapController?.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    if (!mounted) return;
    
    await AssistantMethods.searchAddressForGeographicCoOrdinates(userCurrentPosition!, context);
    
    setState(() {
      userName = userModelCurrentInfo?.name ?? "User";
      userEmail = userModelCurrentInfo?.email ?? "Email";
    });

    initializeGeoFireListener();
  }

  @override
  void initState() {
    super.initState();
    dList = [];
    if (userModelCurrentInfo != null) {
      AssistantMethods.readTripsKeysForOnlineUser(context);
    }
  }

  @override
  void dispose() {
    txtPrice.dispose();
    tripRideRequestInfoStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> saveRideRequestInformation() async {
    referenceRideRequest = FirebaseDatabase.instance.ref().child("All Ride Requests").push();

    final appInfo = Provider.of<AppInfoHandler>(context, listen: false);
    final originLocation = appInfo.userPickUpLocation;
    final destinationLocation = appInfo.userDropOffLocation;

    final Map originLocationMap = {
      "latitude": originLocation!.locationLatitude.toString(),
      "longitude": originLocation.locationLongitude.toString(),
    };

    final Map destinationLocationMap = {
      "latitude": destinationLocation!.locationLatitude.toString(),
      "longitude": destinationLocation.locationLongitude.toString(),
    };

    final Map userInformationMap = {
      "origin": originLocationMap,
      "destination": destinationLocationMap,
      "time": DateTime.now().toString(),
      "userName": userModelCurrentInfo!.name,
      "userPhone": userModelCurrentInfo!.phone ?? "",
      "originAddress": originLocation.locationName,
      "destinationAddress": destinationLocation.locationName,
      "driverId": "waiting",
      "price": txtPrice.text
    };

    await referenceRideRequest!.set(userInformationMap);

    tripRideRequestInfoStreamSubscription = referenceRideRequest!.onValue.listen((eventSnap) async {
      final data = eventSnap.snapshot.value as Map?;
      if (data == null) return;

      if (data["car_details"] != null) {
        setState(() => driverCarDetails = data["car_details"].toString());
      }

      if (data["driverPhone"] != null) {
        setState(() => driverPhone = data["driverPhone"] ?? "");
      }

      if (data["driverName"] != null) {
        setState(() => driverName = data["driverName"].toString());
      }

      if (data["status"] != null) {
        userRideRequestStatus = data["status"].toString();
      }

      if (data["driverLocation"] != null) {
        final double driverLat = double.parse(data["driverLocation"]["latitude"].toString());
        final double driverLng = double.parse(data["driverLocation"]["longitude"].toString());
        final LatLng driverLatLng = LatLng(driverLat, driverLng);

        if (userRideRequestStatus == "accepted") {
          updateArrivalTimeToUserPickupLocation(driverLatLng);
        } else if (userRideRequestStatus == "arrived") {
          setState(() => driverRideStatus = "Driver has Arrived");
        } else if (userRideRequestStatus == "ontrip") {
          updateReachingTimeToUserDropOffLocation(driverLatLng);
        } else if (userRideRequestStatus == "ended") {
          if (data["price"] != null) {
            final double price = double.parse(data["price"].toString());
            if (!mounted) return;
            final response = await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext c) => PayFareAmountDialog(price: price),
            );

            if (response == "cashPayed") {
              if (data["driverId"] != null) {
                final String assignedDriverId = data["driverId"].toString();
                if (!mounted) return;
                Navigator.push(context, MaterialPageRoute(builder: (c) => RateDriverScreen(assignedDriverId: assignedDriverId)));
                referenceRideRequest!.onDisconnect();
                tripRideRequestInfoStreamSubscription?.cancel();
              }
            }
          }
        }
      }
    });

    onlineNearByAvailableDriversList = GeoFireAssistant.activeNearbyAvailableDriversList;
    searchNearestOnlineDrivers();
  }

  Future<void> updateArrivalTimeToUserPickupLocation(LatLng driverLatLng) async {
    if (!requestPositionInfo) return;
    requestPositionInfo = false;

    final LatLng userPickUpPosition = LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);
    final directionDetailsInfo = await AssistantMethods.obtainOriginToDestinationDirectionDetails(driverLatLng, userPickUpPosition);

    if (directionDetailsInfo != null && mounted) {
      setState(() {
        driverRideStatus = "${AppLocalizations.of(context)!.driverIsComing} :: ${directionDetailsInfo.durationText}";
      });
    }
    requestPositionInfo = true;
  }

  Future<void> updateReachingTimeToUserDropOffLocation(LatLng driverLatLng) async {
    if (!requestPositionInfo) return;
    requestPositionInfo = false;

    final dropOffLocation = Provider.of<AppInfoHandler>(context, listen: false).userDropOffLocation;
    final LatLng destinationPosition = LatLng(dropOffLocation!.locationLatitude!, dropOffLocation.locationLongitude!);

    final directionDetailsInfo = await AssistantMethods.obtainOriginToDestinationDirectionDetails(driverLatLng, destinationPosition);

    if (directionDetailsInfo != null && mounted) {
      setState(() {
        driverRideStatus = "Going towards Destination :: ${directionDetailsInfo.durationText}";
      });
    }
    requestPositionInfo = true;
  }

  Future<void> searchNearestOnlineDrivers() async {
    if (onlineNearByAvailableDriversList.isEmpty) {
      await referenceRideRequest!.remove();
      setState(() {
        polyLineSet.clear();
        markersSet.clear();
        circlesSet.clear();
        pLineCoOrdinatesList.clear();
      });

      Fluttertoast.showToast(msg: "No drivers available. Search again later.");
      Future.delayed(const Duration(milliseconds: 4000), () {
        if (mounted) MyApp.restartApp(context);
      });
      return;
    }

    await retrieveOnlineDriversInformation(onlineNearByAvailableDriversList);
    if (!mounted) return;
    
    final response = await Navigator.push(
      context,
      MaterialPageRoute(builder: (c) => SelectNearestActiveDriversScreen(
        referenceRideRequest: referenceRideRequest,
        price: txtPrice.text,
      )),
    );

    if (response == "driverChoosed") {
      final DatabaseEvent event = await FirebaseDatabase.instance.ref().child("drivers").child(chosenDriverId!).once();
      if (event.snapshot.value != null) {
        sendNotificationToDriverNow(chosenDriverId!);
        showWaitingResponseFromDriverUI();

        FirebaseDatabase.instance.ref().child("drivers").child(chosenDriverId!).child("newRideStatus").onValue.listen((eventSnapshot) {
          if (eventSnapshot.snapshot.value == "idle") {
            Fluttertoast.showToast(msg: "The driver has cancelled. Please choose another.");
            Future.delayed(const Duration(milliseconds: 3000), () {
              if (mounted) MyApp.restartApp(context);
            });
          } else if (eventSnapshot.snapshot.value == "accepted") {
            showUIForAssignedDriverInfo();
          }
        });
      } else {
        Fluttertoast.showToast(msg: "This driver does not exist. Try again.");
      }
    }
  }

  void showUIForAssignedDriverInfo() {
    setState(() {
      waitingResponseFromDriverContainerHeight = 0;
      searchLocationContainerHeight = 0;
      assignedDriverInfoContainerHeight = 250;
    });
  }

  void showWaitingResponseFromDriverUI() {
    setState(() {
      searchLocationContainerHeight = 0;
      waitingResponseFromDriverContainerHeight = 220;
    });
  }

  Future<void> sendNotificationToDriverNow(String driverId) async {
    await FirebaseDatabase.instance.ref().child("drivers").child(driverId).child("newRideStatus").set(referenceRideRequest!.key);

    final DatabaseEvent event = await FirebaseDatabase.instance.ref().child("drivers").child(driverId).child("token").once();
    if (event.snapshot.value != null && mounted) {
      final String token = event.snapshot.value.toString();
      await AssistantMethods.sendNotificationToDriverNow(token, referenceRideRequest!.key.toString(), context);
      Fluttertoast.showToast(msg: "Notification sent successfully.");
    } else {
      Fluttertoast.showToast(msg: "Please choose another driver.");
    }
  }

  Future<void> retrieveOnlineDriversInformation(List<ActiveNearbyAvailableDrivers> driversList) async {
    final DatabaseReference ref = FirebaseDatabase.instance.ref().child("drivers");
    for (final driver in driversList) {
      final DatabaseEvent event = await ref.child(driver.driverId.toString()).once();
      final data = event.snapshot.value as Map?;
      if (data != null) {
        final List names = dList.map((e) => e["name"]).toList();
        if (!names.contains(data["name"])) {
          dList.add(data);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    createActiveNearByDriverIconMarker();
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      key: sKey,
      drawer: SizedBox(
        width: 265,
        child: Theme(
          data: Theme.of(context).copyWith(canvasColor: Colors.black),
          child: MyDrawer(name: userName, email: userEmail),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
            mapType: MapType.normal,
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            initialCameraPosition: _kGooglePlex,
            polylines: polyLineSet,
            markers: markersSet,
            circles: circlesSet,
            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMap.complete(controller);
              newGoogleMapController = controller;
              blackThemeGoogleMap();
              setState(() => bottomPaddingOfMap = 240);
              locateUserPosition();
            },
          ),

          Positioned(
            top: 30,
            left: 14,
            child: GestureDetector(
              onTap: () {
                if (openNavigationDrawer) {
                  sKey.currentState!.openDrawer();
                } else {
                  MyApp.restartApp(context);
                }
              },
              child: CircleAvatar(
                backgroundColor: Colors.grey,
                child: Icon(openNavigationDrawer ? Icons.menu : Icons.close, color: Colors.black54),
              ),
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedSize(
              curve: Curves.easeIn,
              duration: const Duration(milliseconds: 120),
              child: Container(
                height: searchLocationContainerHeight,
                decoration: const BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.add_location_alt_outlined, color: Colors.grey),
                          const SizedBox(width: 12.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(localizations.from, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              Text(
                                Provider.of<AppInfoHandler>(context).userPickUpLocation != null
                                    ? "${Provider.of<AppInfoHandler>(context).userPickUpLocation!.locationName!.substring(0, 24)}..."
                                    : localizations.notGettingAddress,
                                style: const TextStyle(color: Colors.grey, fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Divider(height: 1, thickness: 1, color: Colors.grey),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () async {
                          final response = await Navigator.push(context, MaterialPageRoute(builder: (c) => const SearchPlacesScreen()));
                          if (response == "obtainedDropoff") {
                            setState(() => openNavigationDrawer = false);
                            await drawPolyLineFromOriginToDestination();
                          }
                        },
                        child: Row(
                          children: [
                            const Icon(Icons.add_location_alt_outlined, color: Colors.grey),
                            const SizedBox(width: 12.0),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(localizations.to, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                Text(
                                  Provider.of<AppInfoHandler>(context).userDropOffLocation != null
                                      ? Provider.of<AppInfoHandler>(context).userDropOffLocation!.locationName!
                                      : localizations.whereToGo,
                                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Divider(height: 1, thickness: 1, color: Colors.grey),
                      const SizedBox(height: 16),
                      TextField(
                        controller: txtPrice,
                        style: const TextStyle(color: Colors.grey),
                        decoration: InputDecoration(
                          labelText: localizations.price,
                          enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                          hintStyle: const TextStyle(color: Colors.grey, fontSize: 10),
                          labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          if (Provider.of<AppInfoHandler>(context, listen: false).userDropOffLocation != null) {
                            if (txtPrice.text.isNotEmpty) {
                              saveRideRequestInformation();
                            } else {
                              showErrorSnackBar(context, localizations.pleaseEnterYourPrice);
                            }
                          } else {
                            Fluttertoast.showToast(msg: "Please select destination location");
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        child: Text(localizations.requestARide),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: waitingResponseFromDriverContainerHeight,
              decoration: const BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Center(
                  child: AnimatedTextKit(
                    animatedTexts: [
                      FadeAnimatedText(localizations.waitingForResponseFromDriver, duration: const Duration(seconds: 6), textAlign: TextAlign.center, textStyle: const TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold)),
                      ScaleAnimatedText(localizations.pleaseWait, duration: const Duration(seconds: 10), textAlign: TextAlign.center, textStyle: const TextStyle(fontSize: 32, color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: assignedDriverInfoContainerHeight,
              decoration: const BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: Text(driverRideStatus, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white54))),
                    const SizedBox(height: 20),
                    const Divider(height: 2, thickness: 2, color: Colors.white54),
                    const SizedBox(height: 20),
                    Text(driverCarDetails, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Colors.white54)),
                    const SizedBox(height: 2),
                    Text(driverName, textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white54)),
                    const SizedBox(height: 20),
                    const Divider(height: 2, thickness: 2, color: Colors.white54),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () => callNumber(driverPhone),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.black54),
                        icon: const Icon(Icons.phone_android, size: 22),
                        label: Text(localizations.callDriver, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> drawPolyLineFromOriginToDestination() async {
    final appInfo = Provider.of<AppInfoHandler>(context, listen: false);
    final originPosition = appInfo.userPickUpLocation;
    final destinationPosition = appInfo.userDropOffLocation;

    final originLatLng = LatLng(originPosition!.locationLatitude!, originPosition.locationLongitude!);
    final destinationLatLng = LatLng(destinationPosition!.locationLatitude!, destinationPosition.locationLongitude!);

    showDialog(context: context, builder: (c) => ProgressDialog(message: AppLocalizations.of(context)!.pleaseWait));

    final directionDetailsInfo = await AssistantMethods.obtainOriginToDestinationDirectionDetails(originLatLng, destinationLatLng);
    if (!mounted) return;
    
    setState(() => tripDirectionDetailsInfo = directionDetailsInfo);
    Navigator.pop(context);

    if (directionDetailsInfo == null) return;

    final PolylinePoints pPoints = PolylinePoints();
    final List<PointLatLng> decodedPoints = pPoints.decodePolyline(directionDetailsInfo.ePoints!);

    pLineCoOrdinatesList.clear();
    if (decodedPoints.isNotEmpty) {
      for (final point in decodedPoints) {
        pLineCoOrdinatesList.add(LatLng(point.latitude, point.longitude));
      }
    }

    polyLineSet.clear();
    setState(() {
      polyLineSet.add(Polyline(
        color: Colors.purpleAccent,
        polylineId: const PolylineId("PolylineID"),
        jointType: JointType.round,
        points: pLineCoOrdinatesList,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      ));
    });

    final LatLngBounds bounds;
    if (originLatLng.latitude > destinationLatLng.latitude && originLatLng.longitude > destinationLatLng.longitude) {
      bounds = LatLngBounds(southwest: destinationLatLng, northeast: originLatLng);
    } else if (originLatLng.longitude > destinationLatLng.longitude) {
      bounds = LatLngBounds(southwest: LatLng(originLatLng.latitude, destinationLatLng.longitude), northeast: LatLng(destinationLatLng.latitude, originLatLng.longitude));
    } else if (originLatLng.latitude > destinationLatLng.latitude) {
      bounds = LatLngBounds(southwest: LatLng(destinationLatLng.latitude, originLatLng.longitude), northeast: LatLng(originLatLng.latitude, destinationLatLng.longitude));
    } else {
      bounds = LatLngBounds(southwest: originLatLng, northeast: destinationLatLng);
    }

    newGoogleMapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 65));

    setState(() {
      markersSet.add(Marker(
        markerId: const MarkerId("originID"),
        infoWindow: InfoWindow(title: originPosition.locationName, snippet: "Origin"),
        position: originLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
      ));
      markersSet.add(Marker(
        markerId: const MarkerId("destinationID"),
        infoWindow: InfoWindow(title: destinationPosition.locationName, snippet: "Destination"),
        position: destinationLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      ));
      circlesSet.add(Circle(
        circleId: const CircleId("originID"),
        fillColor: Colors.green,
        radius: 12,
        strokeWidth: 3,
        strokeColor: Colors.white,
        center: originLatLng,
      ));
      circlesSet.add(Circle(
        circleId: const CircleId("destinationID"),
        fillColor: Colors.red,
        radius: 12,
        strokeWidth: 3,
        strokeColor: Colors.white,
        center: destinationLatLng,
      ));
    });
  }

  void initializeGeoFireListener() {
    Geofire.initialize("activeDrivers");
    Geofire.queryAtLocation(userCurrentPosition!.latitude, userCurrentPosition!.longitude, 10)!.listen((map) {
      if (map == null) return;
      final callBack = map['callBack'];

      switch (callBack) {
        case Geofire.onKeyEntered:
          final activeDriver = ActiveNearbyAvailableDrivers(
            locationLatitude: map['latitude'],
            locationLongitude: map['longitude'],
            driverId: map['key'],
          );
          GeoFireAssistant.activeNearbyAvailableDriversList.add(activeDriver);
          if (activeNearbyDriverKeysLoaded) displayActiveDriversOnUsersMap();
          break;

        case Geofire.onKeyExited:
          GeoFireAssistant.deleteOfflineDriverFromList(map['key']);
          displayActiveDriversOnUsersMap();
          break;

        case Geofire.onKeyMoved:
          final activeDriver = ActiveNearbyAvailableDrivers(
            locationLatitude: map['latitude'],
            locationLongitude: map['longitude'],
            driverId: map['key'],
          );
          GeoFireAssistant.updateActiveNearbyAvailableDriverLocation(activeDriver);
          displayActiveDriversOnUsersMap();
          break;

        case Geofire.onGeoQueryReady:
          activeNearbyDriverKeysLoaded = true;
          displayActiveDriversOnUsersMap();
          break;
      }
      if (mounted) setState(() {});
    });
  }

  void displayActiveDriversOnUsersMap() {
    setState(() {
      markersSet.clear();
      final Set<Marker> driversMarkerSet = {};

      for (final driver in GeoFireAssistant.activeNearbyAvailableDriversList) {
        driversMarkerSet.add(Marker(
          markerId: MarkerId("driver${driver.driverId}"),
          position: LatLng(driver.locationLatitude!, driver.locationLongitude!),
          icon: activeNearbyIcon ?? BitmapDescriptor.defaultMarker,
          rotation: 360,
        ));
      }
      markersSet.addAll(driversMarkerSet);
    });
  }

  void createActiveNearByDriverIconMarker() {
    if (activeNearbyIcon == null && mounted) {
      const config = ImageConfiguration(size: Size(2, 2));
      BitmapDescriptor.fromAssetImage(config, "assets/images/mapCar.png").then((value) {
        if (mounted) setState(() => activeNearbyIcon = value);
      });
    }
  }
}
