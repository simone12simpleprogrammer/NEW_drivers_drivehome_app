import 'dart:async';
import 'dart:async';

import 'package:drivers_app/authentication/login_screen.dart';
import 'package:drivers_app/documents/privacy_policy.dart';
import 'package:drivers_app/documents/terms_and_conditions.dart';
import 'package:drivers_app/models/driver_data.dart';
import 'package:drivers_app/splashScreen/splash_screen.dart';
import 'package:drivers_app/widgets/progress_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../global/global.dart';

class SignUpScreen extends StatefulWidget {

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {

  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController phoneTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  validateForm()
  {
    if(nameTextEditingController.text.length < 3)
    {
      Fluttertoast.showToast(msg: "Il Nome deve avere almeno 3 Caratteri.");
    }
    else if (!emailTextEditingController.text.contains("@"))
    {
      Fluttertoast.showToast(msg: "Email non Valida.");
    }
    else if (phoneTextEditingController.text.isEmpty)
    {
      Fluttertoast.showToast(msg: "Numero di telefono richiesto.");
    }
    else if (phoneTextEditingController.text.length < 10)
    {
      Fluttertoast.showToast(msg: "Numero di telefono troppo corto.");
    }
    else if (passwordTextEditingController.text.length < 6)
    {
      Fluttertoast.showToast(msg: "La password deve avere almeno 6 Caratteri.");
    }
    else
    {
      SaveDriverInfoNow();
    }
  }

  SaveDriverInfoNow() async
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
          await fAuth.createUserWithEmailAndPassword(
            email: emailTextEditingController.text.trim(),
            password: passwordTextEditingController.text.trim(),
          ).catchError((msg) {
            Navigator.pop(context);
            Fluttertoast.showToast(msg: "Errore: " + msg.toString());
          })
      ).user;


      if (firebaseUser != null) {
        Map driversMap =
        {
          "id": firebaseUser.uid,
          "name": nameTextEditingController.text.trim(),
          "email": emailTextEditingController.text.trim(),
          "phone": phoneTextEditingController.text.trim(),
        };

        DatabaseReference driverRef = FirebaseDatabase.instance.ref().child("drivers");
        driverRef.child(firebaseUser.uid).set(driversMap);

        currentFirebaseUser = firebaseUser;
        //Inviare email di conferma
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
                    border: Border.all(color: Colors.white54),
                    borderRadius: BorderRadius.circular(10.0),
                    color: Colors.white54,
                ),
                child: AlertDialog(
                  backgroundColor: Colors.white54,
                  title: Text("Verifica Email", style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                      textAlign: TextAlign.center),
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
      else {
        Navigator.pop(context);
        Fluttertoast.showToast(msg: "L'account non è stato Creato.");
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
        Fluttertoast.showToast(msg: "Account Creato. Congratulazioni");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [

              const SizedBox(height:30,),

              FittedBox(
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Image.asset("images/logo1.png"),
                ),
              ),
              const SizedBox(height:3,),

              const Text(
                "Registrati come Autista",
                style : TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height:10,),

              TextField(
                controller: nameTextEditingController,
                style: const TextStyle(
                  color: Colors.white
                ),
                decoration: const InputDecoration(
                  labelText: "Nome e Cognome",
                  hintText: "Nome e Cognome",
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
                controller: emailTextEditingController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(
                    color: Colors.white
                ),
                decoration: const InputDecoration(
                  labelText: "Email (Valida come username)",
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
                controller: phoneTextEditingController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(
                    color: Colors.white
                ),
                decoration: const InputDecoration(
                  labelText: "Telefono",
                  hintText: "Telefono",
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
                  primary: Colors.lightGreenAccent,
                ),
                  child: Text(
                    "CREA ACCOUNT",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 20,
                  ),
                  ),
              ),

              TextButton(
                  child: const Text(
                    "Hai già un Account? Accedi Qui",
                    style:TextStyle(color: Colors.white),
                  ),
                  onPressed: ()
                  {
                    Navigator.push(context, MaterialPageRoute(builder: (c)=> LoginScreen()));
                  }
              ),

              const SizedBox(height: 25,),
          FittedBox(
            child:
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(color: Colors.grey,fontSize: 16),
                  children: [
                    const TextSpan(text: 'Registrando un account, accetti i nostri '),
                    TextSpan(
                      text: 'Termini e condizioni\n',
                      style: const TextStyle(color: Colors.white),
                      recognizer: TapGestureRecognizer()..onTap = () { Navigator.push(context,
                          MaterialPageRoute(builder: (c) => TermsAndConditions())); },
                    ),
                    const TextSpan(text: ' e '),
                    TextSpan(
                      text: 'Informativa sulla privacy',
                      style: const TextStyle(color: Colors.white),
                      recognizer: TapGestureRecognizer()..onTap = () { Navigator.push(context,
                          MaterialPageRoute(builder: (c) => PrivacyPolicy())); },
                    ),
                    const TextSpan(text: '.'),
                  ],
                ),
              )
          ),
            ],
          ),
        ),
      ),
    );
  }
}


