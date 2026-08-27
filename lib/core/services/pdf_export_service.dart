import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../../features/customers/data/models/customer.dart';
import '../../features/transactions/data/models/transaction.dart';

class PdfExportService {
  static Future<Uint8List> generateCustomerLedger({
    required String shopName,
    required Customer customer,
    required List<TransactionRecord> transactions,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final pdf = pw.Document();

    final dateStr = '${DateFormat('dd MMM yyyy').format(startDate)} to ${DateFormat('dd MMM yyyy').format(endDate)}';

    // Sort ascending for ledger view
    final sortedTx = List<TransactionRecord>.from(transactions)
      ..sort((a, b) => a.transactionDate.compareTo(b.transactionDate));

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildHeader(shopName, customer, dateStr),
            pw.SizedBox(height: 20),
            _buildSummary(customer),
            pw.SizedBox(height: 20),
            _buildTable(sortedTx),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader(String shopName, Customer customer, String dateStr) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(shopName, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        pw.Text('Customer Ledger', style: pw.TextStyle(fontSize: 18, color: PdfColors.grey700)),
        pw.SizedBox(height: 20),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('To:'),
                pw.Text(customer.name, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                if (customer.mobileNumber != null && customer.mobileNumber!.isNotEmpty)
                  pw.Text('Phone: ${customer.mobileNumber}'),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('Statement Period:'),
                pw.Text(dateStr, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text('Generated: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}'),
              ],
            )
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildSummary(Customer customer) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey200,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Current Outstanding Balance:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.Text(
            'Rs. ${customer.currentBalance.toStringAsFixed(2)}',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: customer.currentBalance > 0 ? PdfColors.red700 : PdfColors.green700,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildTable(List<TransactionRecord> transactions) {
    final headers = ['Date', 'Description', 'Credit (+)', 'Payment (-)'];

    final data = transactions.map((t) {
      final isCredit = t.type == 'credit';
      return [
        DateFormat('dd MMM yyyy').format(t.transactionDate),
        t.description.isNotEmpty ? t.description : (isCredit ? 'Credit' : 'Payment'),
        isCredit ? t.amount.toStringAsFixed(2) : '',
        !isCredit ? t.amount.toStringAsFixed(2) : '',
      ];
    }).toList();

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blue800),
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.centerRight,
      },
      oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
    );
  }

  static Future<void> printOrSharePdf(Uint8List pdfData, String filename) async {
    await Printing.sharePdf(bytes: pdfData, filename: filename);
  }
}
