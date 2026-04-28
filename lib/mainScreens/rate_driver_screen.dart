import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:smooth_star_rating_nsafe/smooth_star_rating.dart';
import 'package:uber_user/main.dart';

import '../global/global.dart';

class RateDriverScreen extends StatefulWidget {
  final String? assignedDriverId;

  const RateDriverScreen({super.key, this.assignedDriverId});

  @override
  State<RateDriverScreen> createState() => _RateDriverScreenState();
}

class _RateDriverScreenState extends State<RateDriverScreen> {
  
  String getRatingTitle(double rating) {
    if (rating <= 1) return "Very Bad";
    if (rating <= 2) return "Bad";
    if (rating <= 3) return "Good";
    if (rating <= 4) return "Very Good";
    return "Excellent";
  }

  Future<void> submitRating() async {
    if (widget.assignedDriverId == null) return;

    final DatabaseReference rateDriverRef = FirebaseDatabase.instance.ref()
        .child("drivers")
        .child(widget.assignedDriverId!)
        .child("ratings");

    try {
      final DatabaseEvent event = await rateDriverRef.once();
      
      if (event.snapshot.value == null) {
        await rateDriverRef.set(countRatingStars.toString());
      } else {
        double pastRatings = double.parse(event.snapshot.value.toString());
        double newAverageRatings = (pastRatings + countRatingStars) / 2;
        await rateDriverRef.set(newAverageRatings.toStringAsFixed(1));
      }

      Fluttertoast.showToast(msg: "Rating submitted. Restarting...");
      if (mounted) {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) MyApp.restartApp(context);
        });
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              const Text(
                "Rate Trip Experience",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              const Divider(thickness: 1),
              const SizedBox(height: 20),
              SmoothStarRating(
                rating: countRatingStars,
                allowHalfRating: false,
                starCount: 5,
                color: Colors.green,
                borderColor: Colors.green,
                size: 46,
                onRatingChanged: (valueOfStars) {
                  setState(() {
                    countRatingStars = valueOfStars;
                    titleStarsRating = getRatingTitle(valueOfStars);
                  });
                },
              ),
              const SizedBox(height: 15),
              Text(
                titleStarsRating,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: submitRating,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text(
                  "Submit",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
