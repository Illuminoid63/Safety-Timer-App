import 'dart:async';
import 'package:location/location.dart';
import '../Models/UserLocation.dart';

class LocationService {

  var location = Location();

  StreamController<UserLocation> _locationController =
      StreamController<UserLocation>();

  Stream<UserLocation> get locationStream => _locationController.stream;

  LocationService() {
    // Request permission to use location
    location.requestPermission().then((granted) {
      if (granted == PermissionStatus.granted) {
        // If granted listen to the onLocationChanged stream and emit over controller
        location.changeSettings(interval: 1000); //1 second
        location.onLocationChanged.listen((locationData) {
          if (locationData != null) {
            _locationController.add(UserLocation(
              latitude: locationData.latitude,
              longitude: locationData.longitude,
            ));
          }
        });
      }
    });
  }

}

Future<int> askLocationPermission() async {
  Location location = new Location();

  bool _serviceEnabled;
  PermissionStatus _permissionGranted;

  _serviceEnabled = await location.serviceEnabled();
  if (!_serviceEnabled) {
    _serviceEnabled = await location.requestService();
    if (!_serviceEnabled) {
      return 1;
    }
  }

  _permissionGranted = await location.hasPermission();
  if (_permissionGranted == PermissionStatus.denied) {
    _permissionGranted = await location.requestPermission();
    if (_permissionGranted != PermissionStatus.granted) {
      return 1;
    }
  }

  bool backgroundLocation;
  try {
    backgroundLocation = await location.enableBackgroundMode();
    if (!backgroundLocation) {
      return 2;
    }
  } catch (e) {
    return 2;
  }
  return 0;
}
