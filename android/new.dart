class InvoiceItem {
  String description;
  int quantity;
  double price;

  InvoiceItem({
    required this.description,
    required this.quantity,
    required this.price,
  });

  double get total => quantity * price;
}