import 'dart:io';

import 'package:drivers_app/splashScreen/splash_screen.dart';
import 'package:drivers_app/widgets/progress_dialog.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

import '../global/global.dart';

class DocumentsUpdatingScreen extends StatefulWidget {

  @override
  State<DocumentsUpdatingScreen> createState() => _DocumentsUpdatingScreenState();
}

class _DocumentsUpdatingScreenState extends State<DocumentsUpdatingScreen> {
  XFile? frontLicence;
  XFile? retroLicence;
  XFile? frontID;
  XFile? retroID;

  UploadTask? uploadTaskFront;
  UploadTask? uploadTaskBack;
  UploadTask? uploadTaskIDFront;
  UploadTask? uploadTaskIDBack;

  String? downloadURL1;
  String? downloadURL2;
  String? downloadURL3;
  String? downloadURL4;

  DatabaseReference driverRef = FirebaseDatabase.instance.ref()
      .child("drivers")
      .child(currentFirebaseUser!.uid);

  final ImagePicker picker = ImagePicker();

  Future getDocument(ImageSource media, String type) async {
    try {
      var img = await picker.pickImage(source: media);

      if (type == "front") {
        setState(() {
          frontLicence = img;
        });
      } else if (type == "retro") {
        setState(() {
          retroLicence = img;
        });
      } else if (type == "IDfront") {
        setState(() {
          frontID = img;
        });
      } else if (type == "IDretro") {
        setState(() {
          retroID = img;
        });
      }
    } catch (err) {
      print("Error during updating : $err");
    }
  }

  //show popup dialog
  void myAlert(String description, String type) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: CupertinoColors.systemGrey5,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
            title: Text(description, style: const TextStyle(color: Colors.black),),
            content: Container(
              height: MediaQuery
                  .of(context)
                  .size
                  .height / 5,
              child: Column(
                children: [
                  const SizedBox(height: 15,),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CupertinoColors.systemGrey,),
                    //if user click this button, user can upload image from gallery
                    onPressed: () {
                      Navigator.pop(context);
                      getDocument(ImageSource.gallery, type);
                    },
                    child: Row(
                      children: const [
                        Icon(Icons.image),
                        SizedBox(width: 10,),
                        Text('Carica da Galleria'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 13),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CupertinoColors.systemGrey,),
                    //if user click this button. user can upload image from camera
                    onPressed: () {
                      Navigator.pop(context);
                      getDocument(ImageSource.camera, type);
                    },
                    child: Row(
                      children: const [
                        Icon(Icons.camera),
                        SizedBox(width: 10,),
                        Text('Scatta')
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
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
                padding: const EdgeInsets.only(top:30.0,left:30.0,right: 30.0,bottom: 15),
                child: Image.asset("images/logo1.png"),
              ),

              const SizedBox(height:30,),

              const Text(
                "Documenti ",
                style : TextStyle(
                  fontSize: 24,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height:50,),
              const Divider(height: 0.5,thickness: 0.5,color: Colors.grey,),
              const SizedBox(height:50,),

              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  //description
                  const Text("Fronte patente",style: TextStyle(color: Colors.white,fontSize: 20),),
                  const SizedBox(width: 55,),
                  //Button
                  ElevatedButton(
                    onPressed: () {
                      myAlert("Carica front", "front");
                    },
                    child: const Text('CARICA'),
                  ),

                  //if image not null show the image
                  // if image null show text
                  frontLicence != null ?
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        //to show image, you type like this.
                        File(frontLicence!.path),
                        fit: BoxFit.cover,
                        width: 40,
                        height: 35,
                      ),
                    ),
                  )
                      :const Text(""),
                ],
              ),

              const SizedBox(
                height: 15,
              ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Text("Retro patente",style: TextStyle(color: Colors.white,fontSize: 20),),
              const SizedBox(width: 68,),
              ElevatedButton(
                onPressed: () {
                  myAlert("Carica retro", "retro");
                },
                child: const Text('CARICA'),
              ),

              //if image not null show the image
              // if image null show text
              retroLicence != null ?
              Padding(padding: const EdgeInsets.symmetric(horizontal: 15),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    //to show image, you type like this.
                    File(retroLicence!.path),
                    fit: BoxFit.cover,
                    width: 40,
                    height: 35,
                  ),
                ),
              )
                  : const Text(""),
              ],
          ),

              const SizedBox(
                height: 15,
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text("Fronte carta d'identità",style: TextStyle(color: Colors.white,fontSize: 18),),
                  const SizedBox(width: 10,),
                  ElevatedButton(
                    onPressed: () {
                      myAlert("Carica fronte", "IDfront");
                    },
                    child: const Text('CARICA'),
                  ),

                  //if image not null show the image
                  // if image null show text
                  frontID != null ?
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        //to show image, you type like this.
                        File(frontID!.path),
                        fit: BoxFit.cover,
                        width: 40,
                        height: 35,
                      ),
                    ),
                  )
                      : const Text(""),
                ],
              ),

              const SizedBox(
                height: 15,
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text("Retro carta d'identità",style: TextStyle(color: Colors.white,fontSize: 18),),
                  const SizedBox(width: 20,),
                  ElevatedButton(
                    onPressed: () {
                      myAlert("Carica retro", "IDretro");
                    },
                    child: const Text('CARICA'),
                  ),

                  //if image not null show the image
                  // if image null show text
                  retroID != null ?
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        //to show image, you type like this.
                        File(retroID!.path),
                        fit: BoxFit.cover,
                        width: 40,
                        height: 35,
                      ),
                    ),
                  )
                      : const Text(""),
                ],
              ),

              const SizedBox(height: 50,),
              const Divider(height: 0.5,thickness: 0.5,color: Colors.grey,),
              const SizedBox(height:50,),

              ElevatedButton(
                onPressed: () async {
                  if (frontLicence != null && retroLicence != null && frontID!= null && retroID != null) {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext c) => ProgressDialog(message: "Attendere..."),
                    );

                    await uploadDocumentOnStorage();

                    if(downloadURL1 != null && downloadURL2 != null && downloadURL3 != null && downloadURL4 != null) {

                      FirebaseDatabase.instance.ref()
                          .child("drivers")
                          .child(currentFirebaseUser!.uid)
                          .child("hasDriverUploadedDocuments")
                          .set("true");

                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (c) => const MySplashScreen()));

                    }else{
                    Fluttertoast.showToast(msg: "OPS.. Contatta l'assistenza!");
                    }
                  }
                  else {
                    Fluttertoast.showToast(msg: "Documenti Mancanti!");
                  }
                },
                child: const Text('SALVA', style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold,),),
              ),

            ],
          ),
        ),
      ),
    );
  }

  uploadDocumentOnStorage() async {
    // Create a storage reference from our app
    final storageRef = FirebaseStorage.instance.ref();

    // Create a reference to "currentFirebaseUser/frontLicence.jpg"
    final frontRef = storageRef.child(
        "drivers/${currentFirebaseUser!.email}/frontLicence.jpg");

    // Create a reference to "currentFirebaseUser/backLicence.jpg"
    final backRef = storageRef.child(
        "drivers/${currentFirebaseUser!.email}/backLicence.jpg");

    // Create a reference to "currentFirebaseUser/frontID.jpg"
    final frontIDRef = storageRef.child(
        "drivers/${currentFirebaseUser!.email}/frontID.jpg");

    // Create a reference to "currentFirebaseUser/backID.jpg"
    final backIDRef = storageRef.child(
        "drivers/${currentFirebaseUser!.email}/backID.jpg");


    // Upload the file to the paths
    uploadTaskFront = frontRef.putFile(File(frontLicence!.path));
    downloadURL1 = await (await uploadTaskFront)!.ref.getDownloadURL();

    uploadTaskBack = backRef.putFile(File(retroLicence!.path));
    downloadURL2 = await (await uploadTaskBack)!.ref.getDownloadURL();

    uploadTaskIDFront = frontIDRef.putFile(File(frontID!.path));
    downloadURL3 = await (await uploadTaskIDFront)!.ref.getDownloadURL();

    uploadTaskIDBack = backIDRef.putFile(File(retroID!.path));
    downloadURL4 = await (await uploadTaskIDBack)!.ref.getDownloadURL();



    print("QUESTO è IL DOWNDLOAD URL ::: $downloadURL2 --- $downloadURL1");
  }

}

