import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/trips_history_model.dart';
import 'package:uber_user/l10n/app_localizations.dart';

class HistoryDesignUIWidget extends StatelessWidget {
  final TripsHistoryModel? tripsHistoryModel;

  const HistoryDesignUIWidget({super.key, this.tripsHistoryModel});

  String formatDateAndTime(String dateTimeFromDB) {
    DateTime dateTime = DateTime.parse(dateTimeFromDB);
    return "${DateFormat.MMMd().format(dateTime)}, ${DateFormat.y().format(dateTime)} - ${DateFormat.jm().format(dateTime)}";
  }

  @override
  Widget build(BuildContext context) {
    if (tripsHistoryModel == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Driver Name + Fare Amount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${AppLocalizations.of(context)!.history}: ${tripsHistoryModel!.driverName}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                "\$${tripsHistoryModel!.fareAmount}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.greenAccent,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Car details
          Row(
            children: [
              const Icon(Icons.directions_car_filled, color: Colors.white60, size: 20),
              const SizedBox(width: 8),
              Text(
                tripsHistoryModel!.carDetails ?? "Vehicle Info",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white60,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Origin Address
          _buildLocationRow(
            iconPath: "assets/images/origin.png",
            address: tripsHistoryModel!.originAddress ?? "",
            color: Colors.yellowAccent,
          ),

          const SizedBox(height: 15),

          // Destination Address
          _buildLocationRow(
            iconPath: "assets/images/destination.png",
            address: tripsHistoryModel!.destinationAddress ?? "",
            color: Colors.orangeAccent,
          ),

          const SizedBox(height: 20),

          // Date and Time
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              formatDateAndTime(tripsHistoryModel!.time!),
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationRow({required String iconPath, required String address, required Color color}) {
    return Row(
      children: [
        Image.asset(iconPath, height: 24, width: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            address,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, color: Colors.white70),
          ),
        ),
      ],
    );
  }
}
