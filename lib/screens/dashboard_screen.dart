import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/invoice_provider.dart';
import '../services/settings_provider.dart';
import '../models/invoice_model.dart';
import 'invoices_list_screen.dart';
import 'create_invoice_screen.dart';
import 'settings_screen.dart';
import 'reports_screen.dart';

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
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F2FF),
      extendBody: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              // Background Decoration (Now inside SingleChildScrollView so it scrolls)
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
                      child: const Center(
                        child: Icon(
                          Icons.notifications_outlined,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    const Text(
                      'Good morning',
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF6C699E),
                        fontFamily: 'Serif',
                      ),
                    ),
                    Text(
                      settings.companyName,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2A2859),
                        fontFamily: 'Serif',
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Summary Cards Grid
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 15,
                      crossAxisSpacing: 15,
                      childAspectRatio: 3.2,
                      children: [
                        _buildSummaryCard(
                          'Total invoices',
                          '${provider.totalInvoicesCount}',
                          const Color(0xFF3D3B8E),
                        ),
                        _buildSummaryCard(
                          'Total revenue',
                          settings.currencySymbol + provider.totalRevenue.toStringAsFixed(0),
                          const Color(0xFFE25E31),
                        ),
                        _buildSummaryCard(
                          'Paid',
                          '${provider.paidCount}',
                          const Color(0xFF126E51),
                        ),
                        _buildSummaryCard(
                          'Unpaid',
                          '${provider.unpaidCount}',
                          const Color(0xFF962D4D),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // Recent Invoices Section Header
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
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const InvoicesListScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'View all',
                            style: TextStyle(
                              color: Color(0xFFE25E31),
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Invoice List
                    ...provider.recentInvoices.map((inv) => _buildInvoiceTile(inv)),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        height: 65,
        width: 65,
        decoration: BoxDecoration(
          color: const Color(0xFFE25E31),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE25E31).withAlpha(77),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateInvoiceScreen(),
              ),
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: Colors.white, size: 35),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 25),
        height: 85,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(Icons.home_outlined, 'Home', 0),
            _buildNavItem(Icons.description_outlined, 'Invoices', 1),
            const SizedBox(width: 45), // Space for centered FAB
            _buildNavItem(Icons.bar_chart_outlined, 'Reports', 2),
            _buildNavItem(Icons.settings_outlined, 'Settings', 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const InvoicesListScreen(),
            ),
          );
          return;
        }
        if (index == 3) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SettingsScreen(),
            ),
          );
          return;
        }
        if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ReportsScreen(),
            ),
          );
          return;
        }
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFF3F2FF) : Colors.transparent,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              icon,
              color: isSelected ? const Color(0xFFE25E31) : const Color(0xFF6C699E),
              size: 26,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFFE25E31) : const Color(0xFF6C699E),
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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
                inv.invoiceNumber,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF2A2859),
                ),
              ),
              Text(
                inv.customerName,
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
                Provider.of<SettingsProvider>(context, listen: false).currencySymbol + inv.total.toStringAsFixed(0),
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
                  color: statusColor.withAlpha(38),
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
    );
  }
}
