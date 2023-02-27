import 'package:firebase_database/firebase_database.dart';

class TripsHistoryModel
{
  String? time;
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
    this.time
  });

  TripsHistoryModel.fromSnapshot(DataSnapshot dataSnapshot)
  {
    time = (dataSnapshot.value as Map)["time"];
    status = (dataSnapshot.value as Map)["status"];
    originAddress = (dataSnapshot.value as Map)["originAddress"];
    destinationAddress = (dataSnapshot.value as Map)["destinationAddress"];
    userName = (dataSnapshot.value as Map)["userName"];
    fareAmount = (dataSnapshot.value as Map)["fareAmount"];

  }

}