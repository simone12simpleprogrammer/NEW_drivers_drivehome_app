import 'package:drivers_app/widgets/progress_dialog.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../global/global.dart';
import '../splashScreen/splash_screen.dart';

class FareAmountCollectionDialog extends StatefulWidget
{
  double? totalFareAmount;

  FareAmountCollectionDialog({this.totalFareAmount});

  @override
  State<FareAmountCollectionDialog> createState() => _FareAmountCollectionDialogState();
}

class _FareAmountCollectionDialogState extends State<FareAmountCollectionDialog>
{
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      backgroundColor: Colors.white70,
      child: Container(
        margin: const EdgeInsets.all(6),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            const SizedBox(height: 20,),

            const Text(
              "Costo della Corsa",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white70,
                fontSize: 24,
              ),
            ),

            const SizedBox(height: 16,),

            const Divider(
              thickness: 2,
              color: Colors.grey,
            ),

            const SizedBox(height: 16,),

            Text(
              widget.totalFareAmount.toString() + "€",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white70,
                fontSize: 50,
              ),
            ),

            const SizedBox(height: 10,),

            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Questo è il totale, \nRitira la somma dal cliente.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                ),
              ),
            ),

            const SizedBox(height: 10,),
            
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.green
                ),
                onPressed: ()
                {
                  showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext c)
                      {
                        return ProgressDialog(message: "Attendere...");
                      }
                  );

                  Future.delayed(const Duration(seconds: 11), ()
                  {
                    Navigator.pop(context);
                    FirebaseDatabase.instance.ref()
                        .child("drivers")
                        .child(currentFirebaseUser!.uid)
                        .child("newRideStatus")
                        .set("idle");


                      //SystemNavigator.pop();
                      Navigator.push(context, MaterialPageRoute(builder: (c)=> const MySplashScreen()));


                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                     const Text(
                        "Contanti Raccolti",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    //Image.asset("image path here")
                     Text(
                       widget.totalFareAmount!.toString() + " \€",
                       style: const TextStyle(
                         fontSize: 16,
                         color: Colors.white,
                         fontWeight: FontWeight.bold,
                       ),
                     ),
                     // Icon(
                     //   Icons.euro,
                     //   color: Colors.white,
                     //    size: 24,
                     // ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 4),

          ],
        ),
      ),
    );
  }
}
