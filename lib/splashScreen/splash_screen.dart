
import 'package:drivers_app/authentication/documents_updating_screen.dart';
import 'package:drivers_app/authentication/login_screen.dart';
import 'package:drivers_app/mainScreens/main_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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

  startRedirect() async {
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
          Future.delayed(const Duration(milliseconds: 3000),()
          {
            Navigator.push(context, MaterialPageRoute(builder: (c) => MainScreen()));
          });
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
  }

  setInitialUserPosition()
  async {
    Position cPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    driverCurrentPosition = cPosition;

    setState((){
      initialLatLngPosition = LatLng(driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);
    });

  }


  _checkIfLocationPermissionAllowed() async
  {
    _locationPermission = await Geolocator.requestPermission();

    if(_locationPermission == LocationPermission.denied)
    {
      _locationPermission = await Geolocator.requestPermission();
    }else
      if(_locationPermission == LocationPermission.deniedForever)
    {
      Fluttertoast.showToast(msg: "Abbiamo bisogno della Posizone!",toastLength: Toast.LENGTH_LONG);
      openAppSettings();
    }else{
      setInitialUserPosition();
      startRedirect();
    }
  }

  @override
  void initState() {
    super.initState();
    _checkIfLocationPermissionAllowed();
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



