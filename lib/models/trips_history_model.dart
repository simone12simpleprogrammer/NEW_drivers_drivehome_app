import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TripsHistoryModel
{
  String? time;
  String? originLat;
  String? originLng;
  String? destinationLat;
  String? destinationLng;
  String? originAddress;
  String? destinationAddress;
  String? status;
  String? fareAmount;
  String? userName;

  TripsHistoryModel({
    this.fareAmount,
    this.userName,
    this.destinationAddress,
    this.originAddress,
    this.status,
    this.time,
    this.originLat,
    this.originLng,
    this.destinationLat,
    this.destinationLng
  });

  TripsHistoryModel.fromSnapshot(DataSnapshot dataSnapshot)
  {
    time = (dataSnapshot.value as Map)["time"];
    status = (dataSnapshot.value as Map)["status"];
    originAddress = (dataSnapshot.value as Map)["originAddress"];
    destinationAddress = (dataSnapshot.value as Map)["destinationAddress"];
    userName = (dataSnapshot.value as Map)["userName"];
    fareAmount = (dataSnapshot.value as Map)["fareAmount"];
    originLat = (dataSnapshot.value as Map)["origin/latitude"];
    originLng = (dataSnapshot.value as Map)["origin/longitude"];
    destinationLat = (dataSnapshot.value as Map)["destination/latitude"];
    destinationLng = (dataSnapshot.value as Map)["destination/longitude"];
  }

}