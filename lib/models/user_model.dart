import 'package:firebase_database/firebase_database.dart';

class UserModel
{
  String? name;
  String? phone;
  String? id;
  String? email;

  UserModel({this.phone, this.name, this.id, this.email});

  UserModel.fromSnapshot(DataSnapshot snap)
  {
    name = (snap.value as dynamic) ["name"];
    phone = (snap.value as dynamic) ["phone"];
    id = snap.key;
    email = (snap.value as dynamic) ["email"];
  }
}