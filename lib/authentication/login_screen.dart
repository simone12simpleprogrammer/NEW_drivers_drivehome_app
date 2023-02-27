import 'dart:async';

import 'package:drivers_app/authentication/signup_screen.dart';
import 'package:drivers_app/mainScreens/main_screen.dart';
import 'package:drivers_app/splashScreen/splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../global/global.dart';
import '../widgets/progress_dialog.dart';

class LoginScreen extends StatefulWidget {

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
{
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  validateForm()
  {

    if (!emailTextEditingController.text.contains("@"))
    {
      Fluttertoast.showToast(msg: "Email non Valida.");
    }
    else if (passwordTextEditingController.text.isEmpty)
    {
      Fluttertoast.showToast(msg: "Password richiesta.");
    }
    else
    {
      loginDriverNow();
    }
  }

  loginDriverNow() async
  {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext c)
        {
          return ProgressDialog(message: "Attendere...",);
        }
    );

      final User? firebaseUser = (
          await fAuth.signInWithEmailAndPassword(
            email: emailTextEditingController.text.trim(),
            password: passwordTextEditingController.text.trim(),
          ).catchError((msg) {
            Navigator.pop(context);
            Fluttertoast.showToast(msg: "Email o Password sbagliata!");
          })
      ).user;

      if (firebaseUser != null) {
        if (fAuth.currentUser!.emailVerified) {
          DatabaseReference driverRef = FirebaseDatabase.instance.ref().child("drivers");
          driverRef.child(firebaseUser.uid).once().then((driverKey) {
            final snap = driverKey.snapshot;
            if (snap.value != null) {
              currentFirebaseUser = firebaseUser;
              setState(() {
                isDriverActive = true;
              });
              Navigator.push(context,
                  MaterialPageRoute(builder: (c) => const MySplashScreen()));
            }
            else {
              Fluttertoast.showToast(msg: "Questa email non è registrata.");
              fAuth.signOut();
              Navigator.push(context,
                  MaterialPageRoute(builder: (c) => const MySplashScreen()));
            }
          });
        }
        else {
          await firebaseUser.sendEmailVerification();

          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext c) {
                return Container(
                  margin: const EdgeInsets.only(
                      left: 50, right: 50, bottom: 220, top: 220),
                  width: double.infinity,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(10.0),
                    color: Colors.white,
                  ),
                  child: AlertDialog(
                    backgroundColor: Colors.white54,
                    title: const Text("Verifica Email", style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                        textAlign: TextAlign.center),
                    content: Text(
                        "Devi verificare la tua email prima di accedere. /n Controlla la tua casella di posta elettronica.",
                        style: TextStyle(color: Colors.black),
                        textAlign: TextAlign.center),
                    actions: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                              child: Text("OK", style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black)),
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey,)
                          ),
                        ],
                      )

                    ],
                  ),
                );
              }
          );

          EmailVerificationControl();

          Timer.periodic(Duration(minutes: 3), (timer2) {
            fAuth.currentUser!.reload();
            if (fAuth.currentUser!.emailVerified) {
              timer2.cancel();
            }
            else {
              fAuth.signOut();
              Navigator.push(context,
                  MaterialPageRoute(builder: (c) => const MySplashScreen()));
            }
          });
        }
      }
      else {
        Navigator.pop(context);
        Fluttertoast.showToast(
            msg: "Si è verificato un errore durante l'Accesso");
      }
  }

  EmailVerificationControl() async
  {
    Timer.periodic(Duration(seconds: 5), (timer)
    {
      fAuth.currentUser!.reload();
      if (fAuth.currentUser!.emailVerified) {
        Navigator.push(context, MaterialPageRoute(builder: (c) => const MySplashScreen()));
        timer.cancel();
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body:SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height:30,),

              Padding(
                padding: const EdgeInsets.all(30.0),
                child: Image.asset("images/logo1.png"),
              ),

              const SizedBox(height:10,),

              const Text(
                "Accedi come Autista",
                style : TextStyle(
                  fontSize: 24,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),

              TextField(
                controller: emailTextEditingController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(
                    color: Colors.grey
                ),
                decoration: const InputDecoration(
                  labelText: "Email",
                  hintText: "Email",
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color:Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color:Colors.grey),
                  ),
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                  labelStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),

              TextField(
                controller: passwordTextEditingController,
                keyboardType: TextInputType.text,
                obscureText: true,
                style: const TextStyle(
                    color: Colors.grey
                ),
                decoration: const InputDecoration(
                  labelText: "Password",
                  hintText: "Password",
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color:Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color:Colors.grey),
                  ),
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                  labelStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),

              const SizedBox(height:20,),

              ElevatedButton(
                onPressed: ()
                {
                  validateForm();
                },
                style:ElevatedButton.styleFrom(
                  primary: Colors.lightGreenAccent,
                ),
                child: Text(
                  "ACCEDI",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 20,
                  ),
                ),
              ),

              TextButton(
                style: TextButton.styleFrom(padding: EdgeInsets.only(top: 10),tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                child: const Text(
                  "Non hai un account? Registrati qui",
                  style:TextStyle(color: Colors.grey),
                ),
                onPressed: ()
                {
                  Navigator.push(context, MaterialPageRoute(builder: (c)=> SignUpScreen()));
                }
              ),


              TextButton(
                  style: TextButton.styleFrom(padding: EdgeInsets.only(top: 2),tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                  child: const Text(
                    "Password dimenticata?",
                    style:TextStyle(color: Colors.grey),
                  ),
                  onPressed: () async
                  {
                    print("QUESTO è l'inidirizzo email per mail da resettare :${emailTextEditingController!.text.trim()}");
                    await FirebaseAuth.instance.sendPasswordResetEmail(email: emailTextEditingController!.text.trim());
                    Fluttertoast.showToast(msg: "Controlla tra le email per reimpostare la password.");
                    Navigator.push(context, MaterialPageRoute(builder: (c)=> LoginScreen()));
                  }
              ),
            ],
          ),
        ),
      ),
    );
  }
}
