import 'dart:async';
import 'package:drivers_app/assistants/assistant_methods.dart';
import 'package:drivers_app/push_notifications/notification_repository.dart';
import 'package:drivers_app/push_notifications/push_notification_system.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:drivers_app/global/global.dart';

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

      String humanReadableAddress = await AssistantMethods
          .searchAddressForGeographicCoOrdinates(
          driverCurrentPosition!, context);

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
    NotificationRepository().generateAndGetToken();
    NotificationRepository().initialize();



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
          onMapCreated: (GoogleMapController controller1)
          {
            _controllerGoogleMap.complete(controller1);
            newGoogleMapController = controller1;

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

    DatabaseReference ref = FirebaseDatabase.instance.ref()
        .child("drivers")
        .child(currentFirebaseUser!.uid)
        .child("newRideStatus");
    ref.onValue.listen((event) { });


  }


  updateDriversLocationAtRealTime()
  {


      streamSubscriptionPosition = Geolocator.getPositionStream()
          //.throttle(Duration(seconds: 13))
          .listen((Position position)
      {
          driverCurrentPosition = position;

          if(isDriverActive == true)
          {
              Geofire.setLocation(
                currentFirebaseUser!.uid,
                driverCurrentPosition!.latitude,
                driverCurrentPosition!.longitude
              );
          }

          LatLng latLng = LatLng(
              driverCurrentPosition!.latitude,
              driverCurrentPosition!.longitude,
          );

          newGoogleMapController!.animateCamera(CameraUpdate.newLatLng(latLng));
      });
  }


}
