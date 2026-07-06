import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart' hide TextDirection;

class PdfDebtReportService {
  static Future<pw.Font?> _loadFont() async {
    try {
      final data = await rootBundle.load('assets/fonts/Cairo-Regular.ttf');
      return pw.Font.ttf(data);
    } catch (_) {
      return null;
    }
  }

  static Future<void> generateDebtReport({
    required Map storeInfo,
    required List customersList,
    required Map globalSummary,
  }) async {
    try {
      final font  = await _loadFont();
      final pdf   = pw.Document();
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      pdf.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(
          base: font ?? pw.Font.helvetica(),
          bold: font ?? pw.Font.helveticaBold(),
        ),
        header: (ctx) => pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 10),
          decoration: const pw.BoxDecoration(
              border: pw.Border(bottom: pw.BorderSide(width: 1))),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.Text("ديوني",
                    style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, font: font)),
                pw.Text("تقرير ديون المتجر: ${storeInfo['name'] ?? ''}",
                    style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700, font: font)),
              ]),
              pw.Text(today,
                  style: pw.TextStyle(fontSize: 11, color: PdfColors.grey, font: font)),
            ],
          ),
        ),
        footer: (ctx) => pw.Container(
          alignment: pw.Alignment.center,
          child: pw.Text(
              "صفحة ${ctx.pageNumber} من ${ctx.pagesCount}",
              style: pw.TextStyle(fontSize: 10, color: PdfColors.grey, font: font)),
        ),
        build: (ctx) => [
          pw.SizedBox(height: 15),
          _summaryRow(font, globalSummary),
          pw.SizedBox(height: 20),
          _customersTable(font, customersList),
        ],
      ));

      await Printing.layoutPdf(onLayout: (_) async => pdf.save());
    } catch (e) {
      Get.snackbar("خطأ", "فشل إنشاء التقرير: $e");
    }
  }

  static pw.Widget _summaryRow(pw.Font? font, Map summary) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _cell("عدد العملاء", "${summary['total_customers'] ?? 0}", font),
          _cell("إجمالي الديون", "${summary['total_debt'] ?? 0}", font),
        ],
      ),
    );
  }

  static pw.Widget _cell(String label, String value, pw.Font? font) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(label,
            style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700, font: font)),
        pw.SizedBox(height: 4),
        pw.Text(value,
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, font: font)),
      ],
    );
  }

  static pw.Widget _customersTable(pw.Font? font, List customers) {
    return pw.TableHelper.fromTextArray(
      headers: ["الاسم", "الهاتف", "الدين الحالي", "سقف الدين"],
      data: customers.map((c) => [
        c['name']?.toString() ?? "",
        c['phone']?.toString() ?? "",
        "${c['total_debt'] ?? 0}",
        "${c['debt_limit'] ?? c['account_limit'] ?? 0}",
      ]).toList(),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, font: font),
      cellStyle: pw.TextStyle(fontSize: 10, font: font),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blue200),
      oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
      border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey400),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(2),
        3: const pw.FlexColumnWidth(2),
      },
    );
  }
}
