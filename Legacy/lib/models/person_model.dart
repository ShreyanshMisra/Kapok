import 'package:cloud_firestore/cloud_firestore.dart';

class Person{     //the purpose of this class is to convert the data from json to normal format
  // login info
  String? uid;
  String? email = "";
  String? password = "";
  int? publishedDateTime;

  // name
  String? name = "";
  String? role = "";

  Person({
    // login info
    this.uid,
    this.email,
    this.password,
    this.publishedDateTime,

    // name
    this.name,
    this.role,
  });

  static Person fromdataSnapShot(DocumentSnapshot snapshot){

    var dataSnapshot = snapshot.data() as Map<String, dynamic>;

    return Person(

      // login info
      uid: dataSnapshot["uid"],
      email: dataSnapshot["email"],
      password: dataSnapshot["password"],
      publishedDateTime: dataSnapshot["publishedDateTime"],

      // name
      name: dataSnapshot["name"],
      role: dataSnapshot["role"],

    );
  }

  Map<String, dynamic> toJson()=> {
    // login info
    "uid": uid,
    "email": email,
    "password": password,
    "publishedDateTime": publishedDateTime,

    // name
    "name": name,
    "role": role,

  };
}