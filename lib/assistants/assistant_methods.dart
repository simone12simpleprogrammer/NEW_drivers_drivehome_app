import 'dart:async';

import 'package:drivers_app/assistants/request_assistant.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../global/global.dart';


import 'package:drivers_app/global/map_key.dart';
import 'package:drivers_app/infoHandler/app_info.dart';
import 'package:drivers_app/models/direction_datails_info.dart';
import 'package:drivers_app/models/directions.dart';
import 'package:stream_transform/stream_transform.dart';
import '../models/trips_history_model.dart';

class AssistantMethods
{
  static Future<String> searchAddressForGeographicCoOrdinates(Position position,context) async
  {
    String apiUrl = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";
    String humanReadableAddress = "";

    var requestResponse = await RequestAssistant.reciveRequest(apiUrl);

    if(requestResponse != "Si è verificato un errore. Nessuna risposta.") //NON CAMBIARE MAI
    {
      humanReadableAddress = requestResponse ["results"][0]["formatted_address"];

      Directions userPickUpAddress = Directions();
      userPickUpAddress.locationLatitude = position.latitude;
      userPickUpAddress.locationLongitude = position.longitude;
      userPickUpAddress.locationName = humanReadableAddress;

      Provider.of<AppInfo>(context, listen: false).updatePickUpLocationAddress(userPickUpAddress);
    }

    return humanReadableAddress;
  }

  static Future<DirectionDetailsInfo?> obtainOriginToDestinationDirectionDetails(LatLng originPosition, LatLng destinationPosition) async
  {
    String urlOriginToDestinationDirectionDetails = "https://maps.googleapis.com/maps/api/directions/json?origin=${originPosition.latitude},${originPosition.longitude}&destination=${destinationPosition.latitude},${destinationPosition.longitude}&key=$mapKey";

    await Future.delayed(Duration(seconds: 8));


    var responseDirectionApi = await RequestAssistant.reciveRequest(urlOriginToDestinationDirectionDetails);
    print('Eseguito Chiamata DIRECTIONS API BASTARDA::::::::::::::::::::::::::::::::::::: OOOOOO ::::::::::::::::::::::::::::::::::::::::');
    if(responseDirectionApi == "Si è verificato un errore. Nessuna risposta.")
    {
      return null;
    }

    DirectionDetailsInfo directionDetailsInfo = DirectionDetailsInfo();
    directionDetailsInfo.e_points = responseDirectionApi["routes"][0]["overview_polyline"]["points"];

    directionDetailsInfo.distance_text = responseDirectionApi["routes"][0]["legs"][0]["distance"]["text"];
    directionDetailsInfo.distance_value = responseDirectionApi["routes"][0]["legs"][0]["distance"]["value"];

    directionDetailsInfo.duration_text = responseDirectionApi["routes"][0]["legs"][0]["duration"]["text"];
    directionDetailsInfo.duration_value = responseDirectionApi["routes"][0]["legs"][0]["duration"]["value"];

    return directionDetailsInfo;
  }

  static pauseLiveLocationUpdates()
  {
    streamSubscriptionPosition!.pause();
    Geofire.removeLocation(currentFirebaseUser!.uid);
  }

  static resumeLiveLocationUpdates()
  {
    streamSubscriptionPosition!.resume();
    Geofire.setLocation(
        currentFirebaseUser!.uid,
        driverCurrentPosition!.latitude,
        driverCurrentPosition!.longitude
    );
  }

  static double calculateFareAmountFromOriginToDestination(DirectionDetailsInfo directionDetailsInfo)
  {

    double timeTraveledFareAmountPerMinute = (directionDetailsInfo.duration_value! / 60) * 0.5; //50 CENT A MINUTO
    double timeTraveledFareAmountPerKilometer = (directionDetailsInfo.distance_value! / 1000) * 0.5;


    double totalFareAmount = timeTraveledFareAmountPerKilometer + timeTraveledFareAmountPerMinute;
    //double totalFareAmount = timeTraveledFareAmountPerKilometer + timeTraveledFareAmountPerMinute;
    // 1USD = 0.94 Euro al cambio d'oggi sbloccare il commento di sotto e ottieni prezzo in euro
    //double localCurrencyTotalFare = totalFareAmount * 0.94;

    print("QUESTO è IL COST NELL'ASSISTENT METHODS OOOOOOO00000000000000000000000000");
    print(totalFareAmount.toString());
    return double.parse(totalFareAmount.toStringAsFixed(2)); //
  }

  static void readTripKeysForOnlineDriver(context)
  {
    //recupero tutte le trips keys dal database per specifico utente (trip key = ride request key?
    FirebaseDatabase.instance.ref()
        .child("ALL Ride Requests")
        .orderByChild("driverId")
        .equalTo(fAuth.currentUser!.uid)
        .once()
        .then((snap)
    {
      if(snap.snapshot.value != null)
      {
        Map keysTripsId = snap.snapshot.value as Map;

        //count total trips and share it with Provider  (app_info.dart)
        int overAllTripsCounter = keysTripsId.length;
        Provider.of<AppInfo>(context, listen: false).updateOverAllTripsCounter(overAllTripsCounter);

        //share trips keys with Provider
        List<String> tripsKeysList = [];
        keysTripsId.forEach((key, value)   //ciclo for each
        {
          tripsKeysList.add(key);
        });
        Provider.of<AppInfo>(context, listen: false).updateOverAllTripsKeys(tripsKeysList);

        //Obtain the complete information of the trips history (userOriginAddress / destinationAdddress / driverName / exc....)
        readTripsHistoryInformation(context);
      }
    });
  }

  static void readTripsHistoryInformation(context)
  {
    var tripsAllKeys = Provider.of<AppInfo>(context, listen: false).historyTripsKeysList;

    for(String eachKey in tripsAllKeys)
    {
      FirebaseDatabase.instance.ref()
          .child("ALL Ride Requests")
          .child(eachKey)
          .once()
          .then((snap)
      {
        var eachTripsHistory = TripsHistoryModel.fromSnapshot(snap.snapshot);

        if((snap.snapshot.value as Map)["status"] == "ended")
        {
          //update-add each history to OverAllTrips History Data List
          Provider.of<AppInfo>(context, listen: false).updateOverAllTripsHistoryInformation(eachTripsHistory);
        }

      });
    }
  }

  //read driver earnings
  static void readDriverEarnings(context)
  {
    FirebaseDatabase.instance.ref()
        .child("drivers")
        .child(fAuth.currentUser!.uid)
        .child("earnings")
        .once()
        .then((snap)
    {
      if(snap.snapshot.value != null)
      {
        String driverEarnings = snap.snapshot.value.toString();
        Provider.of<AppInfo>(context,listen: false).updateDriverTotalEarnings(driverEarnings);
      }
    });

    readTripKeysForOnlineDriver(context);
  }

  static void readDriverRatings(context)
  {
    FirebaseDatabase.instance.ref()
        .child("drivers")
        .child(fAuth.currentUser!.uid)
        .child("ratings")
        .once()
        .then((snap)
    {
      if(snap.snapshot.value != null)
      {
        String driverRatings = snap.snapshot.value.toString();
        Provider.of<AppInfo>(context,listen: false).updateDriverAverageRatings(driverRatings);
      }
    });

  }
}