import 'package:flutter/material.dart';

class SettingsProvider with ChangeNotifier {
  String _companyName = 'Acme Studio';
  String _companyEmail = 'hello@acmestudio.com';
  String _currency = r'USD ($)';
  double _defaultTaxRate = 8.0;
  String _invoicePrefix = 'INV-';
  bool _isDarkMode = false;
  String? _logoPath;

  // Getters
  String get companyName => _companyName;
  String get companyEmail => _companyEmail;
  String get currency => _currency;
  
  String get currencySymbol {
    if (_currency.contains('(')) {
      return _currency.split('(').last.replaceAll(')', '');
    }
    return r'$';
  }
  double get defaultTaxRate => _defaultTaxRate;
  String get invoicePrefix => _invoicePrefix;
  bool get isDarkMode => _isDarkMode;
  String? get logoPath => _logoPath;

  // Setters
  void updateCompanyName(String name) {
    _companyName = name;
    notifyListeners();
  }

  void updateCompanyEmail(String email) {
    _companyEmail = email;
    notifyListeners();
  }

  void updateCurrency(String currency) {
    _currency = currency;
    notifyListeners();
  }

  void updateTaxRate(double rate) {
    _defaultTaxRate = rate;
    notifyListeners();
  }

  void updatePrefix(String prefix) {
    _invoicePrefix = prefix;
    notifyListeners();
  }

  void toggleDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }

  void updateLogoPath(String? path) {
    _logoPath = path;
    notifyListeners();
  }
}
