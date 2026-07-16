import 'package:flutter/material.dart';

class SettingsProvider with ChangeNotifier {
  String _companyName = 'Acme Studio';
  String _companyEmail = 'hello@acmestudio.com';
  String _companyAddress = '42 Market St, Austin, TX';
  String _companyPhone = '+1 (512) 555-0123';
  String _currency = r'USD ($)';
  double _defaultTaxRate = 8.0;
  String _invoicePrefix = 'INV-';
  bool _isDarkMode = false;
  String? _logoPath;

  // Getters
  String get companyName => _companyName;
  String get companyEmail => _companyEmail;
  String get companyAddress => _companyAddress;
  String get companyPhone => _companyPhone;
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

  void updateCompanyAddress(String address) {
    _companyAddress = address;
    notifyListeners();
  }

  void updateCompanyPhone(String phone) {
    _companyPhone = phone;
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
