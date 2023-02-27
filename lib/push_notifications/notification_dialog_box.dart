import 'package:drivers_app/global/global.dart';
import 'package:drivers_app/mainScreens/new_trip_screen.dart';
import 'package:drivers_app/models/user_ride_request_information.dart';
import 'package:drivers_app/splashScreen/splash_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class NotificationDialogBox extends StatefulWidget
{
  UserRideRequestInformation? userRideRequestDetails;

  NotificationDialogBox({this.userRideRequestDetails});

  @override
  State<NotificationDialogBox> createState() => _NotificationDialogBoxState();

}

class _NotificationDialogBoxState extends State<NotificationDialogBox> {
  @override
  Widget build(BuildContext context)
  {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      backgroundColor: Colors.transparent,
      elevation: 2,
      child: Container(
        margin: const EdgeInsets.all(8),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey[300],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            const SizedBox(height: 14,),

            Image.asset(
              "images/car_logo.png",
              width: 160,
            ),

            const SizedBox(height: 5,),

            //titolo
            const Text(
              "Nuova Corsa",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),

            const SizedBox(height: 18,),

             const Divider(
               height: 3,
               thickness: 2,
             ),

            //addresses origin & destination
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  //origin location with icon
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
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16.0,),

                  //destination location with icon
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
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                ],
              ),
            ),

           const Divider(
             height: 3,
             thickness: 2,
           ),

           //buttons rifiuta & accetta
           Padding(
             padding: const EdgeInsets.all(10.0),
             child: Row(
               mainAxisAlignment: MainAxisAlignment.center,

               children: [
                 ElevatedButton(
                   style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                   ),
                   onPressed: ()
                   {
                     audioPlayer.pause();
                     audioPlayer.stop();
                     audioPlayer = AssetsAudioPlayer();

                     //rifiuta la richiesta di corsa
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
                       Fluttertoast.showToast(msg: "Corsa Rifiutata!");
                     });

                     Future.delayed(const Duration(milliseconds: 2000), ()
                     {
                       //SystemNavigator.pop();
                       Navigator.push(context, MaterialPageRoute(builder: (c)=> const MySplashScreen()));
                     });

                   },
                   child: Text(
                     "Rifiuta".toUpperCase(),
                     style: const TextStyle(
                       fontSize: 14.0,
                       color: Colors.white
                     ),
                   ),
                 ),

                 const SizedBox(width: 25.0),

                 ElevatedButton(
                   style: ElevatedButton.styleFrom(
                     backgroundColor: Colors.green,
                   ),
                   onPressed: ()
                   {
                     audioPlayer.pause();
                     audioPlayer.stop();
                     audioPlayer = AssetsAudioPlayer();
                     //accetta la richiesta di corsa
                     acceptRideRequest(context);

                   },
                   child: Text(
                     "Accetta".toUpperCase(),
                     style: const TextStyle(
                       fontSize: 14.0,
                       color: Colors.white
                     ),
                   ),
                 ),
               ],
             ),
           ),

          ],
        ),
      ),
    );
  }

  acceptRideRequest(BuildContext context)
  {
    String getRiderRequestId="";
    FirebaseDatabase.instance.ref()
        .child("drivers")
        .child(currentFirebaseUser!.uid)
        .child("newRideStatus")
        .once()
        .then((snap)
    {
      if(snap.snapshot.value != null)
      {
        getRiderRequestId = snap.snapshot.value.toString();
      }
      else
      {
        Fluttertoast.showToast(msg: "La corsa è stata cancellata!");
        Future.delayed(const Duration(milliseconds: 2000), ()
        {
          //SystemNavigator.pop();
          Navigator.push(context, MaterialPageRoute(builder: (c)=> const MySplashScreen()));
        });
      }

      if(getRiderRequestId == widget.userRideRequestDetails!.rideRequestId)
      {
        FirebaseDatabase.instance.ref()
            .child("drivers")
            .child(currentFirebaseUser!.uid)
            .child("newRideStatus")
            .set("accepted");

        //AssistantMethods.pauseLiveLocationUpdates();

        //la corsa inizia ora
        //mandiamo il driver a new_trip_screen
        // per vedere il tragitto con polyline per arrivare al cliente
        Navigator.push(context, MaterialPageRoute(builder: (c)=> NewTripScreen(
          userRideRequestDetails: widget.userRideRequestDetails,
        )));

      }
      else
      {
        Fluttertoast.showToast(msg: "La corsa è stata cancellata!");

        Future.delayed(const Duration(milliseconds: 2000), ()
        {
          //SystemNavigator.pop();
          Navigator.push(context, MaterialPageRoute(builder: (c)=> const MySplashScreen()));
        });
      }
    });
  }
}
