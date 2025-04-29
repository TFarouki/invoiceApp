class InvoiceDetail {
  int? id; // Primary key for the invoice detail
  int invoiceId; // Foreign key referencing the Invoice
  String description;
  int quantity;
  double price;

  InvoiceDetail({
    this.id,
    required this.invoiceId,
    required this.description,
    required this.quantity,
    required this.price,
  });

  // Method to convert from Map (for database operations)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoiceId': invoiceId,
      'description': description,
      'quantity': quantity,
      'price': price,
    };
  }

  // Method to create from Map
  factory InvoiceDetail.fromMap(Map<String, dynamic> map) {
    return InvoiceDetail(
      id: map['id'],
      invoiceId: map['invoiceId'],
      description: map['description'],
      quantity: map['quantity'],
      price: map['price'],
    );
  }

  double get total => quantity * price;
}