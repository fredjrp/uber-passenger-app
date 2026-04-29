import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:smooth_star_rating_nsafe/smooth_star_rating.dart';
import 'package:uber_user/main.dart';

import '../global/global.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SelectNearestActiveDriversScreen extends StatefulWidget {
  final DatabaseReference? referenceRideRequest;
  final String price;

  const SelectNearestActiveDriversScreen({
    super.key,
    this.referenceRideRequest,
    required this.price,
  });

  @override
  State<SelectNearestActiveDriversScreen> createState() => _SelectNearestActiveDriversScreenState();
}

class _SelectNearestActiveDriversScreenState extends State<SelectNearestActiveDriversScreen> {
  
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.white54,
        title: Text(
          localizations.nearestOnlineDrivers,
          style: const TextStyle(fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            widget.referenceRideRequest?.remove();
            Fluttertoast.showToast(msg: "You have cancelled the ride request.");
            MyApp.restartApp(context);
          },
        ),
      ),
      body: dList.isEmpty
          ? Center(
              child: Text(
                localizations.noNearestOnlineDriver,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: dList.length,
              itemBuilder: (BuildContext context, int index) {
                final driverData = dList[index] as Map;
                final carDetails = driverData["car_details"] as Map;
                final carType = carDetails["type"].toString();

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      chosenDriverId = driverData["id"].toString();
                    });
                    Navigator.pop(context, "driverChoosed");
                  },
                  child: Card(
                    color: Colors.grey,
                    elevation: 3,
                    shadowColor: Colors.green,
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      leading: Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Image.asset(
                          "assets/images/$carType.png",
                          width: 70,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.directions_car, size: 50),
                        ),
                      ),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            driverData["name"].toString(),
                            style: const TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            carDetails["car_model"].toString(),
                            style: const TextStyle(fontSize: 12, color: Colors.black54),
                          ),
                          SmoothStarRating(
                            rating: driverData["ratings"] == null ? 0.0 : double.parse(driverData["ratings"].toString()),
                            color: Colors.orange,
                            borderColor: Colors.black54,
                            allowHalfRating: true,
                            starCount: 5,
                            size: 15,
                          ),
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (tripDirectionDetailsInfo != null) ...[
                            Text(
                              tripDirectionDetailsInfo!.durationText ?? "",
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 12),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              tripDirectionDetailsInfo!.distanceText ?? "",
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54, fontSize: 12),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
