class Contact {
  int? id;
  String name;
  String? address; // Make address nullable
  String? phoneNumber; // Make phoneNumber nullable
  String? email;
  String? siren;

  Contact({
    this.id,
    required this.name,
    this.address,
    this.phoneNumber,
    this.email,
    this.siren,
  });

  // Convert a Contact object into a Map object
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phoneNumber': phoneNumber,
      'email': email,
      'siren': siren,
    };
  }

  // Create a Contact object from a Map object
  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'],
      name: map['name'],
      address: map['address'],
      phoneNumber: map['phoneNumber'],
      email: map['email'],
      siren: map['siren'],
    );
  }
}