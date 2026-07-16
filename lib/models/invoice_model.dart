import 'package:uuid/uuid.dart';

enum InvoiceStatus { paid, unpaid, overdue }

class InvoiceItem {
  final String name;
  final int quantity;
  final double unitPrice;
  final double discountPercent;

  InvoiceItem({
    required this.name,
    required this.quantity,
    required this.unitPrice,
    this.discountPercent = 0,
  });

  double get subtotal => quantity * unitPrice;
  double get total => subtotal * (1 - discountPercent / 100);

  Map<String, dynamic> toJson() => {
    'name': name,
    'quantity': quantity,
    'unitPrice': unitPrice,
    'discountPercent': discountPercent,
  };

  factory InvoiceItem.fromJson(Map<String, dynamic> json) => InvoiceItem(
    name: json['name'],
    quantity: json['quantity'],
    unitPrice: (json['unitPrice'] as num).toDouble(),
    discountPercent: (json['discountPercent'] as num).toDouble(),
  );
}

class Invoice {
  final String id;
  final String invoiceNumber;
  final String customerName;
  final String customerEmail;
  final String customerAddress;
  final String customerPhone;
  final DateTime date;
  final DateTime dueDate;
  final List<InvoiceItem> items;
  final double taxRate;
  final InvoiceStatus status;
  final String notes;
  final String paymentInstructions;

  Invoice({
    String? id,
    required this.invoiceNumber,
    required this.customerName,
    required this.customerEmail,
    this.customerAddress = '18 Willow Ave, Denver, CO 80203',
    this.customerPhone = '+1 (303) 555-0199',
    required this.date,
    required this.dueDate,
    required this.items,
    this.taxRate = 8.0,
    this.status = InvoiceStatus.unpaid,
    this.notes = '',
    this.paymentInstructions = '',
  }) : id = id ?? const Uuid().v4();

  double get subtotal => items.fold(0, (sum, item) => sum + item.total);
  double get taxAmount => subtotal * (taxRate / 100);
  double get total => subtotal + taxAmount;

  Map<String, dynamic> toJson() => {
    'id': id,
    'invoiceNumber': invoiceNumber,
    'customerName': customerName,
    'customerEmail': customerEmail,
    'customerAddress': customerAddress,
    'customerPhone': customerPhone,
    'date': date.toIso8601String(),
    'dueDate': dueDate.toIso8601String(),
    'items': items.map((e) => e.toJson()).toList(),
    'taxRate': taxRate,
    'status': status.index,
    'notes': notes,
    'paymentInstructions': paymentInstructions,
  };

  factory Invoice.fromJson(Map<String, dynamic> json) => Invoice(
    id: json['id'],
    invoiceNumber: json['invoiceNumber'],
    customerName: json['customerName'],
    customerEmail: json['customerEmail'],
    customerAddress: json['customerAddress'] ?? '18 Willow Ave, Denver, CO 80203',
    customerPhone: json['customerPhone'] ?? '+1 (303) 555-0199',
    date: DateTime.parse(json['date']),
    dueDate: DateTime.parse(json['dueDate']),
    items: (json['items'] as List).map((e) => InvoiceItem.fromJson(e)).toList(),
    taxRate: (json['taxRate'] as num).toDouble(),
    status: InvoiceStatus.values[json['status']],
    notes: json['notes'] ?? '',
    paymentInstructions: json['paymentInstructions'] ?? '',
  );
}
