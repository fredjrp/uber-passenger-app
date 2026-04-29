import 'package:flutter/material.dart';
import '../l10n/l10n.dart';
import '../models/directions.dart';
import '../models/trips_history_model.dart';

class AppInfoHandler extends ChangeNotifier {
  Directions? userPickUpLocation;
  Directions? userDropOffLocation;
  int countTotalTrips = 0;
  List<String> historyTripsKeysList = [];
  List<TripsHistoryModel> allTripsHistoryInformation = [];
  Locale? _locale = const Locale('en');

  Locale? get locale => _locale;

  void updatePickUpLocationAddress(Directions userPickUpAddress) {
    userPickUpLocation = userPickUpAddress;
    notifyListeners();
  }

  void updateDropOffLocationAddress(Directions dropOffAddress) {
    userDropOffLocation = dropOffAddress;
    notifyListeners();
  }

  void updateOverAllTripsCounter(int overAllTripsCounter) {
    countTotalTrips = overAllTripsCounter;
    notifyListeners();
  }

  void updateOverAllTripsKeys(List<String> tripsKeysList) {
    historyTripsKeysList = tripsKeysList;
    notifyListeners();
  }

  void updateOverAllTripsHistoryInformation(TripsHistoryModel eachTripHistory) {
    allTripsHistoryInformation.add(eachTripHistory);
    notifyListeners();
  }

  void setLocale(Locale loc) {
    if (!L10n.all.contains(loc)) return;
    _locale = loc;
    notifyListeners();
  }

  void clearLocale() {
    _locale = null;
    notifyListeners();
  }
}
