import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  String address;
  String coordinates;
  String locationNotes;
  String category;
  String instructions;
  int urgency;
  String? id; //fire store doc id

  Task({
    required this.address,
    required this.coordinates,
    required this.locationNotes,
    required this.category,
    required this.instructions,
    required this.urgency,
    this.id,
  });

  Map<String, dynamic> toMap() {
    return {
      'address': address,
      'coordinates': coordinates,
      'locationNotes': locationNotes,
      'category': category,
      'instructions': instructions,
      'urgency': urgency,
    };
  }

  factory Task.fromFirestore(DocumentSnapshot snapshot) {
    var data = snapshot.data() as Map<String, dynamic>;
    return Task(
      id: snapshot.id,
      address: data['address'],
      coordinates: data['coordinates'],
      locationNotes: data['locationNotes'],
      category: data['category'],
      instructions: data['instructions'],
      urgency: data['urgency'],
    );
  }
}
