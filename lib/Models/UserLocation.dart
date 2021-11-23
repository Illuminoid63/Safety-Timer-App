class UserLocation {
  final double latitude;
  final double longitude;

  UserLocation({this.latitude, this.longitude});

  String toString() => "Latitude: $latitude, Longitude: $longitude";

  Map<String, dynamic> toJson() {
    Map<String, dynamic> retVal = {"latitude": latitude, "longitude": longitude};

    return retVal;
  }
}
