import 'dart:async';

import 'package:drivers_app/authentication/documents_updating_screen.dart';
import 'package:drivers_app/authentication/login_screen.dart';
import 'package:drivers_app/authentication/signup_screen.dart';
import 'package:drivers_app/mainScreens/main_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../global/global.dart';

class MySplashScreen extends StatefulWidget
{
  const MySplashScreen({Key? key}) : super(key: key);

  @override
  State<MySplashScreen> createState() => _MySplashScreenState();
}



class _MySplashScreenState extends State<MySplashScreen>
{

  String? hasDriverUploadedFile;


  var geoLocator = Geolocator();
  LocationPermission? _locationPermission;

  startTimer(){
    Timer(const Duration(seconds: 3),()
    async {
      if(fAuth.currentUser != null && fAuth.currentUser!.emailVerified )
      {
        currentFirebaseUser = fAuth.currentUser;

        String? resp;
        await FirebaseDatabase.instance.ref()
            .child("drivers")
            .child(currentFirebaseUser!.uid)
            .child("hasDriverUploadedDocuments")
            .once()
            .then((snapData) {

          if (snapData.snapshot.value != null) {
            print("Dal database mi dicono che il valore è : ${snapData.snapshot.value}");
            setState(() {
              resp = snapData.snapshot.value.toString();
            });
          }
        });

        setState(() {
          hasDriverUploadedFile = resp;
        });

        print("Dal database mi dicono che il valore è : $hasDriverUploadedFile");

        if(hasDriverUploadedFile == "true"){
          print("sono dentro");
          Navigator.push(context, MaterialPageRoute(builder: (c) => MainScreen()));

        }
        else
        {
          print("sono qui");
          Navigator.push(context, MaterialPageRoute(builder: (c) => DocumentsUpdatingScreen()));
        }

      }
      else
      {
        Navigator.push(context, MaterialPageRoute(builder: (c)=> LoginScreen()));
      }

    });
  }

  controlIfDriverHasUploadedDocuments(){



  }

  checkIfLocationPermissionAllowed() async
  {
    _locationPermission = await Geolocator.requestPermission();

    if(_locationPermission == LocationPermission.denied)
    {
      _locationPermission = await Geolocator.requestPermission();

      if(_locationPermission == LocationPermission.deniedForever)
      {
        Fluttertoast.showToast(msg: "Abbiamo bisogno della Posizone!");

        openAppSettings();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    checkIfLocationPermissionAllowed();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color:Colors.black,
        child:Center(
          child:Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Image.asset("images/logo300nosub.png", filterQuality: FilterQuality.high,fit: BoxFit.fill),

               const SizedBox(height:10,),
            ],
          )
        )
      ),
    );
  }

}



