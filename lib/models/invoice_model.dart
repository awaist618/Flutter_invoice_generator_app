import 'package:uuid/uuid.dart';

enum InvoiceStatus { paid, unpaid, overdue }

class Invoice {
  final String id;
  final String invoiceNumber;
  final String customerName;
  final double amount;
  final DateTime date;
  final DateTime dueDate;
  final InvoiceStatus status;

  Invoice({
    String? id,
    required this.invoiceNumber,
    required this.customerName,
    required this.amount,
    required this.date,
    required this.dueDate,
    this.status = InvoiceStatus.unpaid,
  }) : id = id ?? Uuid().v4();
}
