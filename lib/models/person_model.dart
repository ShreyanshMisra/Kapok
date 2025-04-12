import 'package:cloud_firestore/cloud_firestore.dart';

class Person {
  String? uid;
  String? email;
  String? password;
  int? publishedDateTime;
  String? name;
  String? role;

  Person({
    this.uid,
    this.email,
    this.password,
    this.publishedDateTime,
    this.name,
    this.role,
  });

  static Person fromdataSnapShot(DocumentSnapshot snapshot) {
    var data = snapshot.data() as Map<String, dynamic>;

    return Person(
      uid: data["uid"],
      email: data["email"],
      password: data["password"],
      publishedDateTime: data["publishedDateTime"],
      name: data["name"],
      role: data["role"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "uid": uid,
      "email": email,
      "password": password,
      "publishedDateTime": publishedDateTime,
      "name": name,
      "role": role,
    };
  }
}
