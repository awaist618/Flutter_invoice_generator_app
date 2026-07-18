import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../services/settings_provider.dart';
import '../services/invoice_provider.dart';
import 'welcome_screen.dart';
import 'about_developer_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _pickLogo(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      Provider.of<SettingsProvider>(context, listen: false)
          .updateLogoPath(pickedFile.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final invoiceProvider = Provider.of<InvoiceProvider>(context, listen: false);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background Shape
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: const Color(0xFFFFB4C4).withOpacity(isDark ? 0.3 : 1.0),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        alignment: Alignment.centerLeft,
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.arrow_back, color: colorScheme.onSurface, size: 30),
                      ),
                      Text(
                        'Settings',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                          fontFamily: 'Serif',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  
                  // Company Logo Section
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => _pickLogo(context),
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(20),
                            image: settings.logoPath != null
                                ? DecorationImage(
                                    image: FileImage(File(settings.logoPath!)),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: settings.logoPath == null
                              ? const Icon(Icons.business, color: Colors.white, size: 40)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Company logo',
                            style: TextStyle(
                              fontSize: 18,
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _pickLogo(context),
                            child: Text(
                              'Upload new logo',
                              style: TextStyle(
                                color: colorScheme.secondary,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  _buildSectionTitle('Company details', colorScheme),
                  const SizedBox(height: 10),
                  _buildTextField(
                    initialValue: settings.companyName,
                    onChanged: (val) => settings.updateCompanyName(val),
                    colorScheme: colorScheme,
                    isDark: isDark,
                    hint: 'Company Name',
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    initialValue: settings.companyAddress,
                    onChanged: (val) => settings.updateCompanyAddress(val),
                    colorScheme: colorScheme,
                    isDark: isDark,
                    hint: 'Company Address',
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    initialValue: settings.companyEmail,
                    onChanged: (val) => settings.updateCompanyEmail(val),
                    colorScheme: colorScheme,
                    isDark: isDark,
                    hint: 'Company Email',
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    initialValue: settings.companyPhone,
                    onChanged: (val) => settings.updateCompanyPhone(val),
                    colorScheme: colorScheme,
                    isDark: isDark,
                    hint: 'Company Phone',
                  ),
                  const SizedBox(height: 30),

                  _buildSectionTitle('Payment Details (QR Code)', colorScheme),
                  const SizedBox(height: 10),
                  _buildTextField(
                    initialValue: settings.paymentDetails,
                    onChanged: (val) => settings.updatePaymentDetails(val),
                    colorScheme: colorScheme,
                    isDark: isDark,
                    hint: 'JazzCash / Bank Details',
                  ),
                  const SizedBox(height: 30),

                  _buildSectionTitle('Invoice preferences', colorScheme),
                  const SizedBox(height: 15),
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(25),
                      border: isDark ? Border.all(color: Colors.white12) : null,
                    ),
                    child: Column(
                      children: [
                        _buildPreferenceItem(
                          'Invoice Template',
                          settings.selectedTemplate,
                          onTap: () => _showTemplateDialog(context, settings),
                          colorScheme: colorScheme,
                        ),
                        Divider(height: 1, indent: 20, endIndent: 20, color: isDark ? Colors.white12 : Colors.grey.shade200),
                        _buildPreferenceItem(
                          'Currency',
                          settings.currency,
                          onTap: () => _showCurrencyDialog(context, settings),
                          colorScheme: colorScheme,
                        ),
                        Divider(height: 1, indent: 20, endIndent: 20, color: isDark ? Colors.white12 : Colors.grey.shade200),
                        _buildPreferenceItem(
                          'Default tax rate',
                          '${settings.defaultTaxRate.toStringAsFixed(0)}%',
                          onTap: () => _showTaxDialog(context, settings),
                          colorScheme: colorScheme,
                        ),
                        Divider(height: 1, indent: 20, endIndent: 20, color: isDark ? Colors.white12 : Colors.grey.shade200),
                        _buildPreferenceItem(
                          'Invoice prefix',
                          settings.invoicePrefix,
                          onTap: () => _showPrefixDialog(context, settings),
                          colorScheme: colorScheme,
                        ),
                        Divider(height: 1, indent: 20, endIndent: 20, color: isDark ? Colors.white12 : Colors.grey.shade200),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Dark mode',
                                style: TextStyle(fontSize: 16, color: colorScheme.onSurface),
                              ),
                              Switch(
                                value: settings.isDarkMode,
                                activeColor: colorScheme.primary,
                                onChanged: (val) => settings.toggleDarkMode(val),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  _buildSectionTitle('Data Management', colorScheme),
                  const SizedBox(height: 15),
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(25),
                      border: isDark ? Border.all(color: Colors.white12) : null,
                    ),
                    child: Column(
                      children: [
                        _buildPreferenceItem(
                          'Backup Data',
                          'Share Backup',
                          onTap: () => invoiceProvider.backupData(),
                          colorScheme: colorScheme,
                        ),
                        Divider(height: 1, indent: 20, endIndent: 20, color: isDark ? Colors.white12 : Colors.grey.shade200),
                        _buildPreferenceItem(
                          'About Developer',
                          '',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const AboutDeveloperScreen()),
                            );
                          },
                          colorScheme: colorScheme,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Log out Button
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF962D4D), // Burgundy color
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Log out',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, ColorScheme colorScheme) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        color: colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildTextField({
    required String initialValue,
    required Function(String) onChanged,
    required ColorScheme colorScheme,
    required bool isDark,
    String? hint,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(5),
        border: isDark ? Border.all(color: Colors.white12) : null,
      ),
      child: TextFormField(
        initialValue: initialValue,
        onChanged: onChanged,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: TextStyle(color: colorScheme.onSurfaceVariant.withOpacity(0.5)),
        ),
        style: TextStyle(color: colorScheme.onSurface, fontSize: 18),
      ),
    );
  }

  Widget _buildPreferenceItem(String title, String value, {required VoidCallback onTap, required ColorScheme colorScheme}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(fontSize: 16, color: colorScheme.onSurface)),
            Text(value, style: TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  void _showTemplateDialog(BuildContext context, SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select Template'),
        children: ['Modern', 'Minimal'].map((e) {
          return SimpleDialogOption(
            onPressed: () {
              settings.updateTemplate(e);
              Navigator.pop(context);
            },
            child: Text(e),
          );
        }).toList(),
      ),
    );
  }

  void _showCurrencyDialog(BuildContext context, SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select Currency'),
        children: [r'USD ($)', r'EUR (€)', r'GBP (£)', r'PKR (Rs)', r'INR (₹)'].map((e) {
          return SimpleDialogOption(
            onPressed: () {
              settings.updateCurrency(e);
              Navigator.pop(context);
            },
            child: Text(e),
          );
        }).toList(),
      ),
    );
  }

  void _showTaxDialog(BuildContext context, SettingsProvider settings) {
    final controller = TextEditingController(text: settings.defaultTaxRate.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Default Tax Rate (%)'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              settings.updateTaxRate(double.tryParse(controller.text) ?? 0);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showPrefixDialog(BuildContext context, SettingsProvider settings) {
    final controller = TextEditingController(text: settings.invoicePrefix);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invoice Prefix'),
        content: TextField(controller: controller),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              settings.updatePrefix(controller.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

