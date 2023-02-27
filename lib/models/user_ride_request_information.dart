import 'package:google_maps_flutter/google_maps_flutter.dart';

class UserRideRequestInformation
{
  LatLng? originLatLng;
  LatLng? destinationLatLng;
  String? originAddress;
  String? destinationAddress;
  String? rideRequestId;
  String? userName;
  String? userPhone;

  UserRideRequestInformation({
   this.userName,
   this.originLatLng,
   this.destinationLatLng,
   this.destinationAddress,
   this.originAddress,
   this.rideRequestId,
   this.userPhone,
});
}