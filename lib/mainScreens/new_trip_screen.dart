import 'dart:async';
import 'dart:ui';

import 'package:drivers_app/global/global.dart';
import 'package:drivers_app/models/user_ride_request_information.dart';
import 'package:drivers_app/widgets/fare_amount_collection_dialog.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../assistants/assistant_methods.dart';
import '../assistants/black_theme_google_map.dart';
import '../models/direction_datails_info.dart';
import '../splashScreen/splash_screen.dart';
import '../widgets/progress_dialog.dart';

class NewTripScreen extends StatefulWidget
{
  UserRideRequestInformation? userRideRequestDetails;

  NewTripScreen({
    this.userRideRequestDetails,
  });

  @override
  State<NewTripScreen> createState() => _NewTripScreenState();
}


class _NewTripScreenState extends State<NewTripScreen>
{
  GoogleMapController? newTripGoogleMapController;
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  String? buttonTitle = "Arrivato";
  Color? buttonColor = Colors.green;

  Set<Marker> setOfMarkers = Set<Marker>();
  Set<Circle> setOfCircle = Set<Circle>();
  Set<Polyline> setOfPolyline = Set<Polyline>();
  List<LatLng> polyLinePositionCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

  double mapPadding = 0;
  BitmapDescriptor? iconAnimatedMarker;  //icona che si muove del driver
  var geoLocator = Geolocator();
  LatLng? currentDriverPositionLatLng;
  LatLng? currentDriverPositionLatLng4Arrived;
  LatLng? currentDriverPositionLatLng2;
  DirectionDetailsInfo? tripDirectionDetails;
  DirectionDetailsInfo? tripDirectionDetails2;
  String? rideRequestStatus;
  String durationFromOriginToDestination = "";
  bool isNewTrip = true;
  bool isRequestDirectionDetails = false;

  StreamSubscription<DatabaseEvent>? tripRideRequestInfoStreamSubscription;



  locateDriverPosition() async
  {

    Position cPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    driverCurrentPosition = cPosition;

    LatLng latLngPosition = LatLng(
        driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);
    CameraPosition cameraPosition = CameraPosition(
        target: latLngPosition, zoom: 14);

    newTripGoogleMapController!.animateCamera(
        CameraUpdate.newCameraPosition(cameraPosition));

    // ignore: use_build_context_synchronously
    String humanReadableAddress = await AssistantMethods.searchAddressForGeographicCoOrdinates(driverCurrentPosition!, context);

  }

  //Step 1:: Quando il driver accetta la richiesta di corsa.
  // originLatLng = posizione corrente del driver.
  // destinationLatLng = user pickup location.

  //Step 2:: Quando il driver è già salito nella macchina del cliente
  // originLatLng = user Pickup location => driver current Location.
  // destinationLatLng = user DropOff location.
  Future<void> drawPolyLineFromOriginToDestination(LatLng originLatLng, LatLng destinationLatLng) async  // Direction API CALL
  {
    showDialog(
      context: context,
      builder: (BuildContext context) => ProgressDialog(message: "Attendere...",),
    );

    var directionDetailsInfo = await AssistantMethods.obtainOriginToDestinationDirectionDetails(originLatLng, destinationLatLng);

    // ignore: use_build_context_synchronously
    Navigator.pop(context);

    PolylinePoints pPoints = PolylinePoints();
    List<PointLatLng> decodedPolyLinePointsResultList = pPoints.decodePolyline(directionDetailsInfo!.e_points!);

    polyLinePositionCoordinates.clear();

    if (decodedPolyLinePointsResultList.isNotEmpty)
    {
      for (var pointLatLng in decodedPolyLinePointsResultList) {
        polyLinePositionCoordinates.add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      }
    }

    setOfPolyline.clear();

    setState(() {
      Polyline polyline = Polyline(
        color: Colors.blueAccent,
        polylineId: const PolylineId("PolylineID"),
        jointType: JointType.round,
        points: polyLinePositionCoordinates,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      setOfPolyline.add(polyline);
    });

    LatLngBounds boundsLatLng;
    if(originLatLng.latitude > destinationLatLng.latitude && originLatLng.longitude > destinationLatLng.longitude)
    {
      boundsLatLng = LatLngBounds(southwest: destinationLatLng, northeast: originLatLng);
    }
    else if(originLatLng.longitude > destinationLatLng.longitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(originLatLng.latitude, destinationLatLng.longitude),
        northeast: LatLng(destinationLatLng.latitude, originLatLng.longitude),
      );
    }
    else if(originLatLng.latitude > destinationLatLng.latitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(destinationLatLng.latitude, originLatLng.longitude),
        northeast: LatLng(originLatLng.latitude, destinationLatLng.longitude),
      );
    }
    else
    {
      boundsLatLng = LatLngBounds(southwest: originLatLng, northeast: destinationLatLng);
    }

    newTripGoogleMapController!.animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 65));

    // Marker originMarker = Marker(
    //   markerId: const MarkerId("originID"),
    //   position: originLatLng,
    //   icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    // );

    Marker destinationMarker = Marker(
      markerId: const MarkerId("destinationID"),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    setState(() {
      //setOfMarkers.add(originMarker);
      setOfMarkers.add(destinationMarker);
    });
  }

  @override
  void initState() {
    super.initState();

    print("siamo dentro new TRIP SCREEN CDDDòòòòòò €€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€&&&&&&&&&&&&&&&&&&&&&");
   saveAssignedDriverDetailsToUserRideRequest();
   controlStateOfTrip();
  }

  createDriverIconMarker()
  {
    if(iconAnimatedMarker == null)
    {
      ImageConfiguration imageConfiguration = createLocalImageConfiguration(context, size: const Size(2, 2));
      BitmapDescriptor.fromAssetImage(imageConfiguration, "").then((value)
      //BitmapDescriptor.fromAssetImage(imageConfiguration, "images/bike.png").then((value)
      {
        iconAnimatedMarker = value;
      });
    }
  }

  getDriversLocationUpdatesAtRealTime()
  {
    LatLng oldLatLng = LatLng(0, 0);

    streamSubscriptionDriverLivePosition = Geolocator.getPositionStream()
        .listen((Position position)

    {
      driverCurrentPosition = position;
      onlineDriverCurrentPosition = position;

      LatLng latLngLiveDriverPosition = LatLng(
        onlineDriverCurrentPosition!.latitude,
        onlineDriverCurrentPosition!.longitude,
      );

       Marker animatingMarker = Marker(
         markerId: const MarkerId("AnimatedMarker"),
         position: latLngLiveDriverPosition,
         icon: iconAnimatedMarker!,
         infoWindow: const InfoWindow(title: "Questa è la tua posizione"),
       );

      setState(() {
        CameraPosition cameraPosition = CameraPosition(target: latLngLiveDriverPosition, zoom: 16);
        newTripGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

        setOfMarkers.removeWhere((element) => element.markerId.value == "AnimatedMarker");
        setOfMarkers.add(animatingMarker);
      });

      oldLatLng = latLngLiveDriverPosition;
      updateDurationTimeAtRealTime();

      //updating driver location in realtime in database firebase
      Map driverLatLngDataMap =
      {
        "latitude": onlineDriverCurrentPosition!.latitude.toString(),
        "longitude": onlineDriverCurrentPosition!.longitude.toString(),
      };

      //controllo che il cliente non abbia annullato la corsa
      FirebaseDatabase.instance.ref().child("ALL Ride Requests")
          .child(widget.userRideRequestDetails!.rideRequestId!).once().then((tripKey){
          final snap = tripKey.snapshot;
          if(snap.value != null) {
          //il valore non è nullo, quindi procedere
            FirebaseDatabase.instance.ref().child("ALL Ride Requests")
                .child(widget.userRideRequestDetails!.rideRequestId!)
                .child("driverLocation")
                .set(driverLatLngDataMap);
          }
          else {
          //il valore è nullo, quindi non procedere
            streamSubscriptionDriverLivePosition!.cancel();
          }
      });
    });
  }

  updateDurationTimeAtRealTime() async  // Direction API CALL
  {
    if(isRequestDirectionDetails == false)
    {
      isRequestDirectionDetails = true;

      if(onlineDriverCurrentPosition == null)
      {
        return;
      }

      var originLatLng = LatLng(
          onlineDriverCurrentPosition!.latitude,
          onlineDriverCurrentPosition!.longitude,
      ); //Driver current Location

      var destinationLatLng;

      if(rideRequestStatus == "accepted") {
        destinationLatLng = widget.userRideRequestDetails!.originLatLng; //USER PickUp Location
      }
      else //arrived
      {
        destinationLatLng = widget.userRideRequestDetails!.destinationLatLng; ////USER DropOff Location
      }

      var directionInformation = await AssistantMethods.obtainOriginToDestinationDirectionDetails(originLatLng, destinationLatLng);

      if(directionInformation != null)
      {
        setState(() {
          durationFromOriginToDestination = directionInformation.duration_text!;
        });
      }

      isRequestDirectionDetails = false;
    }
  }

  @override
  Widget build(BuildContext context)
  {
    createDriverIconMarker();

    return Scaffold(
      body: Stack(
        children: [

          //google map
          GoogleMap(
            padding: EdgeInsets.only(bottom: mapPadding),
            mapType: MapType.normal,
            myLocationEnabled: true,
            initialCameraPosition: _kGooglePlex,
            minMaxZoomPreference: const MinMaxZoomPreference(11, 20),
            markers: setOfMarkers,
            circles: setOfCircle,
            polylines: setOfPolyline,
            onMapCreated: (GoogleMapController controller)
            {
              _controllerGoogleMap.complete(controller);
              newTripGoogleMapController = controller;

              setState(() {
                mapPadding = 350;
              });

              //riga che chiama metodo per impostare la mappa NERA!
              blackThemeGoogleMap(newTripGoogleMapController);
              locateDriverPosition();
              
              var driverCurrentLatLng = LatLng(
                  driverCurrentPosition!.latitude,
                  driverCurrentPosition!.longitude
              );

              if(rideRequestStatus == "accepted") {
                var userPickUpLatLng = widget.userRideRequestDetails!
                    .originLatLng;

                drawPolyLineFromOriginToDestination(driverCurrentLatLng, userPickUpLatLng!);
              }
              else if(rideRequestStatus == "arrived"){
                var userDropOffLtnLng = widget.userRideRequestDetails!
                    .destinationLatLng;

                setState(() {
                  buttonTitle = "Andiamo"; //start the trip
                  buttonColor = Colors.lightGreen;
                });

                drawPolyLineFromOriginToDestination(driverCurrentLatLng, userDropOffLtnLng!);
              }
              else if(rideRequestStatus == "ontrip"){
                var userDropOffLtnLng = widget.userRideRequestDetails!
                    .destinationLatLng;

                setState(() {
                  buttonTitle = "Fine Corsa"; //fine della corsa
                  buttonColor = Colors.red;
                });

                drawPolyLineFromOriginToDestination(driverCurrentLatLng, userDropOffLtnLng!);
              }


              getDriversLocationUpdatesAtRealTime();
            },
          ),

          //UI
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration:const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
                boxShadow:
                [
                  BoxShadow(
                    color: Colors.white30,
                    blurRadius: 18,
                    spreadRadius: .5,
                    offset: Offset(0.6, 0.6),
                  ),
                ]
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25,vertical: 20),
                child: Column(
                  children: [

                    //durata
                    Text(
                      durationFromOriginToDestination,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.lightGreenAccent,
                      ),
                    ),


                    const SizedBox(height: 18.0,),

                    const Divider(
                      height: 2,
                      thickness: 2,
                      color: Colors.grey,
                    ),

                    const SizedBox(height: 8.0,),

                    //user name - icon
                    Row(
                      children: [
                        Text(
                          widget.userRideRequestDetails!.userName!,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.lightGreenAccent,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // ignore: deprecated_member_use
                            launch("tel://${widget.userRideRequestDetails!.userPhone!}");
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Icon(
                              Icons.phone_android,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18.0,),

                    //user PickUp Address with icon
                    Row(
                      children: [
                        Image.asset(
                          "images/origin.png",
                          width: 30,
                          height: 30,
                        ),
                        const SizedBox(width: 16,),
                        Expanded(
                          child: Container(
                            child: Text(
                              widget.userRideRequestDetails!.originAddress!,
                              style: const TextStyle(
                                fontSize: 16,
                                color:Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20.0,),

                    //user DropOff Address with icon
                    Row(
                      children: [
                        Image.asset(
                          "images/destination.png",
                          width: 30,
                          height: 30,
                        ),
                        const SizedBox(width: 16,),
                        Expanded(
                          child: Container(
                            child: Text(
                              widget.userRideRequestDetails!.destinationAddress!,
                              style: const TextStyle(
                                fontSize: 16,
                                color:Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24.0,),

                    const Divider(
                      height: 2,
                      thickness: 2,
                      color: Colors.grey,
                    ),

                    const SizedBox(height: 20.0,),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () async
                              {
                                //[il driver è arrivato alla user Pickup Location con la bici/monopattino] - Arrivato Button
                                 if(rideRequestStatus == "accepted")
                                 {
                                   Position pos = await Geolocator.getCurrentPosition(
                                     desiredAccuracy: LocationAccuracy.high,
                                   );

                                   onlineDriverCurrentPosition = pos;

                                   double distanceInMeters = await Geolocator.distanceBetween(
                                     onlineDriverCurrentPosition!.latitude,
                                     onlineDriverCurrentPosition!.longitude,
                                     widget.userRideRequestDetails!.originLatLng!.latitude,
                                     widget.userRideRequestDetails!.originLatLng!.longitude,
                                   );

                                   print("QUESTO è IL VALORE DELLA DISTANZA  ::::::::");
                                   print(distanceInMeters.toString());

                                   if(distanceInMeters < 200.0)
                                   {
                                     setArrived();
                                   }
                                   else
                                   {
                                   Fluttertoast.showToast(msg: "Non sei ancora arrivato!");
                                   }
                                 }
                                // [il driver è al volante nella macchina e inizia la corsa del cliente] - Andiamo Button
                                else if(rideRequestStatus == "arrived")
                                {
                                  rideRequestStatus = "ontrip";

                                  FirebaseDatabase.instance.ref()
                                      .child("ALL Ride Requests")
                                      .child(widget.userRideRequestDetails!.rideRequestId!)
                                      .child("status")
                                      .set(rideRequestStatus); //cambio il valore di status nel database firebase

                                  FirebaseDatabase.instance.ref()
                                      .child("drivers")
                                      .child(currentFirebaseUser!.uid)
                                      .child("newRideStatus")
                                      .set(rideRequestStatus);

                                  setState(() {
                                    buttonTitle = "Fine Corsa"; //fine della corsa
                                    buttonColor = Colors.red;
                                  });
                                }
                                //[il cliente è arrivato e driver termina la corsa] - Fine Corsa Button
                                else if(rideRequestStatus == "ontrip")
                                {
                                  endTripNow();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: buttonColor,
                              ),
                                icon: const Icon(
                                  Icons.directions_car,
                                  color: Colors.white,
                                  size:28,

                                ),
                                label: Text(
                                  buttonTitle!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                              ),
                            ),

                            const SizedBox(width: 18.0),

                            ElevatedButton(
                              onPressed:() async {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      backgroundColor: CupertinoColors.systemGrey5,
                                      title: Text("Attenzione!"),
                                      content: Text("Se prosegui cancellerai il servizio in corso. \n \nDesideri continuare?"),
                                      actions: [
                                        ElevatedButton(
                                          child: Text("Si"),
                                          onPressed: () {
                                            driverAnnullaServizioInCorso();
                                          },
                                          style: ElevatedButton.styleFrom(backgroundColor: CupertinoColors.systemGrey,),
                                        ),
                                          const SizedBox(width: 15,),

                                          ElevatedButton(
                                            child: Text("No"),
                                            onPressed: () {
                                              // Codice da eseguire se l'utente preme "No"
                                              Navigator.of(context).pop();
                                            },
                                            style: ElevatedButton.styleFrom(backgroundColor: CupertinoColors.systemGrey,),
                                          ),
                                        const SizedBox(width: 11,),


                                      ],
                                      actionsAlignment: MainAxisAlignment.end,
                                    );
                                  },
                                );
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: CupertinoColors.systemGrey,),
                              child: const Text('Annulla Corsa',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold
                                  )
                              ),

                            ),
                          ],
                        ),

                  ],
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }


  driverAnnullaServizioInCorso()
  {
    FirebaseDatabase.instance.ref()
        .child("ALL Ride Requests")
        .child(widget.userRideRequestDetails!.rideRequestId!)
        .remove().then((value)
    {
      FirebaseDatabase.instance.ref()
          .child("drivers")
          .child(currentFirebaseUser!.uid)
          .child("newRideStatus")
          .set("idle");
    }).then((value)
    {
      FirebaseDatabase.instance.ref()
          .child("drivers")
          .child(currentFirebaseUser!.uid)
          .child("tripsHistory")
          .child(widget.userRideRequestDetails!.rideRequestId!)
          .remove();
    }).then((value)
    {
      setState(() {
        setOfPolyline.clear();
        setOfMarkers.clear();
        setOfCircle.clear();
        polyLinePositionCoordinates.clear();
        streamSubscriptionDriverLivePosition?.cancel();
        tripRideRequestInfoStreamSubscription?.cancel();
      });

      Fluttertoast.showToast(msg: "Corsa Annullata!");

      Navigator.push(context, MaterialPageRoute(builder: (c)=> MySplashScreen()));

    });

  }


  setArrived() async {
    rideRequestStatus = "arrived";

    FirebaseDatabase.instance.ref()
        .child("ALL Ride Requests")
        .child(widget.userRideRequestDetails!.rideRequestId!)
        .child("status")
        .set(rideRequestStatus);

    FirebaseDatabase.instance.ref()
        .child("drivers")
        .child(currentFirebaseUser!.uid)
        .child("newRideStatus")
        .set(rideRequestStatus);

    setState(() {
      buttonTitle = "Andiamo"; //start the trip
      buttonColor = Colors.lightGreen;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext c) => ProgressDialog(message: "Attendere..."),
    );

    await drawPolyLineFromOriginToDestination(
    widget.userRideRequestDetails!.originLatLng!,
    widget.userRideRequestDetails!.destinationLatLng!
    );

    Navigator.pop(context);
  }

  endTripNow() async
  {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context)=> ProgressDialog(message: "Attendere...",),
    );


    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    onlineDriverCurrentPosition = pos;

    double distanceInMeters = await Geolocator.distanceBetween(
      onlineDriverCurrentPosition!.latitude,
      onlineDriverCurrentPosition!.longitude,
      widget.userRideRequestDetails!.destinationLatLng!.latitude,
      widget.userRideRequestDetails!.destinationLatLng!.longitude,
    );

    print("QUESTO è IL VALORE DELLA DISTANZA  ::::::::");
    print(distanceInMeters.toString());

    if(distanceInMeters < 200.0)
    {

      //Costo corsa - fare amount
      double totalFareAmount = 20;
      //double totalFareAmount = AssistantMethods.calculateFareAmountFromOriginToDestination(tripDirectionDetails!);

      DatabaseReference? ref = FirebaseDatabase.instance.ref()
          .child("ALL Ride Requests")
          .child(widget.userRideRequestDetails!.rideRequestId!);

      ref.child("fareAmount").set(totalFareAmount.toString());

      ref.child("status").set("ended");

      streamSubscriptionDriverLivePosition!.cancel();

      ref.onDisconnect();


      Navigator.pop(context);

      // il driver vede il suo guadagno appena dopo aver finito la corsa //PUNTO CALIENTE BABY ::::::!!!!!!
      showDialog(
          context: context,
          builder: (BuildContext c)=> FareAmountCollectionDialog(totalFareAmount: totalFareAmount,),);
      //salviamo nella pagina earnings
      saveFareAmountToDriverEarnings(totalFareAmount);
    }
    else
    {
      Fluttertoast.showToast(msg: "Arriva alla Destinazione!");

      Navigator.pop(context);
    }
  }

  saveFareAmountToDriverEarnings(double totaleFareAmount)
  {//controlliamo la presenza e creaiamo un campo subchild di drivers all'interno del database firebase
    FirebaseDatabase.instance.ref()
        .child("drivers")
        .child(currentFirebaseUser!.uid)
        .child("earnings")
        .once()
        .then((snap)
    {
      if(snap.snapshot.value != null) //earnings sub child exist in Firebase Database
      {
        //prendo il valore che c'era prima
        double oldEarnings = double.parse(snap.snapshot.value.toString());
        //sommo il vecchio al nuovo
        double driverTotalEarnings = totaleFareAmount + oldEarnings;
        //vado a settarlo sul database firebase
        FirebaseDatabase.instance.ref()
            .child("drivers")
            .child(currentFirebaseUser!.uid)
            .child("earnings")
            .set(driverTotalEarnings.toString());
      }
      else //earnings sub do not child exist - lo creo e setto il valore in Firebase Database
      {
        FirebaseDatabase.instance.ref()
            .child("drivers")
            .child(currentFirebaseUser!.uid)
            .child("earnings")
            .set(totaleFareAmount.toString());
      }
    });
  }

  controlStateOfTrip()
  {
    DatabaseReference databaseReference = FirebaseDatabase.instance.ref()
        .child("ALL Ride Requests")
        .child(widget.userRideRequestDetails!.rideRequestId!);

    tripRideRequestInfoStreamSubscription = databaseReference!.onValue.listen((eventSnap) async
    {
      if(eventSnap.snapshot.value == null)
      {
        FirebaseDatabase.instance.ref()
            .child("drivers")
            .child(currentFirebaseUser!.uid)
            .child("newRideStatus")
            .set("idle");

          FirebaseDatabase.instance.ref()
              .child("drivers")
              .child(currentFirebaseUser!.uid)
              .child("tripsHistory")
              .child(widget.userRideRequestDetails!.rideRequestId!)
              .remove();


        setState(() {
          setOfPolyline.clear();
          setOfMarkers.clear();
          setOfCircle.clear();
          polyLinePositionCoordinates.clear();
          streamSubscriptionDriverLivePosition?.cancel();
          tripRideRequestInfoStreamSubscription?.cancel();
          //widget.userRideRequestDetails;
        });

        Fluttertoast.showToast(msg: "Il cliente ha annullato la corsa!",toastLength: Toast.LENGTH_LONG);
        Navigator.push(context, MaterialPageRoute(builder: (c)=> const MySplashScreen()));
      }
    });
  }

  saveAssignedDriverDetailsToUserRideRequest() async {
    DatabaseReference databaseReference = FirebaseDatabase.instance.ref()
                                          .child("ALL Ride Requests")
                                          .child(widget.userRideRequestDetails!.rideRequestId!);

    Map driverLocationDataMap =
    {
      "latitude" : driverCurrentPosition!.latitude.toString(),
      "longitude" : driverCurrentPosition!.longitude.toString(),
    };
    databaseReference.child("driverLocation").set(driverLocationDataMap);


    //faccio un controllo per capire se la corsa è già stata avviata e si sta riaprendo l'app perchè killata per errore
    FirebaseDatabase.instance.ref()
        .child("ALL Ride Requests")
        .child(widget.userRideRequestDetails!.rideRequestId!)
        .child("status").once()
        .then((snap){

      if(snap.snapshot.value !=null){
        if(snap.snapshot.value != "accepted" && snap.snapshot.value != "arrived" && snap.snapshot.value != "ontrip" && snap.snapshot.value != "ended")
        {
          isNewTrip = false;
        }
        else{
          setState(() {
            rideRequestStatus = snap.snapshot.value.toString();
            print("settato $rideRequestStatus");
          });
        }
      }
    });


    print("lo stato di isNewTrip é $isNewTrip");
    if(isNewTrip != false) {

      setState(() {
        rideRequestStatus = "accepted";
      });
      databaseReference.child("status").set("accepted");
      databaseReference.child("driverId").set(onlineDriverData.id);
      databaseReference.child("driverName").set(onlineDriverData.name);
      databaseReference.child("driverPhone").set(onlineDriverData.phone);
      saveRideRequestIdToDriverHistory();
    }


  }

  saveRideRequestIdToDriverHistory()
  {
    DatabaseReference tripsHistoryRef = FirebaseDatabase.instance.ref()
        .child("drivers")
        .child(currentFirebaseUser!.uid)
        .child("tripsHistory");

    tripsHistoryRef.child(widget.userRideRequestDetails!.rideRequestId!).set(true);
  }

}
