class Company {
  int? id;
  String name;
  String? address;
  String? phone;
  String? email;
  String? siren;
  String? logoPath;

  Company({
    this.id,
    required this.name,
    this.address,
    this.phone,
    this.email,
    this.siren,
    this.logoPath,
  });

  // Convert a Company object into a Map object
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'email': email,
      'siren': siren,
      'logo_path': logoPath,
    };
  }

  // Create a Company object from a Map object
  factory Company.fromMap(Map<String, dynamic> map) {
    return Company(
      id: map['id'] as int?,
      name: map['name'] as String,
      address: map['address'] as String?,
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      siren: map['siren'] as String?,
      logoPath: map['logo_path'] as String?,
    );
  }
}
