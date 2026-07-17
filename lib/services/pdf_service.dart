import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/invoice_model.dart';
import 'package:intl/intl.dart';
import '../services/settings_provider.dart';

class PdfService {
  static Future<Uint8List> generateInvoicePdf({
    required Invoice invoice,
    required SettingsProvider settings,
  }) async {
    final pdf = pw.Document();

    final font = await PdfGoogleFonts.openSansRegular();
    final fontBold = await PdfGoogleFonts.openSansBold();

    pw.MemoryImage? logoImage;
    if (settings.logoPath != null && File(settings.logoPath!).existsSync()) {
      logoImage = pw.MemoryImage(File(settings.logoPath!).readAsBytesSync());
    }

    if (settings.selectedTemplate == 'Minimal') {
      return _generateMinimalTemplate(pdf, invoice, settings, font, fontBold, logoImage);
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Row(
                    children: [
                      if (logoImage != null)
                        pw.Container(
                          width: 60,
                          height: 60,
                          margin: const pw.EdgeInsets.only(right: 15),
                          decoration: pw.BoxDecoration(
                            borderRadius: pw.BorderRadius.circular(15),
                            image: pw.DecorationImage(image: logoImage, fit: pw.BoxFit.cover),
                          ),
                        ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(settings.companyName, style: pw.TextStyle(font: fontBold, fontSize: 18, color: PdfColor.fromInt(0xFF2A2859))),
                          pw.Text(settings.companyAddress, style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.grey700)),
                          pw.Text('${settings.companyEmail}  ·  ${settings.companyPhone}', style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.grey700)),
                        ],
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('INVOICE', style: pw.TextStyle(font: fontBold, fontSize: 26, color: PdfColor.fromInt(0xFF2A2859))),
                      pw.Text(invoice.invoiceNumber, style: pw.TextStyle(font: fontBold, fontSize: 14, color: PdfColor.fromInt(0xFFE25E31))),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 25),
              pw.Divider(thickness: 3, color: PdfColor.fromInt(0xFFE25E31)),
              pw.SizedBox(height: 30),

              // Billed To & Details
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('BILLED TO', style: pw.TextStyle(font: fontBold, fontSize: 10, color: PdfColor.fromInt(0xFFB4B0FF))),
                      pw.SizedBox(height: 5),
                      pw.Text(invoice.customerName, style: pw.TextStyle(font: fontBold, fontSize: 14)),
                      pw.Text(invoice.customerAddress, style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.grey700)),
                      pw.Text('${invoice.customerEmail}  ·  ${invoice.customerPhone}', style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('DETAILS', style: pw.TextStyle(font: fontBold, fontSize: 10, color: PdfColor.fromInt(0xFFB4B0FF))),
                      pw.SizedBox(height: 5),
                      pw.Row(children: [
                        pw.Text('Invoice date: ', style: pw.TextStyle(font: font, fontSize: 11, color: PdfColors.grey700)),
                        pw.Text(DateFormat('MMM dd, yyyy').format(invoice.date), style: pw.TextStyle(font: font, fontSize: 11)),
                      ]),
                      pw.Row(children: [
                        pw.Text('Due date: ', style: pw.TextStyle(font: font, fontSize: 11, color: PdfColors.grey700)),
                        pw.Text(DateFormat('MMM dd, yyyy').format(invoice.dueDate), style: pw.TextStyle(font: font, fontSize: 11)),
                      ]),
                      pw.SizedBox(height: 8),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: pw.BoxDecoration(
                          color: PdfColor.fromInt(0xFFEFFFF4),
                          borderRadius: pw.BorderRadius.circular(10),
                        ),
                        child: pw.Text(invoice.status.name.toUpperCase(), style: pw.TextStyle(font: fontBold, fontSize: 10, color: PdfColor.fromInt(0xFF126E51))),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 40),

              // Items Table
              pw.Table(
                columnWidths: {
                  0: const pw.FlexColumnWidth(4),
                  1: const pw.FixedColumnWidth(50),
                  2: const pw.FixedColumnWidth(90),
                  3: const pw.FixedColumnWidth(60),
                  4: const pw.FixedColumnWidth(90),
                },
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromInt(0xFF3D3B8E),
                      borderRadius: const pw.BorderRadius.only(topLeft: pw.Radius.circular(10), topRight: pw.Radius.circular(10)),
                    ),
                    children: [
                      _headerCell('DESCRIPTION', fontBold),
                      _headerCell('QTY', fontBold, align: pw.TextAlign.center),
                      _headerCell('PRICE', fontBold, align: pw.TextAlign.right),
                      _headerCell('DISC.', fontBold, align: pw.TextAlign.center),
                      _headerCell('AMOUNT', fontBold, align: pw.TextAlign.right),
                    ],
                  ),
                  ...invoice.items.map((item) => pw.TableRow(
                    decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200, width: 0.5))),
                    children: [
                      _cell(item.name, font),
                      _cell(item.quantity.toString(), font, align: pw.TextAlign.center),
                      _cell('${settings.currencySymbol}${NumberFormat("#,##0.00").format(item.unitPrice)}', font, align: pw.TextAlign.right),
                      _cell(item.discountPercent > 0 ? '${item.discountPercent.toStringAsFixed(0)}%' : '—', font, align: pw.TextAlign.center),
                      _cell('${settings.currencySymbol}${NumberFormat("#,##0.00").format(item.total)}', fontBold, align: pw.TextAlign.right),
                    ],
                  )),
                ],
              ),
              pw.SizedBox(height: 30),

              // Summary & QR
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  // Payment QR
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('PAYMENT QR', style: pw.TextStyle(font: fontBold, fontSize: 10, color: PdfColors.grey700)),
                      pw.SizedBox(height: 5),
                      pw.Container(
                        width: 100,
                        height: 100,
                        child: pw.BarcodeWidget(
                          barcode: pw.Barcode.qrCode(),
                          data: settings.paymentDetails,
                          drawText: false,
                        ),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text('Scan to pay via UPI/Bank', style: pw.TextStyle(font: font, fontSize: 8, color: PdfColors.grey600)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      _summaryRow('Subtotal', '${settings.currencySymbol}${NumberFormat("#,##0.00").format(invoice.subtotal)}', font),
                      pw.SizedBox(height: 5),
                      _summaryRow('Tax (${invoice.taxRate.toStringAsFixed(0)}%)', '${settings.currencySymbol}${NumberFormat("#,##0.00").format(invoice.taxAmount)}', font),
                      pw.SizedBox(height: 15),
                      pw.Container(
                        width: 250,
                        padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: pw.BoxDecoration(
                          color: PdfColor.fromInt(0xFF3D3B8E),
                          borderRadius: pw.BorderRadius.circular(15),
                        ),
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Total', style: pw.TextStyle(font: fontBold, fontSize: 18, color: PdfColors.white)),
                            pw.Text('${settings.currencySymbol}${NumberFormat("#,##0.00").format(invoice.total)}', style: pw.TextStyle(font: fontBold, fontSize: 18, color: PdfColors.white)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              if (invoice.notes.isNotEmpty) ...[
                pw.SizedBox(height: 30),
                pw.Text('NOTES', style: pw.TextStyle(font: fontBold, fontSize: 10, color: PdfColors.grey700)),
                pw.SizedBox(height: 5),
                pw.Text(invoice.notes, style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.grey800)),
              ],
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static Future<Uint8List> _generateMinimalTemplate(
    pw.Document pdf,
    Invoice invoice,
    SettingsProvider settings,
    pw.Font font,
    pw.Font fontBold,
    pw.MemoryImage? logoImage,
  ) async {
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('INVOICE', style: pw.TextStyle(font: fontBold, fontSize: 24)),
                  if (logoImage != null) pw.Image(logoImage, width: 50, height: 50),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('From:', style: pw.TextStyle(font: fontBold)),
                      pw.Text(settings.companyName),
                      pw.Text(settings.companyAddress),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Invoice #: ${invoice.invoiceNumber}'),
                      pw.Text('Date: ${DateFormat('yyyy-MM-dd').format(invoice.date)}'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Text('Bill To:', style: pw.TextStyle(font: fontBold)),
              pw.Text(invoice.customerName),
              pw.Text(invoice.customerAddress),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                context: context,
                headerStyle: pw.TextStyle(font: fontBold),
                headers: ['Description', 'Qty', 'Unit Price', 'Total'],
                data: invoice.items.map((item) => [
                  item.name,
                  item.quantity.toString(),
                  '${settings.currencySymbol}${item.unitPrice}',
                  '${settings.currencySymbol}${item.total.toStringAsFixed(2)}',
                ]).toList(),
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Subtotal: ${settings.currencySymbol}${invoice.subtotal.toStringAsFixed(2)}'),
                      pw.Text('Tax: ${settings.currencySymbol}${invoice.taxAmount.toStringAsFixed(2)}'),
                      pw.Text('Total: ${settings.currencySymbol}${invoice.total.toStringAsFixed(2)}', style: pw.TextStyle(font: fontBold)),
                    ],
                  ),
                ],
              ),
              pw.Spacer(),
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.BarcodeWidget(
                      barcode: pw.Barcode.qrCode(),
                      data: settings.paymentDetails,
                      width: 80,
                      height: 80,
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text('Payment QR', style: pw.TextStyle(fontSize: 8)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
    return pdf.save();
  }

  static pw.Widget _headerCell(String text, pw.Font font, {pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: pw.Text(text, textAlign: align, style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.white)),
    );
  }

  static pw.Widget _cell(String text, pw.Font font, {pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: pw.Text(text, textAlign: align, style: pw.TextStyle(font: font, fontSize: 10)),
    );
  }

  static pw.Widget _summaryRow(String label, String value, pw.Font font) {
    return pw.Row(
      children: [
        pw.Text(label, style: pw.TextStyle(font: font, color: PdfColors.grey700, fontSize: 11)),
        pw.SizedBox(width: 40),
        pw.Text(value, style: pw.TextStyle(font: font, fontSize: 11)),
      ],
    );
  }

  static Future<void> printInvoice(Invoice invoice, SettingsProvider settings) async {
    final bytes = await generateInvoicePdf(invoice: invoice, settings: settings);
    await Printing.layoutPdf(onLayout: (format) async => bytes, name: '${invoice.invoiceNumber}.pdf');
  }

  static Future<void> shareInvoice(Invoice invoice, SettingsProvider settings) async {
    final bytes = await generateInvoicePdf(invoice: invoice, settings: settings);
    await Printing.sharePdf(bytes: bytes, filename: '${invoice.invoiceNumber}.pdf');
  }
}
