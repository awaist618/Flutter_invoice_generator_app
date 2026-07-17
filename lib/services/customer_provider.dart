import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/customer_model.dart';

class CustomerProvider with ChangeNotifier {
  List<Customer> _customers = [];

  List<Customer> get customers => _customers;
  List<Customer> get favoriteCustomers => _customers.where((c) => c.isFavorite).toList();

  CustomerProvider() {
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    final prefs = await SharedPreferences.getInstance();
    final String? customersJson = prefs.getString('customers');
    if (customersJson != null) {
      final List<dynamic> decoded = jsonDecode(customersJson);
      _customers = decoded.map((item) => Customer.fromJson(item)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveCustomers() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_customers.map((c) => c.toJson()).toList());
    await prefs.setString('customers', encoded);
  }

  void addCustomer(Customer customer) {
    _customers.add(customer);
    _saveCustomers();
    notifyListeners();
  }

  void updateCustomer(Customer customer) {
    final index = _customers.indexWhere((c) => c.id == customer.id);
    if (index != -1) {
      _customers[index] = customer;
      _saveCustomers();
      notifyListeners();
    }
  }

  void toggleFavorite(String id) {
    final index = _customers.indexWhere((c) => c.id == id);
    if (index != -1) {
      _customers[index] = _customers[index].copyWith(isFavorite: !_customers[index].isFavorite);
      _saveCustomers();
      notifyListeners();
    }
  }

  void deleteCustomer(String id) {
    _customers.removeWhere((c) => c.id == id);
    _saveCustomers();
    notifyListeners();
  }
}
