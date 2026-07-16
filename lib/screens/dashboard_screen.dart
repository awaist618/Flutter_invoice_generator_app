import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/invoice_provider.dart';
import '../models/invoice_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InvoiceProvider>(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF3F2FF),
      body: Stack(
        children: [
          // Background Shape (Top Right)
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 250,
              height: 250,
              decoration: const BoxDecoration(
                color: Color(0xFFB4B0FF),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: Color(0xFF3D3B8E),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.notifications_outlined,
                          color: Colors.white, size: 30),
                      onPressed: () {
                        // Action for notifications
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Good morning',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF6C699E),
                      fontFamily: 'Serif',
                    ),
                  ),
                  const Text(
                    'Acme Studio',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2A2859),
                      fontFamily: 'Serif',
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  // Summary Cards Grid (Using Dynamic Data)
                  Row(
                    children: [
                      _buildSummaryCard(
                        'Total invoices',
                        '${provider.totalInvoicesCount}',
                        const Color(0xFF3D3B8E),
                      ),
                      const SizedBox(width: 15),
                      _buildSummaryCard(
                        'Total revenue',
                        r'$' + provider.totalRevenue.toStringAsFixed(0),
                        const Color(0xFFE25E31),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      _buildSummaryCard(
                        'Paid',
                        '${provider.paidCount}',
                        const Color(0xFF126E51),
                      ),
                      const SizedBox(width: 15),
                      _buildSummaryCard(
                        'Unpaid',
                        '${provider.unpaidCount}',
                        const Color(0xFF962D4D),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Recent Invoices Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent invoices',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2A2859),
                          fontFamily: 'Serif',
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'View all',
                          style: TextStyle(color: Color(0xFFE25E31)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  
                  // Invoice List (Using Dynamic Data)
                  ...provider.recentInvoices.map((inv) => _buildInvoiceTile(
                    inv.invoiceNumber, 
                    inv.customerName, 
                    r'$' + inv.amount.toStringAsFixed(0), 
                    inv.status == InvoiceStatus.paid ? 'Paid' : (inv.status == InvoiceStatus.overdue ? 'Overdue' : 'Unpaid'), 
                    inv.status == InvoiceStatus.paid ? const Color(0xFF66D1A4) : (inv.status == InvoiceStatus.overdue ? const Color(0xFFE05275) : const Color(0xFFFF9F69))
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1A1A1A),
        selectedItemColor: const Color(0xFFE25E31),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description_outlined),
            label: 'Invoices',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceTile(String id, String name, String amount, String status, Color statusColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                id,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF2A2859),
                ),
              ),
              Text(
                name,
                style: const TextStyle(color: Color(0xFF6C699E)),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF2A2859),
                ),
              ),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  status,
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
    );
  }
}
