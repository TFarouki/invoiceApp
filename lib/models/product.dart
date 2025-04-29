class Product {
  int? id;
  String name;
  double unitPrice;
  double tvaRate;
  String? imagePath; // New field for image path

  Product({this.id, required this.name, required this.unitPrice, required this.tvaRate, this.imagePath});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'unit_price': unitPrice,
      'tva_rate': tvaRate,
      'image_path': imagePath, // Add to map
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int?,
      name: map['name'] as String,
      unitPrice: map['unit_price'] as double,
      tvaRate: map['tva_rate'] as double,
      imagePath: map['image_path'] as String?, // Add from map
    );
  }
}