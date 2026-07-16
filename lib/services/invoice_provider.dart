import 'package:flutter/material.dart';
import '../models/invoice_model.dart';

class InvoiceProvider with ChangeNotifier {
  final List<Invoice> _invoices = [];

  List<Invoice> get invoices => [..._invoices];

  List<Invoice> get recentInvoices => _invoices.reversed.take(5).toList();

  double get totalRevenue => _invoices
      .where((inv) => inv.status == InvoiceStatus.paid)
      .fold(0.0, (sum, inv) => sum + inv.total);

  int get totalInvoicesCount => _invoices.length;
  
  String get nextInvoiceNumber {
    return 'INV-${(100 + _invoices.length + 1).toString()}';
  }

  int get paidCount => _invoices.where((inv) => inv.status == InvoiceStatus.paid).length;
  int get unpaidCount => _invoices.where((inv) => inv.status == InvoiceStatus.unpaid).length;

  void addInvoice(Invoice invoice) {
    _invoices.add(invoice);
    notifyListeners();
  }

  // Initializing with some dummy data that feels "real" for testing
  void loadInvoices() {
    if (_invoices.isEmpty) {
      addInvoice(Invoice(
        invoiceNumber: 'INV-108',
        customerName: 'Maria Chen',
        customerEmail: 'maria@example.com',
        date: DateTime.now().subtract(const Duration(days: 2)),
        dueDate: DateTime.now().add(const Duration(days: 5)),
        status: InvoiceStatus.paid,
        items: [InvoiceItem(name: 'Web Design', quantity: 1, unitPrice: 1240)],
      ));
      addInvoice(Invoice(
        invoiceNumber: 'INV-107',
        customerName: 'Daniel Osei',
        customerEmail: 'daniel@example.com',
        date: DateTime.now().subtract(const Duration(days: 10)),
        dueDate: DateTime.now().subtract(const Duration(days: 1)),
        status: InvoiceStatus.overdue,
        items: [InvoiceItem(name: 'App Audit', quantity: 2, unitPrice: 430)],
      ));
      addInvoice(Invoice(
        invoiceNumber: 'INV-106',
        customerName: 'Priya Nair',
        customerEmail: 'priya@example.com',
        date: DateTime.now().subtract(const Duration(days: 1)),
        dueDate: DateTime.now().add(const Duration(days: 1)), // Due tomorrow!
        status: InvoiceStatus.unpaid,
        items: [InvoiceItem(name: 'Social Media Management', quantity: 1, unitPrice: 2015)],
      ));
    }
  }
}
