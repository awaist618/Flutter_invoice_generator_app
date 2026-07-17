import 'package:flutter/material.dart';
import '../models/invoice_model.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/settings_provider.dart';
import '../services/invoice_provider.dart';
import '../services/pdf_service.dart';

class InvoiceDetailScreen extends StatelessWidget {
  final String invoiceId;

  const InvoiceDetailScreen({super.key, required this.invoiceId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final settings = Provider.of<SettingsProvider>(context);
    final invoiceProvider = Provider.of<InvoiceProvider>(context);
    
    // Find the invoice in the provider to get the latest status
    final invoice = invoiceProvider.invoices.firstWhere((inv) => inv.id == invoiceId);

    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? colorScheme.surface : const Color(0xFFF3F2FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          invoice.invoiceNumber,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 24,
            fontFamily: 'Serif',
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background Shape
          Positioned(
            top: -20,
            left: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFB4B0FF).withOpacity(isDark ? 0.2 : 0.6),
                shape: BoxShape.circle,
              ),
            ),
          ),
          
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: isDark ? colorScheme.surfaceVariant : Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Company Info and Status
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    settings.companyName,
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSurface,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    settings.companyAddress,
                                    style: TextStyle(
                                      color: colorScheme.onSurfaceVariant,
                                      fontSize: 14,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${settings.companyEmail}  ·  ${settings.companyPhone}',
                                    style: TextStyle(
                                      color: colorScheme.onSurfaceVariant,
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () {
                                _showStatusDialog(context, invoice);
                              },
                              child: _buildStatusBadge(invoice.status),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),

                        // Billed to and Due Date
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Billed to',
                                    style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    invoice.customerName,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSurface,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    invoice.customerAddress,
                                    style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${invoice.customerEmail}  ·  ${invoice.customerPhone}',
                                    style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Due date',
                                    style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    DateFormat('MMM dd, yyyy').format(invoice.dueDate),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSurface,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),

                        // Divider
                        _buildDottedDivider(colorScheme.onSurfaceVariant.withOpacity(0.3)),
                        const SizedBox(height: 25),

                        // Items
                        ...invoice.items.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  item.name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: colorScheme.onSurface,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '${settings.currencySymbol}${NumberFormat("#,##0.00").format(item.total)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        )).toList(),
                        
                        const SizedBox(height: 10),
                        const Divider(),
                        const SizedBox(height: 15),

                        // Total
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                '${settings.currencySymbol}${NumberFormat("#,##0.00").format(invoice.total)}',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        
                        // Show notes if available
                        if (invoice.notes.isNotEmpty) ...[
                          const SizedBox(height: 30),
                          _buildDottedDivider(colorScheme.onSurfaceVariant.withOpacity(0.3)),
                          const SizedBox(height: 20),
                          Text(
                            'Notes',
                            style: TextStyle(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            invoice.notes,
                            style: TextStyle(color: colorScheme.onSurfaceVariant),
                          ),
                        ]
                      ],
                    ),
                  ),
                ),
              ),

              // Action Buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        'Download',
                        const Color(0xFF3D3B8E),
                        Icons.download_rounded,
                        () => PdfService.printInvoice(invoice, settings),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildActionButton(
                        'Share',
                        const Color(0xFFE25E31),
                        Icons.share_rounded,
                        () => PdfService.shareInvoice(invoice, settings),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildActionButton(
                        'Print',
                        const Color(0xFF126E51),
                        Icons.print_rounded,
                        () => PdfService.printInvoice(invoice, settings),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(InvoiceStatus status) {
    Color color;
    String label;
    switch (status) {
      case InvoiceStatus.paid:
        color = const Color(0xFF66D1A4);
        label = 'Paid';
        break;
      case InvoiceStatus.unpaid:
        color = const Color(0xFFFF9F69);
        label = 'Unpaid';
        break;
      case InvoiceStatus.overdue:
        color = const Color(0xFFE05275);
        label = 'Overdue';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildDottedDivider(Color color) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 5.0;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          direction: Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildActionButton(String label, Color color, IconData icon, VoidCallback onTap) {
    return SizedBox(
      height: 60,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 0,
          padding: EdgeInsets.zero,
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _showStatusDialog(BuildContext context, Invoice invoice) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Status'),
        content: const Text('Mark this invoice as:'),
        actions: [
          TextButton(
            onPressed: () {
              Provider.of<InvoiceProvider>(context, listen: false)
                  .updateInvoiceStatus(invoice.id, InvoiceStatus.paid);
              Navigator.pop(context);
            },
            child: const Text('Paid', style: TextStyle(color: Color(0xFF66D1A4))),
          ),
          TextButton(
            onPressed: () {
              Provider.of<InvoiceProvider>(context, listen: false)
                  .updateInvoiceStatus(invoice.id, InvoiceStatus.unpaid);
              Navigator.pop(context);
            },
            child: const Text('Unpaid', style: TextStyle(color: Color(0xFFFF9F69))),
          ),
          TextButton(
            onPressed: () {
              Provider.of<InvoiceProvider>(context, listen: false)
                  .updateInvoiceStatus(invoice.id, InvoiceStatus.overdue);
              Navigator.pop(context);
            },
            child: const Text('Overdue', style: TextStyle(color: Color(0xFFE05275))),
          ),
        ],
      ),
    );
  }
}
