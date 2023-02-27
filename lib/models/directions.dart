import 'dart:ffi';

class Directions
{
  String? humanReadableAddress;
  String? locationName;
  String? locationId;
  double? locationLatitude;
  double? locationLongitude;

  Directions({
    this.humanReadableAddress,
    this.locationId,
    this.locationName,
    this.locationLatitude,
    this.locationLongitude,
  });
}