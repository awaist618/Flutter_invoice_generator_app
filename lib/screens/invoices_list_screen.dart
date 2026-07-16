import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/invoice_provider.dart';
import '../models/invoice_model.dart';
import 'package:intl/intl.dart';

class InvoicesListScreen extends StatefulWidget {
  const InvoicesListScreen({super.key});

  @override
  State<InvoicesListScreen> createState() => _InvoicesListScreenState();
}

class _InvoicesListScreenState extends State<InvoicesListScreen> {
  String _selectedFilter = 'All';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InvoiceProvider>(context);
    
    // Filter logic
    final filteredInvoices = provider.invoices.where((inv) {
      bool matchesSearch = inv.invoiceNumber.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                          inv.customerName.toLowerCase().contains(_searchQuery.toLowerCase());
      
      if (_selectedFilter == 'All') return matchesSearch;
      if (_selectedFilter == 'Paid') return matchesSearch && inv.status == InvoiceStatus.paid;
      if (_selectedFilter == 'Unpaid') return matchesSearch && inv.status == InvoiceStatus.unpaid;
      if (_selectedFilter == 'Overdue') return matchesSearch && inv.status == InvoiceStatus.overdue;
      return matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F2FF),
      body: Stack(
        children: [
          // Background shapes
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: const BoxDecoration(
                color: Color(0xFFFF9F69),
                shape: BoxShape.circle,
              ),
            ),
          ),
          
          SafeArea(
            child: Padding(
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
                        'Invoices',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2A2859),
                          fontFamily: 'Serif',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Search Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: TextField(
                      onChanged: (value) => setState(() => _searchQuery = value),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Search by number or customer',
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['All', 'Paid', 'Unpaid', 'Overdue'].map((filter) {
                        bool isSelected = _selectedFilter == filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: ChoiceChip(
                            label: Text(filter),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) setState(() => _selectedFilter = filter);
                            },
                            selectedColor: const Color(0xFF3D3B8E),
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : const Color(0xFF2A2859),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            side: BorderSide.none,
                            showCheckmark: false,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Invoices List
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredInvoices.length,
                      itemBuilder: (context, index) {
                        final inv = filteredInvoices[index];
                        return _buildInvoiceTile(inv);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        height: 65,
        width: 65,
        decoration: BoxDecoration(
          color: const Color(0xFFE25E31),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE25E31).withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            // Action to create new invoice
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: Colors.white, size: 35),
        ),
      ),
    );
  }

  Widget _buildInvoiceTile(Invoice inv) {
    Color statusColor;
    String statusLabel;
    
    switch (inv.status) {
      case InvoiceStatus.paid:
        statusColor = const Color(0xFF66D1A4);
        statusLabel = 'Paid';
        break;
      case InvoiceStatus.overdue:
        statusColor = const Color(0xFFE05275);
        statusLabel = 'Overdue';
        break;
      case InvoiceStatus.unpaid:
        statusColor = const Color(0xFFFF9F69);
        statusLabel = 'Unpaid';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Left color stripe
            Container(
              width: 6,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          inv.invoiceNumber,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color(0xFF2A2859),
                          ),
                        ),
                        Text(
                          '${inv.customerName} · ${DateFormat('MMM dd').format(inv.date)}',
                          style: const TextStyle(
                            color: Color(0xFF6C699E),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          r'$' + NumberFormat("#,##0", "en_US").format(inv.amount),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color(0xFF2A2859),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            statusLabel,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
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
}
