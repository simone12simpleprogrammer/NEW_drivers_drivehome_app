import 'dart:async';
import 'package:drivers_app/assistants/assistant_methods.dart';
import 'package:drivers_app/global/global.dart';
import 'package:drivers_app/infoHandler/app_info.dart';
import 'package:drivers_app/mainScreens/new_trip_screen.dart';
import 'package:drivers_app/models/user_ride_request_information.dart';
import 'package:drivers_app/push_notifications/notification_repository.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../assistants/black_theme_google_map.dart';

class HomeTabPage extends StatefulWidget {
  const HomeTabPage({Key? key}) : super(key: key);

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}



class _HomeTabPageState extends State<HomeTabPage> with AutomaticKeepAliveClientMixin
{
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController? newGoogleMapController;
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  checkIfNotificationPermissionAllowed() async
  {
    NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Notifiche CONCESSE');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('Notifiche Concesse PROVVISORIAMENTE');
    } else {
      print('NON CONCESSE NOTIFICHE');
      Fluttertoast.showToast(msg: "Abbiamo bisogno delle Notifiche!");
      openAppSettings();
    }
  }

  locateDriverPosition() async
  {

      Position cPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      driverCurrentPosition = cPosition;

      LatLng latLngPosition = LatLng(
          driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);
      CameraPosition cameraPosition = CameraPosition(
          target: latLngPosition, zoom: 14);

      newGoogleMapController!.animateCamera(
          CameraUpdate.newCameraPosition(cameraPosition));

      // ignore: use_build_context_synchronously
      String humanReadableAddress = await AssistantMethods.searchAddressForGeographicCoOrdinates(driverCurrentPosition!, context);

      AssistantMethods.readDriverRatings(context);
  }

  readCurrentDriverInformation() async
  {
    currentFirebaseUser = fAuth.currentUser;

    FirebaseDatabase.instance.ref()
        .child("drivers")
        .child(currentFirebaseUser!.uid)
        .once()
        .then((snap)
    {
      if(snap.snapshot.value != null)
      {
        //assegno i dati dal realtime database firebase alla model class
        onlineDriverData.id = (snap.snapshot.value as Map)["id"];
        onlineDriverData.name = (snap.snapshot.value as Map)["name"];
        onlineDriverData.phone = (snap.snapshot.value as Map)["phone"];
        onlineDriverData.email = (snap.snapshot.value as Map)["email"];

        print("ONLINE DRIVER ID :: ");
        print(onlineDriverData.id);
        print(onlineDriverData.name);
        print(onlineDriverData.phone);
        print(onlineDriverData.email);
      }

    });
    NotificationRepository().initialize();
    NotificationRepository().generateAndGetToken();



    AssistantMethods.readDriverEarnings(context);
  }

    @override
    void initState()
    {
      super.initState();

      checkIfNotificationPermissionAllowed();
      readCurrentDriverInformation();
      driverIsOnlineNow();
      updateDriversLocationAtRealTime();
    }




  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      children: [
        GoogleMap(
          mapType: MapType.normal,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomGesturesEnabled: true,
          zoomControlsEnabled: true,
          initialCameraPosition: _kGooglePlex,
          minMaxZoomPreference: const MinMaxZoomPreference(12, 20),
          onMapCreated: (GoogleMapController controller)
          {
            _controllerGoogleMap.complete(controller);
            newGoogleMapController = controller;

            //riga che chiama metodo per impostare la mappa NERA!
            blackThemeGoogleMap(newGoogleMapController);

            locateDriverPosition();
          },
        ),

      ],
    );
  }

  @override
  bool get wantKeepAlive => true;

  driverIsOnlineNow() async
  {

    print("NUOVO UPDATE ORA!  ");
    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    driverCurrentPosition = pos;

    Geofire.initialize("activeDrivers");


    Geofire.setLocation(
        currentFirebaseUser!.uid,
        driverCurrentPosition!.latitude,
        driverCurrentPosition!.longitude
    );

    var tripsAllKeys = Provider.of<AppInfo>(context, listen: false).historyTripsKeysList;

    for(String eachKey in tripsAllKeys)
    {
      print("questo sono i viaggi di sto trimone : $eachKey");
    }

    await rechargeTripBeforeDriverKilledApp();


  }

  rechargeTripBeforeDriverKilledApp()
  {
    DatabaseReference ref = FirebaseDatabase.instance.ref()
        .child("drivers")
        .child(currentFirebaseUser!.uid)
        .child("newRideStatus");
    ref.once().then((snapData)  {

      //1.CONTROLLARE LO STATO DEL DRIVER CON UN'IF E SE è ACCEPTED/ARRIVED/ONTRIP
      if(snapData.snapshot.value == "accepted" || snapData.snapshot.value == "arrived" || snapData.snapshot.value == "ontrip")
      {
        //2.TROVA TRA LE ALL RIDE REQUEST  QUELLA ASSEGNATA A LUI CON LO STESSO STATO
        String value = snapData.snapshot.value.toString();
        print("lo stato della corsa lasciata precedentemente è ::: $value");
        var tripsAllKeys = Provider.of<AppInfo>(context, listen: false).historyTripsKeysList;

        for(String eachKey in tripsAllKeys)
        {

          print("siamo dentro! questa è la keyDelTrip ::: $eachKey");
          FirebaseDatabase.instance.ref()
              .child("ALL Ride Requests")
              .child(eachKey)
              .once()
              .then((snap)
          {
            print("questo è il suo stato :: ${(snap.snapshot.value as Map)["status"]} !" );
            //var eachTripsHistory = TripsHistoryModel.fromSnapshot(snap.snapshot);
            String dateTimeFromDB;

            if((snap.snapshot.value as Map)["status"] == value)
            {

              print("TROVATA corsa con stato uguale");
              dateTimeFromDB = (snap.snapshot.value as Map)["time"];
              var dateOfTrip = DateTime.parse(dateTimeFromDB).toLocal();
              if(dateOfTrip.year == DateTime.now().year && dateOfTrip.month == DateTime.now().month && dateOfTrip.day == DateTime.now().day)
              {
                print("TROVATA corsa con DATA DI OGGI");

                //3.CARICARE LA RIDE REQUEST INFORMATION
                double originLat = double.parse((snap.snapshot.value! as Map)["origin"]["latitude"]);
                double originLng = double.parse((snap.snapshot.value! as Map)["origin"]["longitude"]);
                String originAddress = (snap.snapshot.value! as Map)["originAddress"];

                double destinationLat = double.parse((snap.snapshot.value! as Map)["destination"]["latitude"]);
                double destinationLng = double.parse((snap.snapshot.value! as Map)["destination"]["longitude"]);
                String destinationAddress = (snap.snapshot.value! as Map)["destinationAddress"];

                String userName = (snap.snapshot.value! as Map)["userName"];
                String userPhone = (snap.snapshot.value! as Map)["userPhone"];

                String? rideRequestId = snap.snapshot.key;

                //passo tutto alla classe MODEL UserRideRequestInformation
                UserRideRequestInformation userRideRequestDetails = UserRideRequestInformation();

                userRideRequestDetails.originLatLng = LatLng(originLat, originLng);
                userRideRequestDetails.originAddress = originAddress;

                userRideRequestDetails.destinationLatLng = LatLng(destinationLat, destinationLng);
                userRideRequestDetails.destinationAddress = destinationAddress;

                userRideRequestDetails.userName = userName;
                userRideRequestDetails.userPhone = userPhone;

                userRideRequestDetails.rideRequestId = rideRequestId;


                //4.ANDARE ALLA NEW TRIP SCREEN PER CREARE NUOVAMENTE POLYLINE E RICARICARE DATI
                Navigator.push(context, MaterialPageRoute(builder: (c)=> NewTripScreen(
                  userRideRequestDetails: userRideRequestDetails,
                )));

              }else{
                print("c'è una corsa interrotta precedentemente ma non nella data odierna!");
              }

            }else
            {
              print("nessuna corsa interrotta precedentemente!");

            }

          });
        }
      }

    });
  }

  sendTo()
  {

  }

  updateDriversLocationAtRealTime()
  {


      streamSubscriptionPosition = Geolocator.getPositionStream()
          //.throttle(Duration(seconds: 13))
          .listen((Position position)
      {
          driverCurrentPosition = position;


              Geofire.setLocation(
                currentFirebaseUser!.uid,
                driverCurrentPosition!.latitude,
                driverCurrentPosition!.longitude
              );


          LatLng latLng = LatLng(
              driverCurrentPosition!.latitude,
              driverCurrentPosition!.longitude,
          );

          newGoogleMapController!.animateCamera(CameraUpdate.newLatLng(latLng));

      });
  }


}
