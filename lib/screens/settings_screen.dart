import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../services/settings_provider.dart';
import 'welcome_screen.dart';
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
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Background Shape
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 150,
              height: 150,
              decoration: const BoxDecoration(
                color: Color(0xFFFFB4C4), // Pinkish color from image
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
                        icon: const Icon(Icons.arrow_back, color: Color(0xFF2A2859), size: 30),
                      ),
                      const Text(
                        'Settings',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2A2859),
                          fontFamily: 'Serif',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  
                  // Company Logo Section
                  Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFF3D3B8E),
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
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Company logo',
                            style: TextStyle(
                              fontSize: 18,
                              color: Color(0xFF2A2859),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _pickLogo(context),
                            child: const Text(
                              'Upload new logo',
                              style: TextStyle(
                                color: Color(0xFFE25E31),
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  _buildSectionTitle('Company details'),
                  const SizedBox(height: 10),
                  _buildTextField(
                    initialValue: settings.companyName,
                    onChanged: (val) => settings.updateCompanyName(val),
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    initialValue: settings.companyEmail,
                    onChanged: (val) => settings.updateCompanyEmail(val),
                  ),
                  const SizedBox(height: 30),

                  _buildSectionTitle('Invoice preferences'),
                  const SizedBox(height: 15),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Column(
                      children: [
                        _buildPreferenceItem(
                          'Currency',
                          settings.currency,
                          onTap: () => _showCurrencyDialog(context, settings),
                        ),
                        const Divider(height: 1, indent: 20, endIndent: 20),
                        _buildPreferenceItem(
                          'Default tax rate',
                          '${settings.defaultTaxRate.toStringAsFixed(0)}%',
                          onTap: () => _showTaxDialog(context, settings),
                        ),
                        const Divider(height: 1, indent: 20, endIndent: 20),
                        _buildPreferenceItem(
                          'Invoice prefix',
                          settings.invoicePrefix,
                          onTap: () => _showPrefixDialog(context, settings),
                        ),
                        const Divider(height: 1, indent: 20, endIndent: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Dark mode',
                                style: TextStyle(fontSize: 16, color: Color(0xFF2A2859)),
                              ),
                              Switch(
                                value: settings.isDarkMode,
                                activeColor: const Color(0xFF3D3B8E),
                                onChanged: (val) => settings.toggleDarkMode(val),
                              ),
                            ],
                          ),
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        color: Color(0xFF6C699E),
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildTextField({required String initialValue, required Function(String) onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
      ),
      child: TextFormField(
        initialValue: initialValue,
        onChanged: onChanged,
        decoration: const InputDecoration(
          border: InputBorder.none,
        ),
        style: const TextStyle(color: Color(0xFF2A2859), fontSize: 18),
      ),
    );
  }

  Widget _buildPreferenceItem(String title, String value, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, color: Color(0xFF2A2859))),
            Text(value, style: const TextStyle(fontSize: 16, color: Color(0xFF6C699E))),
          ],
        ),
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
