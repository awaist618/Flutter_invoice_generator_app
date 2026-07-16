import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/invoice_model.dart';
import '../services/invoice_provider.dart';
import '../services/settings_provider.dart';
import '../services/notification_service.dart';

class CreateInvoiceScreen extends StatefulWidget {
  const CreateInvoiceScreen({super.key});

  @override
  State<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  
  DateTime _invoiceDate = DateTime.now();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 14));
  final List<InvoiceItem> _items = [];
  String _generatedInvoiceNo = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = Provider.of<SettingsProvider>(context, listen: false);
      setState(() {
        _generatedInvoiceNo = settings.invoicePrefix + 
            (100 + Provider.of<InvoiceProvider>(context, listen: false).invoices.length + 1).toString();
      });
    });
  }

  Future<void> _selectDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFE25E31),
              onPrimary: Colors.white,
              onSurface: Color(0xFF2A2859),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  void _addItem() {
    final nameController = TextEditingController();
    final qtyController = TextEditingController(text: '1');
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Add New Item', style: TextStyle(color: Color(0xFF2A2859), fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogField(nameController, 'Item name', TextInputType.text),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _buildDialogField(qtyController, 'Qty', TextInputType.number)),
                const SizedBox(width: 10),
                Expanded(child: _buildDialogField(priceController, 'Price', TextInputType.number)),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && priceController.text.isNotEmpty) {
                setState(() {
                  _items.add(InvoiceItem(
                    name: nameController.text,
                    quantity: int.tryParse(qtyController.text) ?? 1,
                    unitPrice: double.tryParse(priceController.text) ?? 0.0,
                  ));
                });
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3D3B8E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogField(TextEditingController controller, String hint, TextInputType type) {
    return TextField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF3F2FF),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      ),
    );
  }

  double _calculateSubtotal() => _items.fold(0, (sum, item) => sum + item.total);
  double _calculateTax(double rate) => _calculateSubtotal() * (rate / 100);
  double _calculateTotal(double rate) => _calculateSubtotal() + _calculateTax(rate);

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final subtotal = _calculateSubtotal();
    final taxAmount = _calculateTax(settings.defaultTaxRate);
    final total = _calculateTotal(settings.defaultTaxRate);
    return Scaffold(
      backgroundColor: const Color(0xFFF3F2FF),
      body: Stack(
        children: [
          // Background Decoration (Top Right)
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: const BoxDecoration(
                color: Color(0xFF66D1A4),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: Color(0xFF126E51),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(25),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      alignment: Alignment.centerLeft,
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Color(0xFF2A2859), size: 30),
                    ),
                    const Center(
                      child: Text(
                        'New invoice',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2A2859),
                          fontFamily: 'Serif',
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Top Info Row
                    Row(
                      children: [
                        _buildTopInfoCard('Invoice no.', _generatedInvoiceNo.isEmpty ? 'Loading...' : _generatedInvoiceNo),
                        const SizedBox(width: 10),
                        _buildTopInfoCard('Invoice date', DateFormat('MMM dd').format(_invoiceDate)),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: _selectDueDate,
                          child: _buildTopInfoCard('Due date', DateFormat('MMM dd').format(_dueDate)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Customer Section
                    const Text(
                      'Customer',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2A2859),
                        fontFamily: 'Serif',
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(_nameController, 'Customer name'),
                    const SizedBox(height: 10),
                    _buildTextField(_emailController, 'Email address'),
                    
                    const SizedBox(height: 30),

                    // Items Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Items',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2A2859),
                            fontFamily: 'Serif',
                          ),
                        ),
                        GestureDetector(
                          onTap: _addItem,
                          child: const Text(
                            'Add item',
                            style: TextStyle(color: Color(0xFFE25E31), fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    
                    // Items List
                    ..._items.map((item) => _buildItemTile(item)),

                    const SizedBox(height: 30),

                    // Summary Card
                    Container(
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3D3B8E),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Column(
                        children: [
                          _buildSummaryRow('Subtotal', settings.currencySymbol + subtotal.toStringAsFixed(2)),
                          const SizedBox(height: 10),
                          _buildSummaryRow('Tax (${settings.defaultTaxRate.toStringAsFixed(0)}%)', settings.currencySymbol + taxAmount.toStringAsFixed(2)),
                          const SizedBox(height: 20),
                          const Divider(color: Colors.white24),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Grand total',
                                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                settings.currencySymbol + total.toStringAsFixed(2),
                                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Create Button
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate() && _items.isNotEmpty) {
                            final newInvoice = Invoice(
                              invoiceNumber: _generatedInvoiceNo,
                              customerName: _nameController.text,
                              customerEmail: _emailController.text,
                              date: _invoiceDate,
                              dueDate: _dueDate,
                              items: List.from(_items),
                              taxRate: settings.defaultTaxRate,
                            );
                            Provider.of<InvoiceProvider>(context, listen: false).addInvoice(newInvoice);
                            
                            // Schedule notification
                            NotificationService().scheduleDueDateNotification(
                              newInvoice.hashCode, 
                              newInvoice.invoiceNumber, 
                              newInvoice.dueDate
                            );

                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE25E31),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          elevation: 0,
                        ),
                        child: const Text('Create Invoice', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopInfoCard(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(color: Color(0xFF6C699E), fontSize: 12)),
            const SizedBox(height: 5),
            Text(value, style: const TextStyle(color: Color(0xFF2A2859), fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (val) => val!.isEmpty ? 'Required' : null,
    );
  }

  Widget _buildItemTile(InvoiceItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 6,
              decoration: const BoxDecoration(
                color: Color(0xFF3D3B8E),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2A2859)),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Qty ${item.quantity}  ·  \$${item.unitPrice.toStringAsFixed(2)}${item.discountPercent > 0 ? '  ·  ${item.discountPercent.toStringAsFixed(0)}% off' : ''}',
                          style: const TextStyle(color: Color(0xFF6C699E)),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: Color(0xFFE05275), size: 24),
                      onPressed: () {
                        setState(() {
                          _items.remove(item);
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 16)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
