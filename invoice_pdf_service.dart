import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/daftar_record.dart';

class InvoicePdfService {
  static Future<void> printInvoice(DaftarRecord record) async {
    final doc = pw.Document();
    final date = DateFormat('yyyy/MM/dd').format(DateTime.parse(record.createdAt));
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Directionality(
          textDirection: pw.TextDirection.rtl,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.Text('DAFTAR | دفتر',
                  style: pw.TextStyle(fontSize: 25, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Text('فاتورة / سجل بيع'),
              pw.Divider(),
              pw.Text('البيان: ${record.title}'),
              pw.Text('التاريخ: $date'),
              if (record.details.isNotEmpty) pw.Text('التفاصيل: ${record.details}'),
              pw.SizedBox(height: 24),
              pw.Container(
                padding: const pw.EdgeInsets.all(14),
                color: PdfColors.blue50,
                child: pw.Text(
                  'المبلغ الإجمالي: ${record.amount.toStringAsFixed(2)} دج',
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.Spacer(),
              pw.Center(child: pw.Text('شكراً لثقتكم بنا')),
            ],
          ),
        ),
      ),
    );
    await Printing.layoutPdf(onLayout: (_) async => doc.save());
  }
}
