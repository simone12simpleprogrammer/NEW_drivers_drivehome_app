import 'package:drivers_app/global/global.dart';
import 'package:drivers_app/push_notifications/notification_repository.dart';
import 'package:drivers_app/tabPages/home_tab.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../splashScreen/splash_screen.dart';
import '../widgets/info_design_ui.dart';

class ProfileTabPage extends StatefulWidget
{
  const ProfileTabPage({Key? key}) : super(key: key);

  @override
  State<ProfileTabPage> createState() => _ProfileTabPageState();
}

class _ProfileTabPageState extends State<ProfileTabPage>
{


  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height:100,),
            //name
            Text(
              onlineDriverData.name!,textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 60.0,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),


            const SizedBox(
              height: 30,
              width: 200,
              child: Divider(
                color: Colors.white,
                height: 2,
                thickness: 2,
              ),
            ),

            const SizedBox(height: 50,),

            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 30.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const <Widget>[
                      Icon(
                        Icons.settings_outlined,
                        size: 28.0,
                        color: Colors.white,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Text('Sono disponibile',style: TextStyle(color: Colors.white,fontSize: 20),),
                      ),
                    ],
                  ),
                  CupertinoSwitch(
                    value: isDriverActive,
                    onChanged: (value) {
                      setState(() {
                        isDriverActive = value;
                        if(isDriverActive == false){
                          driverIsOfflineNow();
                        }else if (isDriverActive == true)
                        {
                          driverIsOnlineNow();
                        }
                      });
                    },
                  ),

                ],
              ),
            ),

        const SizedBox(height: 20,),
            //phone
            InfoDesignUIWidget(
              textInfo: onlineDriverData.phone!,
              iconData: Icons.phone_iphone,
            ),

            //email
            InfoDesignUIWidget(
              textInfo: onlineDriverData.email!,
              iconData: Icons.email,
            ),

            const SizedBox(height: 20,),

            ElevatedButton(
              onPressed:()
              {
                DatabaseReference ref = FirebaseDatabase.instance.ref()
                    .child("drivers")
                    .child(currentFirebaseUser!.uid)
                    .child("newRideStatus");

                      Geofire.removeLocation(currentFirebaseUser!.uid);
                      ref.set("idle");
                      fAuth.signOut();
                      Navigator.push(context, MaterialPageRoute(builder: (c) => const MySplashScreen()));

              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text(
                "LogOut",
                style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,),
              ),
            ),

            const SizedBox(height: 45,),

            TextButton(
                style: TextButton.styleFrom(padding: const EdgeInsets.only(top: 10),tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                child: const Text(
                  "Cancella il mio account",
                  style:TextStyle(color: Colors.white,fontWeight: FontWeight.w100)
                ),
                onPressed: ()
                {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        backgroundColor: CupertinoColors.systemGrey5,
                        title: Text("Oh no.."),
                        content: Text("Ci dispiace perderti. \n \nVuoi davvero cancellarti?"),
                        actions: [

                          const SizedBox(width: 5,),
                          ElevatedButton(
                            onPressed: () {

                              //cancellazione utente
                              var firebaseUserReference = FirebaseDatabase.instance.ref().child("drivers").child(fAuth.currentUser!.uid);
                              firebaseUserReference.remove();
                              Fluttertoast.showToast(msg: "Account cancellato!");
                              Navigator.push(context, MaterialPageRoute(builder: (c)=> const MySplashScreen()));

                            },
                            style: ElevatedButton.styleFrom(backgroundColor: CupertinoColors.destructiveRed,),
                            child: const Text("Cancella il mio account",style: TextStyle(color:Colors.white),),
                          ),



                          ElevatedButton(
                            onPressed: () {
                              // Codice da eseguire se l'utente preme "No"
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: CupertinoColors.systemGrey,),
                            child: const Text("No",style: TextStyle(color:Colors.white),),
                          ),
                          const SizedBox(width: 5,),
                        ],
                        actionsAlignment: MainAxisAlignment.center,
                      );
                    },
                  );
                }
            ),


          ],
        ),
      ),
    );
  }

  driverIsOnlineNow() async
  {

    print("NUOVO UPDATE ORA!  ");
    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    driverCurrentPosition = pos;

    Geofire.initialize("activeDrivers");
    if(streamSubscriptionPosition!.isPaused){
      streamSubscriptionPosition!.resume();
    }

    Geofire.setLocation(
        currentFirebaseUser!.uid,
        driverCurrentPosition!.latitude,
        driverCurrentPosition!.longitude
    );

    NotificationRepository().generateAndGetToken();

    DatabaseReference ref = FirebaseDatabase.instance.ref()
        .child("drivers")
        .child(currentFirebaseUser!.uid)
        .child("newRideStatus");

    ref.set("idle");

  }



  driverIsOfflineNow()
  {
    Geofire.removeLocation(currentFirebaseUser!.uid);
    streamSubscriptionPosition?.pause();

    DatabaseReference? ref = FirebaseDatabase.instance.ref()
        .child("drivers")
        .child(currentFirebaseUser!.uid)
        .child("newRideStatus");


    ref.onDisconnect();
    ref.remove();
    ref = null;


  }
}
