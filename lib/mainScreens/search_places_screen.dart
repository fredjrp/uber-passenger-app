import 'package:flutter/material.dart';

import '../assistants/request_assistant.dart';
import '../global/global.dart';
import '../models/predicted_places.dart';
import '../widgets/place_prediction_tile.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SearchPlacesScreen extends StatefulWidget {
  const SearchPlacesScreen({super.key});

  @override
  State<SearchPlacesScreen> createState() => _SearchPlacesScreenState();
}

class _SearchPlacesScreenState extends State<SearchPlacesScreen> {
  List<PredictedPlaces> placesPredictedList = [];

  Future<void> findPlaceAutoCompleteSearch(String inputText) async {
    if (inputText.length > 1) {
      final String urlAutoCompleteSearch = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$inputText&key=$mapKey";

      final responseAutoCompleteSearch = await RequestAssistant.receiveRequest(urlAutoCompleteSearch);

      if (responseAutoCompleteSearch is Map && responseAutoCompleteSearch["status"] == "OK") {
        final List placePredictions = responseAutoCompleteSearch["predictions"];

        final List<PredictedPlaces> placePredictionsList = placePredictions
            .map((jsonData) => PredictedPlaces.fromJson(jsonData))
            .toList();

        if (mounted) {
          setState(() {
            placesPredictedList = placePredictionsList;
          });
        }
      }
    } else {
      if (mounted && placesPredictedList.isNotEmpty) {
        setState(() {
          placesPredictedList = [];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // Search place UI
          Container(
            height: 180,
            decoration: const BoxDecoration(
              color: Colors.black87,
              boxShadow: [
                BoxShadow(
                  color: Colors.white24,
                  blurRadius: 8,
                  spreadRadius: 0.5,
                  offset: Offset(0.7, 0.7),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 40.0),
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back, color: Colors.grey),
                      ),
                      Center(
                        child: Text(
                          localizations.searchSetDropOffLocation,
                          style: const TextStyle(
                            fontSize: 18.0,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, color: Colors.grey),
                      const SizedBox(width: 18.0),
                      Expanded(
                        child: TextField(
                          onChanged: (valueTyped) {
                            findPlaceAutoCompleteSearch(valueTyped);
                          },
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: "${localizations.searchHere}...",
                            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                            fillColor: Colors.white12,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Display place predictions result
          if (placesPredictedList.isNotEmpty)
            Expanded(
              child: ListView.separated(
                itemCount: placesPredictedList.length,
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.all(0),
                itemBuilder: (context, index) {
                  return PlacePredictionTileDesign(
                    predictedPlaces: placesPredictedList[index],
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return const Divider(
                    height: 1,
                    color: Colors.white24,
                    thickness: 1,
                  );
                },
              ),
            )
          else
            const Expanded(
              child: Center(
                child: Icon(Icons.search, size: 100, color: Colors.white10),
              ),
            ),
        ],
      ),
    );
  }
}
