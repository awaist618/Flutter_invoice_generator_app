import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/invoice_model.dart';
import 'package:intl/intl.dart';
import 'notification_service.dart';

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
// import 'package:file_picker/file_picker.dart';

class InvoiceProvider with ChangeNotifier {
  final List<Invoice> _invoices = [];

  List<Invoice> get invoices => [..._invoices];

  // ... (rest of the getters)

  Future<void> exportToCsv() async {
    List<List<dynamic>> rows = [];
    
    // Add header
    rows.add([
      "Invoice Number",
      "Customer Name",
      "Customer Email",
      "Date",
      "Due Date",
      "Status",
      "Subtotal",
      "Tax Amount",
      "Total"
    ]);

    for (var inv in _invoices) {
      rows.add([
        inv.invoiceNumber,
        inv.customerName,
        inv.customerEmail,
        DateFormat('yyyy-MM-dd').format(inv.date),
        DateFormat('yyyy-MM-dd').format(inv.dueDate),
        inv.status.name,
        inv.subtotal,
        inv.taxAmount,
        inv.total
      ]);
    }

    String csvData = const ListToCsvConverter().convert(rows);
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/invoices_export.csv');
    await file.writeAsString(csvData);
    
    await Share.shareXFiles([XFile(file.path)], text: 'Invoices Export');
  }

  Future<void> backupData() async {
    final data = jsonEncode(_invoices.map((e) => e.toJson()).toList());
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/invoicely_backup.json');
    await file.writeAsString(data);
    
    await Share.shareXFiles([XFile(file.path)], text: 'Invoicely Data Backup');
  }

  Future<bool> restoreData() async {
    // Feature removed due to build issues with file_picker
    debugPrint('Restore feature is currently disabled');
    return false;
    /*
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      String content = await file.readAsString();
      try {
        final List decoded = jsonDecode(content);
        _invoices.clear();
        _invoices.addAll(decoded.map((e) => Invoice.fromJson(e)).toList());
        await _saveToLocal();
        notifyListeners();
        return true;
      } catch (e) {
        debugPrint('Restore failed: $e');
        return false;
      }
    }
    return false;
    */
  }

  // ... (rest of the methods)

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

  Map<String, double> get monthlyRevenue {
    Map<String, double> data = {};
    final now = DateTime.now();
    for (int i = 5; i >= 0; i--) {
      DateTime date = DateTime(now.year, now.month - i, 1);
      String monthName = DateFormat('MMM').format(date);
      double total = _invoices
          .where((inv) => inv.date.month == date.month && inv.date.year == date.year && inv.status == InvoiceStatus.paid)
          .fold(0.0, (sum, inv) => sum + inv.total);
      data[monthName] = total;
    }
    return data;
  }

  double get revenueGrowth => 12.4; // Demo value

  Future<void> addInvoice(Invoice invoice) async {
    _invoices.add(invoice);
    _checkOverdueStatus();
    await _saveToLocal();
    
    // Schedule notification for due date
    try {
      await NotificationService().scheduleInvoiceReminders(
        invoice.id.hashCode,
        invoice.invoiceNumber,
        invoice.dueDate,
      );
    } catch (e) {
      debugPrint('Failed to schedule notification: $e');
    }

    notifyListeners();
  }

  Future<void> deleteInvoice(String id) async {
    final index = _invoices.indexWhere((inv) => inv.id == id);
    if (index != -1) {
      final invoice = _invoices[index];
      // Cancel notifications
      try {
        await NotificationService().cancelAllReminders(invoice.id.hashCode);
      } catch (e) {
        debugPrint('Failed to cancel notifications: $e');
      }
      _invoices.removeAt(index);
      await _saveToLocal();
      notifyListeners();
    }
  }

  Future<void> updateInvoiceStatus(String id, InvoiceStatus newStatus) async {
    final index = _invoices.indexWhere((inv) => inv.id == id);
    if (index != -1) {
      final invoice = _invoices[index];
      _invoices[index] = invoice.copyWith(status: newStatus);
      
      // Cancel notifications if paid
      if (newStatus == InvoiceStatus.paid) {
        try {
          await NotificationService().cancelAllReminders(invoice.id.hashCode);
        } catch (e) {
          debugPrint('Failed to cancel notifications: $e');
        }
      }

      await _saveToLocal();
      notifyListeners();
    }
  }

  void _checkOverdueStatus() {
    final now = DateTime.now();
    bool changed = false;
    for (int i = 0; i < _invoices.length; i++) {
      if (_invoices[i].status == InvoiceStatus.unpaid &&
          _invoices[i].dueDate.isBefore(DateTime(now.year, now.month, now.day))) {
        _invoices[i] = _invoices[i].copyWith(status: InvoiceStatus.overdue);
        changed = true;
      }
    }
    if (changed) {
      _saveToLocal();
    }
  }

  Future<void> _saveToLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(_invoices.map((e) => e.toJson()).toList());
    await prefs.setString('invoices', data);
  }

  Future<void> loadInvoices() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('invoices');
    
    if (data != null) {
      final List decoded = jsonDecode(data);
      _invoices.clear();
      _invoices.addAll(decoded.map((e) => Invoice.fromJson(e)).toList());
      _checkOverdueStatus();
    } else {
      // Initializing with some dummy data if nothing is saved
      _invoices.clear();
      _invoices.add(Invoice(
        invoiceNumber: 'INV-108',
        customerName: 'Maria Chen',
        customerEmail: 'maria@example.com',
        customerAddress: '18 Willow Ave, Denver, CO 80203',
        customerPhone: '+1 (303) 555-0199',
        date: DateTime.now().subtract(const Duration(days: 2)),
        dueDate: DateTime.now().add(const Duration(days: 5)),
        status: InvoiceStatus.paid,
        items: [InvoiceItem(name: 'Web Design', quantity: 1, unitPrice: 1240)],
      ));
      _invoices.add(Invoice(
        invoiceNumber: 'INV-107',
        customerName: 'Daniel Osei',
        customerEmail: 'daniel@example.com',
        customerAddress: '55 East St, Houston, TX 77002',
        customerPhone: '+1 (713) 555-0144',
        date: DateTime.now().subtract(const Duration(days: 10)),
        dueDate: DateTime.now().subtract(const Duration(days: 1)),
        status: InvoiceStatus.overdue,
        items: [InvoiceItem(name: 'App Audit', quantity: 2, unitPrice: 430)],
      ));
      _invoices.add(Invoice(
        invoiceNumber: 'INV-106',
        customerName: 'Priya Nair',
        customerEmail: 'priya@example.com',
        customerAddress: '99 North Rd, Seattle, WA 98101',
        customerPhone: '+1 (206) 555-0122',
        date: DateTime.now().subtract(const Duration(days: 1)),
        dueDate: DateTime.now().add(const Duration(days: 1)), // Due tomorrow!
        status: InvoiceStatus.unpaid,
        items: [InvoiceItem(name: 'Social Media Management', quantity: 1, unitPrice: 2015)],
      ));
      await _saveToLocal();
    }
    notifyListeners();
  }
}
