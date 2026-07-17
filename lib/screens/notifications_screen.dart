import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/invoice_provider.dart';
import '../models/invoice_model.dart';
import 'package:intl/intl.dart';
import 'invoice_detail_screen.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final invoiceProvider = Provider.of<InvoiceProvider>(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // We'll show "Actionable" items: Overdue invoices and Unpaid invoices due within 3 days
    final now = DateTime.now();
    final urgentInvoices = invoiceProvider.invoices.where((inv) {
      if (inv.status == InvoiceStatus.paid) return false;
      if (inv.status == InvoiceStatus.overdue) return true;
      final diff = inv.dueDate.difference(now).inDays;
      return diff <= 3; // Due within 3 days
    }).toList();

    // Sort: Overdue first, then by due date
    urgentInvoices.sort((a, b) {
      if (a.status == InvoiceStatus.overdue && b.status != InvoiceStatus.overdue) return -1;
      if (a.status != InvoiceStatus.overdue && b.status == InvoiceStatus.overdue) return 1;
      return a.dueDate.compareTo(b.dueDate);
    });

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontFamily: 'Serif',
          ),
        ),
        centerTitle: true,
      ),
      body: urgentInvoices.isEmpty
          ? _buildEmptyState(colorScheme)
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: urgentInvoices.length,
              itemBuilder: (context, index) {
                final inv = urgentInvoices[index];
                return _buildNotificationTile(context, inv, colorScheme, isDark);
              },
            ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_outlined,
            size: 80,
            color: colorScheme.onSurfaceVariant.withOpacity(0.3),
          ),
          const SizedBox(height: 20),
          Text(
            'All caught up!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'No urgent payment reminders at the moment.',
            style: TextStyle(color: colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTile(BuildContext context, Invoice inv, ColorScheme colorScheme, bool isDark) {
    final bool isOverdue = inv.status == InvoiceStatus.overdue;
    final Color iconColor = isOverdue ? const Color(0xFFE05275) : const Color(0xFFFF9F69);
    final String timeText = isOverdue 
        ? 'Overdue since ${DateFormat('MMM dd').format(inv.dueDate)}'
        : 'Due in ${inv.dueDate.difference(DateTime.now()).inDays + 1} days (${DateFormat('MMM dd').format(inv.dueDate)})';

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
              color: Colors.black.withOpacity(0.03),
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
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isOverdue ? Icons.warning_amber_rounded : Icons.timer_outlined,
                color: iconColor,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isOverdue ? 'Overdue Payment' : 'Upcoming Payment',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Invoice ${inv.invoiceNumber} for ${inv.customerName}',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeText,
                    style: TextStyle(
                      color: iconColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }
}
