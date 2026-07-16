import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/invoice_provider.dart';
import '../services/settings_provider.dart';
import '../models/invoice_model.dart';
import 'invoices_list_screen.dart';
import 'create_invoice_screen.dart';
import 'settings_screen.dart';
import 'reports_screen.dart';
import 'invoice_detail_screen.dart';

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
                  decoration: BoxDecoration(
                    color: const Color(0xFFB4B0FF).withOpacity(isDark ? 0.3 : 1.0),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
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
                    Text(
                      'Good morning',
                      style: TextStyle(
                        fontSize: 18,
                        color: colorScheme.onSurfaceVariant,
                        fontFamily: 'Serif',
                      ),
                    ),
                    Text(
                      settings.companyName,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
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
                          colorScheme.primary,
                        ),
                        _buildSummaryCard(
                          'Total revenue',
                          settings.currencySymbol + provider.totalRevenue.toStringAsFixed(0),
                          colorScheme.secondary,
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
                        Text(
                          'Recent invoices',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                            fontFamily: 'Serif',
                          ),
                        ),
                        if (provider.invoices.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const InvoicesListScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'View all',
                              style: TextStyle(
                                color: colorScheme.secondary,
                                fontSize: 16,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Invoice List or Empty State
                    if (provider.invoices.isEmpty)
                      _buildEmptyState(colorScheme, isDark)
                    else
                      ...provider.recentInvoices.map((inv) => _buildInvoiceTile(inv, colorScheme, isDark)),
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
          color: colorScheme.secondary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: colorScheme.secondary.withAlpha(77),
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
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 50 : 10),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          border: isDark ? Border.all(color: Colors.white12) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(Icons.home_outlined, 'Home', 0, colorScheme),
            _buildNavItem(Icons.description_outlined, 'Invoices', 1, colorScheme),
            const SizedBox(width: 45), // Space for centered FAB
            _buildNavItem(Icons.bar_chart_outlined, 'Reports', 2, colorScheme),
            _buildNavItem(Icons.settings_outlined, 'Settings', 3, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                shape: BoxShape.circle,
                border: isDark ? Border.all(color: Colors.white12) : null,
              ),
              child: Icon(
                Icons.description_outlined,
                size: 60,
                color: colorScheme.onSurfaceVariant.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No invoices yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to create your first one',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, ColorScheme colorScheme) {
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
              color: isSelected ? colorScheme.secondary.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              icon,
              color: isSelected ? colorScheme.secondary : colorScheme.onSurfaceVariant,
              size: 26,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? colorScheme.secondary : colorScheme.onSurfaceVariant,
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

  Widget _buildInvoiceTile(Invoice inv, ColorScheme colorScheme, bool isDark) {
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

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InvoiceDetailScreen(invoiceId: inv.id),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: isDark ? Border.all(color: Colors.white12) : null,
          boxShadow: isDark ? null : [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(Icons.receipt_long_outlined, color: statusColor),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    inv.customerName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    inv.invoiceNumber,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  Provider.of<SettingsProvider>(context, listen: false).currencySymbol + inv.total.toStringAsFixed(0),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
