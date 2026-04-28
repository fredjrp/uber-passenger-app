import '../models/active_nearby_available_drivers.dart';

class GeoFireAssistant {
  static List<ActiveNearbyAvailableDrivers> activeNearbyAvailableDriversList = [];

  static void deleteOfflineDriverFromList(String driverId) {
    activeNearbyAvailableDriversList.removeWhere((element) => element.driverId == driverId);
  }

  static void updateActiveNearbyAvailableDriverLocation(ActiveNearbyAvailableDrivers driverWhoMove) {
    final int index = activeNearbyAvailableDriversList.indexWhere((element) => element.driverId == driverWhoMove.driverId);

    if (index != -1) {
      activeNearbyAvailableDriversList[index].locationLatitude = driverWhoMove.locationLatitude;
      activeNearbyAvailableDriversList[index].locationLongitude = driverWhoMove.locationLongitude;
    }
  }
}