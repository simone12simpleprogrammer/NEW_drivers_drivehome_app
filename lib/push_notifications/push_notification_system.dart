import 'package:drivers_app/global/global.dart';
import 'package:drivers_app/models/user_ride_request_information.dart';
import 'package:drivers_app/push_notifications/notification_dialog_box.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:assets_audio_player/assets_audio_player.dart';


class PushNotificationSystem
{

  static readUserRideRequestInformation(String userRideRequestId, BuildContext context)
  {
    FirebaseDatabase.instance.ref()
        .child("ALL Ride Requests")
        .child(userRideRequestId)
        .once()
        .then((snapData)
    {
      if(snapData.snapshot.value != null)
      {
        audioPlayer.open(Audio("music/notificationSound.mp3"));
        audioPlayer.play();


        double originLat = double.parse((snapData.snapshot.value! as Map)["origin"]["latitude"]);
        double originLng = double.parse((snapData.snapshot.value! as Map)["origin"]["longitude"]);
        String originAddress = (snapData.snapshot.value! as Map)["originAddress"];

        double destinationLat = double.parse((snapData.snapshot.value! as Map)["destination"]["latitude"]);
        double destinationLng = double.parse((snapData.snapshot.value! as Map)["destination"]["longitude"]);
        String destinationAddress = (snapData.snapshot.value! as Map)["destinationAddress"];

        String userName = (snapData.snapshot.value! as Map)["userName"];
        String userPhone = (snapData.snapshot.value! as Map)["userPhone"];

        String? rideRequestId = snapData.snapshot.key;

        //passo tutto alla classe MODEL UserRideRequestInformation
        UserRideRequestInformation userRideRequestDetails = UserRideRequestInformation();

        userRideRequestDetails.originLatLng = LatLng(originLat, originLng);
        userRideRequestDetails.originAddress = originAddress;

        userRideRequestDetails.destinationLatLng = LatLng(destinationLat, destinationLng);
        userRideRequestDetails.destinationAddress = destinationAddress;

        userRideRequestDetails.userName = userName;
        userRideRequestDetails.userPhone = userPhone;

        userRideRequestDetails.rideRequestId = rideRequestId;

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) => NotificationDialogBox(
            userRideRequestDetails: userRideRequestDetails,
          ),
        );
      }
      else
      {
        //La corsa è stata cancellata
        //Fluttertoast.showToast(msg: "This Ride Request Id do not exists. ");
        Fluttertoast.showToast(msg: "La corsa è stata cancellata.");
      }
    });

  }


/*FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future initializeCloudMessaging(BuildContext context) async
  {
    //1. Terminated
    //Quando l'appliazione è completamente chiusa e quando apri la notifica vai direttamente sull'app
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? remoteMessage)
    {
      //remoteMessage?.notification?.android.priority = AndroidNotificationPriority.highPriority;
      if(remoteMessage != null)
      {
        //mostrare informazioni della richiesta di corsa - informazioni user che richiede la corsa
        readUserRideRequestInformation(remoteMessage.data["rideRequestId"], context);
      }
    });

    //2.Foreground
    //Quando l'applicazione è aperta e ricevi una notifica push
    FirebaseMessaging.onMessage.listen((RemoteMessage? remoteMessage)
    {
      if(remoteMessage != null)
      {
        //mostrare informazioni della richiesta di corsa - informazioni user che richiede la corsa
        readUserRideRequestInformation(remoteMessage!.data["rideRequestId"], context);
      }
    });

    //3. Background
    //Quando l'app è in backgound e si apre direttamente l'app quando si clicca sulla notifica push
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? remoteMessage)
    {
      if(remoteMessage != null)
      {
        //mostrare informazioni della richiesta di corsa - informazioni user che richiede la corsa
        readUserRideRequestInformation(remoteMessage!.data["rideRequestId"], context);
      }
    });

    //4. Quando il cell è bloccato ?? da testare
    //FirebaseMessaging.onBackgroundMessage((firebaseMessagingBackgroundHandler.) => readUserRideRequestInformation(remoteMessage!.data["rideRequestId"],););

  }





  Future generateAndGetToken() async
  {
    //richiedo il token
    String? registrationToken = await messaging.getToken();
    print("FCM Registration Token: ");
    print(registrationToken);

    //lo setto nel databese realtime
    FirebaseDatabase.instance.ref()
        .child("drivers")
        .child(currentFirebaseUser!.uid)
        .child("token")
        .set(registrationToken);

    messaging.subscribeToTopic("allDrivers");
  }*/


}