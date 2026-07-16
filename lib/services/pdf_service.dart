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
                      pw.Container(
                        width: 60,
                        height: 60,
                        decoration: pw.BoxDecoration(
                          color: PdfColor.fromInt(0xFF3D3B8E),
                          borderRadius: pw.BorderRadius.circular(15),
                          image: logoImage != null ? pw.DecorationImage(image: logoImage, fit: pw.BoxFit.cover) : null,
                        ),
                      ),
                      pw.SizedBox(width: 15),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(settings.companyName, style: pw.TextStyle(font: fontBold, fontSize: 18, color: PdfColor.fromInt(0xFF2A2859))),
                          pw.Text(settings.companyAddress, style: pw.TextStyle(font: font, fontSize: 11, color: PdfColors.grey700)),
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
                      pw.Text(invoice.customerAddress, style: pw.TextStyle(font: font, fontSize: 11, color: PdfColors.grey700)),
                      pw.Text(invoice.customerEmail, style: pw.TextStyle(font: font, fontSize: 11, color: PdfColors.grey700)),
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

              // Summary
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
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
