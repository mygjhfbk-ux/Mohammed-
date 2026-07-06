import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart' hide TextDirection;

class DebtPdfGenerator {
  static Future<pw.Font?> _loadArabicFont() async {
    try {
      final fontData = await rootBundle.load('assets/fonts/Cairo-Regular.ttf');
      return pw.Font.ttf(fontData);
    } catch (_) {
      return null;
    }
  }

  static Future<void> generateCustomerStatement(
    Map customerInfo,
    List transactions,
  ) async {
    try {
      final font     = await _loadArabicFont();
      final boldFont = font;

      final pdf = pw.Document();
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      pdf.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(
          base: font ?? pw.Font.helvetica(),
          bold: boldFont ?? pw.Font.helveticaBold(),
        ),
        header: (ctx) => pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 10),
          decoration: const pw.BoxDecoration(
              border: pw.Border(bottom: pw.BorderSide(width: 1))),
          child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text("ديوني - كشف حساب", style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                pw.Text(today, style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey)),
              ]),
        ),
        build: (ctx) => [
          pw.SizedBox(height: 15),
          _infoBlock(font, customerInfo),
          pw.SizedBox(height: 20),
          _transactionsTable(font, transactions),
          pw.SizedBox(height: 20),
          _summaryBlock(font, transactions),
        ],
      ));

      await Printing.layoutPdf(onLayout: (_) async => pdf.save());
    } catch (e) {
      Get.snackbar("خطأ", "فشل إنشاء PDF: $e");
    }
  }

  static Future<void> generateMerchantReport(
    List reports,
    String merchantName,
  ) async {
    try {
      final font = await _loadArabicFont();
      final pdf  = pw.Document();
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
          child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text("ديوني", style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
            pw.Text("تقرير التاجر: $merchantName   |   التاريخ: $today",
                style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey)),
          ]),
        ),
        build: (ctx) => [
          pw.SizedBox(height: 15),
          _merchantReportTable(font, reports),
        ],
      ));

      await Printing.layoutPdf(onLayout: (_) async => pdf.save());
    } catch (e) {
      Get.snackbar("خطأ", "فشل إنشاء PDF: $e");
    }
  }

  static pw.Widget _infoBlock(pw.Font? font, Map info) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _labelValue("اسم العميل", info['customer_name']?.toString() ?? "", font),
          _labelValue("إجمالي الدين", "${info['total_debt'] ?? 0.0}", font),
          _labelValue("سقف الحساب",  "${info['account_limit'] ?? 0.0}", font),
        ],
      ),
    );
  }

  static pw.Widget _labelValue(String label, String value, pw.Font? font) {
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

  static pw.Widget _transactionsTable(pw.Font? font, List transactions) {
    final headers = ["التاريخ", "البيان", "نوع العملية", "المبلغ"];
    final rows = transactions.map((tx) {
      final isDebt = tx['type'] == 'debt' || tx['type'] == 'purchase';
      return [
        tx['date']?.toString().substring(0, 10) ?? "",
        tx['note']?.toString() ?? "",
        isDebt ? "دين" : "سداد",
        "${tx['amount'] ?? 0}",
      ];
    }).toList();

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: rows,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, font: font),
      cellStyle: pw.TextStyle(fontSize: 10, font: font),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blue100),
      oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
      border: const pw.TableBorder(
        left:   pw.BorderSide(width: 0.5),
        right:  pw.BorderSide(width: 0.5),
        top:    pw.BorderSide(width: 0.5),
        bottom: pw.BorderSide(width: 0.5),
        horizontalInside: pw.BorderSide(width: 0.3),
        verticalInside:   pw.BorderSide(width: 0.3),
      ),
    );
  }

  static pw.Widget _merchantReportTable(pw.Font? font, List reports) {
    final headers = ["التاريخ", "العميل", "النوع", "المبلغ"];
    final rows = reports.map((r) => [
      r['date']?.toString().substring(0, 10) ?? "",
      r['requests']?['customers']?['customer_name'] ?? "",
      r['type'] == 'debt' ? "دين" : "سداد",
      "${r['amount'] ?? 0}",
    ]).toList();

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: rows,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, font: font),
      cellStyle: pw.TextStyle(fontSize: 10, font: font),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blue100),
      oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
    );
  }

  static pw.Widget _summaryBlock(pw.Font? font, List transactions) {
    double totalDebt    = 0;
    double totalPayment = 0;
    for (var tx in transactions) {
      final amt = (tx['amount'] as num?)?.toDouble() ?? 0;
      if (tx['type'] == 'debt' || tx['type'] == 'purchase') {
        totalDebt += amt;
      } else {
        totalPayment += amt;
      }
    }
    final balance = totalDebt - totalPayment;

    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.blue200, width: 0.8),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _labelValue("إجمالي الديون",  totalDebt.toStringAsFixed(2), font),
          _labelValue("إجمالي السداد", totalPayment.toStringAsFixed(2), font),
          _labelValue("الرصيد الحالي",  balance.toStringAsFixed(2), font),
        ],
      ),
    );
  }
}
