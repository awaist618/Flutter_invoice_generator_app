import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/invoice_model.dart';
import '../services/invoice_provider.dart';
import '../services/settings_provider.dart';
import '../services/notification_service.dart';
import '../services/customer_provider.dart';
import '../services/product_provider.dart';
import '../models/customer_model.dart';
import '../models/product_model.dart';

class CreateInvoiceScreen extends StatefulWidget {
  const CreateInvoiceScreen({super.key});

  @override
  State<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  final _paymentInstructionsController = TextEditingController();
  
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

  void _showSavedCustomersPicker() {
    final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
    if (customerProvider.customers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No saved customers found')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Pick a Customer', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: customerProvider.customers.length,
                itemBuilder: (context, index) {
                  final customer = customerProvider.customers[index];
                  return ListTile(
                    title: Text(customer.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(customer.email),
                    onTap: () {
                      setState(() {
                        _nameController.text = customer.name;
                        _emailController.text = customer.email;
                        _addressController.text = customer.address;
                        _phoneController.text = customer.phone;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSavedProductsPicker() {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Pick a Product', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: productProvider.products.length,
                itemBuilder: (context, index) {
                  final product = productProvider.products[index];
                  return ListTile(
                    title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Price: ${Provider.of<SettingsProvider>(context, listen: false).currencySymbol}${NumberFormat("#,##0.00").format(product.unitPrice)}'),
                    onTap: () {
                      Navigator.pop(context);
                      _showAddItemWithProduct(product);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddItemWithProduct(Product product) {
    final nameController = TextEditingController(text: product.name);
    final qtyController = TextEditingController(text: '1');
    final priceController = TextEditingController(text: product.unitPrice.toString());
    final itemFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Add Item', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Form(
          key: itemFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogField(nameController, 'Item name', TextInputType.text, (val) => val!.isEmpty ? 'Enter item name' : null),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildDialogField(qtyController, 'Qty', TextInputType.number, (val) {
                      if (val!.isEmpty) return 'Required';
                      if (int.tryParse(val) == null) return 'Invalid';
                      return null;
                    }),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildDialogField(priceController, 'Price', TextInputType.number, (val) {
                      if (val!.isEmpty) return 'Required';
                      if (double.tryParse(val) == null) return 'Invalid';
                      return null;
                    }),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (itemFormKey.currentState!.validate()) {
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
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addItem() {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final nameController = TextEditingController();
    final qtyController = TextEditingController(text: '1');
    final priceController = TextEditingController();
    final itemFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Add New Item', 
              style: TextStyle(
                fontWeight: FontWeight.bold
              )
            ),
            if (productProvider.products.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.saved_search, color: Color(0xFFE25E31)),
                onPressed: () {
                  Navigator.pop(context);
                  _showSavedProductsPicker();
                },
                tooltip: 'Pick from saved products',
              ),
          ],
        ),
        content: Form(
          key: itemFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogField(nameController, 'Item name', TextInputType.text, (val) => val!.isEmpty ? 'Enter item name' : null),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildDialogField(qtyController, 'Qty', TextInputType.number, (val) {
                      if (val!.isEmpty) return 'Required';
                      if (int.tryParse(val) == null) return 'Invalid';
                      return null;
                    }),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildDialogField(priceController, 'Price', TextInputType.number, (val) {
                      if (val!.isEmpty) return 'Required';
                      if (double.tryParse(val) == null) return 'Invalid';
                      return null;
                    }),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (itemFormKey.currentState!.validate()) {
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
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogField(TextEditingController controller, String hint, TextInputType type, String? Function(String?)? validator) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
        filled: true,
        fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.05) : const Color(0xFFF3F2FF),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        errorStyle: const TextStyle(fontSize: 10),
      ),
      validator: validator,
    );
  }

  double _calculateSubtotal() => _items.fold(0, (sum, item) => sum + item.total);
  double _calculateTax(double rate) => _calculateSubtotal() * (rate / 100);
  double _calculateTotal(double rate) => _calculateSubtotal() + _calculateTax(rate);

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final subtotal = _calculateSubtotal();
    final taxAmount = _calculateTax(settings.defaultTaxRate);
    final total = _calculateTotal(settings.defaultTaxRate);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background Decoration (Top Right)
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: const Color(0xFF66D1A4).withOpacity(isDark ? 0.3 : 1.0),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF126E51).withOpacity(isDark ? 0.5 : 1.0),
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
                      icon: Icon(Icons.arrow_back, color: colorScheme.onSurface, size: 30),
                    ),
                    Center(
                      child: Text(
                        'New invoice',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                          fontFamily: 'Serif',
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Top Info Row
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            SizedBox(
                              width: (constraints.maxWidth - 20) / 3,
                              child: _buildTopInfoCard('Invoice no.', _generatedInvoiceNo.isEmpty ? '...' : _generatedInvoiceNo, colorScheme, isDark),
                            ),
                            SizedBox(
                              width: (constraints.maxWidth - 20) / 3,
                              child: _buildTopInfoCard('Date', DateFormat('MMM dd').format(_invoiceDate), colorScheme, isDark),
                            ),
                            SizedBox(
                              width: (constraints.maxWidth - 20) / 3,
                              child: GestureDetector(
                                onTap: _selectDueDate,
                                child: _buildTopInfoCard('Due date', DateFormat('MMM dd').format(_dueDate), colorScheme, isDark),
                              ),
                            ),
                          ],
                        );
                      }
                    ),
                    const SizedBox(height: 30),

                    // Customer Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Customer',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                            fontFamily: 'Serif',
                          ),
                        ),
                        GestureDetector(
                          onTap: _showSavedCustomersPicker,
                          child: Text(
                            'Pick saved',
                            style: TextStyle(color: colorScheme.secondary, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(_nameController, 'Customer name', colorScheme),
                    const SizedBox(height: 10),
                    _buildTextField(_addressController, 'Customer address', colorScheme),
                    const SizedBox(height: 10),
                    _buildTextField(_emailController, 'Email address', colorScheme),
                    const SizedBox(height: 10),
                    _buildTextField(_phoneController, 'Phone number', colorScheme),
                    
                    const SizedBox(height: 30),

                    // Items Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Items',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                            fontFamily: 'Serif',
                          ),
                        ),
                        GestureDetector(
                          onTap: _addItem,
                          child: Text(
                            'Add item',
                            style: TextStyle(color: colorScheme.secondary, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    
                    // Items List
                    if (_items.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Text(
                            'No items added yet',
                            style: TextStyle(color: colorScheme.onSurfaceVariant),
                          ),
                        ),
                      )
                    else
                      ..._items.map((item) => _buildItemTile(item, colorScheme, isDark, settings)),

                    const SizedBox(height: 30),

                    // Additional Info Section
                    Text(
                      'Additional Info',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                        fontFamily: 'Serif',
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(_notesController, 'Notes (e.g., Thank you for your business)', colorScheme, maxLines: 3, required: false),
                    const SizedBox(height: 10),
                    _buildTextField(_paymentInstructionsController, 'Payment Instructions (e.g., Bank details)', colorScheme, maxLines: 3, required: false),

                    const SizedBox(height: 30),

                    // Summary Card
                    Container(
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildSummaryRow('Subtotal', settings.currencySymbol + NumberFormat("#,##0.00").format(subtotal)),
                          const SizedBox(height: 12),
                          _buildSummaryRow('Tax (${settings.defaultTaxRate.toStringAsFixed(0)}%)', settings.currencySymbol + NumberFormat("#,##0.00").format(taxAmount)),
                          const SizedBox(height: 20),
                          Divider(color: Colors.white.withOpacity(0.2)),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Grand total',
                                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                settings.currencySymbol + NumberFormat("#,##0.00").format(total),
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
                      height: 65,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            if (_items.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please add at least one item')),
                              );
                              return;
                            }
                            
                            final newInvoice = Invoice(
                              invoiceNumber: _generatedInvoiceNo,
                              customerName: _nameController.text,
                              customerEmail: _emailController.text,
                              customerAddress: _addressController.text,
                              customerPhone: _phoneController.text,
                              date: _invoiceDate,
                              dueDate: _dueDate,
                              items: List.from(_items),
                              taxRate: settings.defaultTaxRate,
                              notes: _notesController.text,
                              paymentInstructions: _paymentInstructionsController.text,
                            );
                            Provider.of<InvoiceProvider>(context, listen: false).addInvoice(newInvoice);
                            HapticFeedback.lightImpact();
                            
                            // Schedule notification
                            NotificationService().scheduleInvoiceReminders(
                              newInvoice.id.hashCode,
                              newInvoice.invoiceNumber, 
                              newInvoice.dueDate
                            );

                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.secondary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_outline),
                            SizedBox(width: 10),
                            Text('Generate Invoice', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
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

  Widget _buildTopInfoCard(String label, String value, ColorScheme colorScheme, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
        border: isDark ? Border.all(color: Colors.white12) : null,
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12)),
          const SizedBox(height: 5),
          Text(value, style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, ColorScheme colorScheme, {int maxLines = 1, bool required = true}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        filled: true,
        fillColor: colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
      validator: required ? (val) => val!.isEmpty ? 'Required' : null : null,
    );
  }

  Widget _buildItemTile(InvoiceItem item, ColorScheme colorScheme, bool isDark, SettingsProvider settings) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: isDark ? Border.all(color: Colors.white12) : null,
        boxShadow: isDark ? null : [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.inventory_2_outlined, color: colorScheme.primary),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.quantity} x ${settings.currencySymbol}${NumberFormat("#,##0.00").format(item.unitPrice)}',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${settings.currencySymbol}${NumberFormat("#,##0.00").format(item.total)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              icon: Icon(Icons.remove_circle_outline, color: colorScheme.error.withOpacity(0.7)),
              onPressed: () {
                setState(() {
                  _items.remove(item);
                });
              },
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
