import 'package:firebase_database/firebase_database.dart';

class TripsHistoryModel {
  final String? time;
  final String? originAddress;
  final String? destinationAddress;
  final String? status;
  final String? fareAmount;
  final String? carDetails;
  final String? driverName;

  TripsHistoryModel({
    this.time,
    this.originAddress,
    this.destinationAddress,
    this.status,
    this.fareAmount,
    this.carDetails,
    this.driverName,
  });

  factory TripsHistoryModel.fromSnapshot(DataSnapshot snapshot) {
    final data = snapshot.value as Map?;
    return TripsHistoryModel(
      time: data?['time'],
      originAddress: data?['originAddress'],
      destinationAddress: data?['destinationAddress'],
      status: data?['status'],
      fareAmount: data?['fareAmount'],
      carDetails: data?['car_details'],
      driverName: data?['driverName'],
    );
  }
}