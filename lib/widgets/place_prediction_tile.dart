import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uber_user/widgets/progress_dialog.dart';

import '../assistants/request_assistant.dart';
import '../global/global.dart';
import '../infoHandler/app_info_handler.dart';
import '../models/directions.dart';
import '../models/predicted_places.dart';

class PlacePredictionTileDesign extends StatefulWidget {
  final PredictedPlaces? predictedPlaces;

  const PlacePredictionTileDesign({super.key, this.predictedPlaces});

  @override
  State<PlacePredictionTileDesign> createState() => _PlacePredictionTileDesignState();
}

class _PlacePredictionTileDesignState extends State<PlacePredictionTileDesign> {
  
  Future<void> getPlaceDirectionDetails(String? placeId, BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => const ProgressDialog(
        message: "Setting up drop-off, please wait...",
      ),
    );

    final String url = "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapKey";

    final response = await RequestAssistant.receiveRequest(url);

    if (!mounted) return;
    Navigator.pop(context); // Close progress dialog

    if (response is Map && response["status"] == "OK") {
      final result = response["result"];
      final Directions directions = Directions(
        locationName: result["name"],
        locationId: placeId,
        locationLatitude: result["geometry"]["location"]["lat"],
        locationLongitude: result["geometry"]["location"]["lng"],
      );

      Provider.of<AppInfoHandler>(context, listen: false).updateDropOffLocationAddress(directions);

      setState(() {
        userDropOffAddress = directions.locationName!;
      });

      Navigator.pop(context, "obtainedDropoff");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ElevatedButton(
        onPressed: () {
          getPlaceDirectionDetails(widget.predictedPlaces?.place_id, context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white12,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Row(
          children: [
            const Icon(Icons.location_on_outlined, color: Colors.white70),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.predictedPlaces?.main_text ?? "",
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.predictedPlaces?.secondary_text ?? "",
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Colors.white60),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
