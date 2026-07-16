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
}

class Invoice {
  final String id;
  final String invoiceNumber;
  final String customerName;
  final String customerEmail;
  final DateTime date;
  final DateTime dueDate;
  final List<InvoiceItem> items;
  final double taxRate;
  final InvoiceStatus status;

  Invoice({
    String? id,
    required this.invoiceNumber,
    required this.customerName,
    required this.customerEmail,
    required this.date,
    required this.dueDate,
    required this.items,
    this.taxRate = 8.0,
    this.status = InvoiceStatus.unpaid,
  }) : id = id ?? const Uuid().v4();

  double get subtotal => items.fold(0, (sum, item) => sum + item.total);
  double get taxAmount => subtotal * (taxRate / 100);
  double get total => subtotal + taxAmount;
}
