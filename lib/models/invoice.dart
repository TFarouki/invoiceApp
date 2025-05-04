class Invoice {
  int? id;
  int refInvoice;
  DateTime date;
  String action; // 'Sell' or 'Buy'
  int contactId;
  double total;
  String paymentMethod;

  Invoice({
    this.id,
    required this.refInvoice,
    required this.date,
    required this.action,
    required this.contactId,
    required this.total,
    required this.paymentMethod,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'refInvoice': refInvoice,
      'date': date.millisecondsSinceEpoch, // Stored as integer
      'action': action,
      'contactId': contactId,
      'total': total,
      'paymentMethod': paymentMethod,
    };
  }

  factory Invoice.fromMap(Map<String, dynamic> map) {
    return Invoice(
      id: map['id'],
      refInvoice: map['refInvoice'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      action: map['action'],
      contactId: map['contactId'],
      total: map['total'],
      paymentMethod: map['paymentMethod'],
    );
  }
}
