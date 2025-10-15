class Task {
  String address;
  String coordinates;
  String locationNotes;
  String category;
  String instructions;
  int urgency;

  Task({
    required this.address,
    required this.coordinates,
    required this.locationNotes,
    required this.category,
    required this.instructions,
    required this.urgency,
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
}