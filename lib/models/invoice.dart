class Invoice {
  int? id;
  String refInvoice;
  String date;
  int contactId; // Client
  double totalAmount;
  String action; // "Buy" or "Sell"
  String paymentMethod; // "Cash", "Cheque", "TPE", etc.

  Invoice({
    this.id,
    required this.date,
    required this.refInvoice,
    required this.contactId,
    required this.totalAmount,
    required this.action,
    required this.paymentMethod,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ref_invoice': refInvoice,
      'date': date,
      'contact_id': contactId,
      'total_amount': totalAmount,
      'action': action,
      'payment_method': paymentMethod,
    };
  }

  factory Invoice.fromMap(Map<String, dynamic> map) {
    return Invoice(
      id: map['id'],
      refInvoice: map['ref_invoice'] ?? '',
      date: map['date'] ?? '',
      contactId: map['contact_id'],
      totalAmount: (map['total_amount'] ?? 0.0).toDouble(),
      action: map['action'] ?? '',
      paymentMethod: map['payment_method'] ?? '',
    );
  }
}
