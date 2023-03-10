import 'dart:async';

import 'package:drivers_app/authentication/signup_screen.dart';
import 'package:drivers_app/splashScreen/splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:drivers_app/global/global.dart';
import 'package:drivers_app/widgets/progress_dialog.dart';

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
              Fluttertoast.showToast(msg: "Questa email non ?? registrata.");
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
                return AlertDialog(
                  backgroundColor: CupertinoColors.systemGrey5,
                  title: Padding(
                    padding: const EdgeInsets.only(top:15.0),
                    child: Text("Verifica Email", style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                        textAlign: TextAlign.center),
                  ),
                  content: Text(
                      "Devi verificare la tua email prima di accedere. Controlla la tua casella di posta elettronica.",
                      style: TextStyle(color: Colors.black),
                      textAlign: TextAlign.center),
                  actions: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                            child: Text(
                                "OK", style: TextStyle(fontWeight: FontWeight
                                .bold, color: Colors.black)),
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: CupertinoColors.systemGrey,)
                        ),
                        const SizedBox(height: 15,)
                      ],
                    )
                  ],
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
            msg: "Si ?? verificato un errore durante l'Accesso");
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
          FittedBox(
              child:Padding(
                padding: const EdgeInsets.all(30.0),
                child: Image.asset("images/logo1.png"),
              ),
          ),
              const SizedBox(height:3,),

          const FittedBox(
            child: Text(
                "Accedi come Autista",
                style : TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ),
              const SizedBox(height:10,),


            TextField(
                controller: emailTextEditingController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(
                    color: Colors.white
                ),
                decoration: const InputDecoration(
                  labelText: "Email",
                  hintText: "Email",
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color:Colors.white),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color:Colors.white),
                  ),
                  hintStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                  labelStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),


              TextField(
                controller: passwordTextEditingController,
                keyboardType: TextInputType.text,
                obscureText: true,
                style: const TextStyle(
                    color: Colors.white
                ),
                decoration: const InputDecoration(
                  labelText: "Password",
                  hintText: "Password",
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color:Colors.white),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color:Colors.white),
                  ),
                  hintStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                  labelStyle: TextStyle(
                    color: Colors.white,
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
                  backgroundColor: Colors.lightGreenAccent,
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
                  style:TextStyle(color: Colors.white),
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
                    style:TextStyle(color: Colors.white),
                  ),
                  onPressed: () async
                  {
                    String emailUser = emailTextEditingController.text.trim();
                    if(emailUser.isNotEmpty) {
                      await FirebaseAuth.instance.sendPasswordResetEmail(
                          email: emailTextEditingController.text.trim());
                      Fluttertoast.showToast(
                          msg: "Controlla tra le e-mail per reimpostare la password.");
                      Navigator.push(context,
                          MaterialPageRoute(builder: (c) => LoginScreen()));
                    }else{
                      Fluttertoast.showToast(msg: "Inserire l'e-mail nel suo campo e riprovare.");
                    }
                  }
              ),
            ],
          ),
        ),
      ),
    );
  }
}
