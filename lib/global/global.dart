import 'dart:async';
import 'dart:ui';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:drivers_app/models/driver_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';

import '../models/user_ride_request_information.dart';



final FirebaseAuth fAuth = FirebaseAuth.instance;
User? currentFirebaseUser;
StreamSubscription<Position>? streamSubscriptionPosition;
StreamSubscription<Position>? streamSubscriptionDriverLivePosition;
AssetsAudioPlayer audioPlayer = AssetsAudioPlayer();
Position? driverCurrentPosition;
Position? onlineDriverCurrentPosition;
DriverData onlineDriverData = DriverData();
UserRideRequestInformation? userRideRequestDetails;
String titleStarsRating = "Affidabile";
String hasDriverUploadedFile = "";
bool isDriverActive = true;
Color buttonColor = Colors.grey;
String statusText = "Clicca e Vai Online";
