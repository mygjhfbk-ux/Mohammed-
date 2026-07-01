import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// تقرير العملاء والدين
class PdfDebtReportService {
  // الهوية البصرية للتقرير (تطابق الصورة المرفقة)
  static const PdfColor primaryBlue = PdfColor.fromInt(0xff07477E);
  static const PdfColor cardRed = PdfColor.fromInt(0xffF44336);
  static const PdfColor cardOrange = PdfColor.fromInt(0xffFF9800);
  static const PdfColor cardBlue = PdfColor.fromInt(0xff2196F3);
  static const PdfColor cardGreen = PdfColor.fromInt(0xff4CAF50);
  static const PdfColor cardPurple = PdfColor.fromInt(0xff9C27B0);
  static GetStorage  box = GetStorage();

  static Future<void> generateDebtReport({
    required Map storeInfo,
    required List customersList,
    required Map globalSummary,
  }) async
  {
    final font = await rootBundle.load("assets/fonts/Cairo-regular.ttf");
    final ttf = pw.Font.ttf(font);
    final arabicTheme = pw.ThemeData.base().copyWith(defaultTextStyle: pw.TextStyle(font: ttf, fontSize: 10));
    final pdf = pw.Document(theme: arabicTheme);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        theme: arabicTheme,
        build: (pw.Context context) {
          return [
            _buildHeader(storeInfo),
            pw.SizedBox(height: 20),
            _buildStoreSummaryHeader(storeInfo, customersList.length),
            pw.SizedBox(height: 20),
            _buildColorSummaryGrid(globalSummary),
            pw.SizedBox(height: 20),
            _buildCustomersTable(customersList),
            pw.SizedBox(height: 20),
            _buildBottomSummary(globalSummary),
            pw.Spacer(),
            _buildFooter(),
          ];
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  // 1. الهيدر العلوي
  static pw.Widget _buildHeader(Map store) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(box.read("Name").toString(), style: pw.TextStyle(fontSize: 18,)),
            pw.Text(box.read("saved_phone").toString(), style: const pw.TextStyle(fontSize: 12)),
          ],
        ),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          decoration: pw.BoxDecoration(
            color: PdfColor.fromInt(0xffE3F2FD),
            borderRadius: pw.BorderRadius.circular(10),
            border: pw.Border.all(color: primaryBlue, width: 1),
          ),
          child: pw.Column(
            children: [
              pw.Text("تقرير العملاء والدين", style: pw.TextStyle(color: primaryBlue, fontSize: 16,)),
            ],
          ),
        ),
      ],
    );
  }

  // 2. بطاقة معلومات المتجر والحالة
  static pw.Widget _buildStoreSummaryHeader(Map store, int count) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(10),
        color: PdfColors.grey50,
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("تقرير إجمالي العملاء", style: pw.TextStyle(fontSize: 16, color: primaryBlue)),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              _statusLabel("$count عميل", cardGreen),
              pw.SizedBox(height: 10),
              pw.Text("تاريخ التقرير: 28/03/2026 04:04", style: const pw.TextStyle(fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  // 3. شبكة المربعات الملونة (Summary Grid)
  static pw.Widget _buildColorSummaryGrid(Map summary) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        _colorBox("إجمالي الدين", "${summary['total_debt']}", cardRed),
        _colorBox("متوسط الدين/عميل", "${summary['avg_debt']}", cardOrange),
        _colorBox("عدد العملاء", "${summary['customer_count']}", cardBlue),
        _colorBox("عملاء مدينون", "${summary['debtor_count']}", cardGreen),
        _colorBox("أعلى دين", "${summary['max_debt']}", cardPurple),
      ],
    );
  }

  static pw.Widget _colorBox(String label, String value, PdfColor color) {
    return pw.Container(
      width: 95,
      padding: const pw.EdgeInsets.symmetric(vertical: 10),
      decoration: pw.BoxDecoration(color: color, borderRadius: pw.BorderRadius.circular(8)),
      child: pw.Column(
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 8, color: PdfColors.white)),
          pw.SizedBox(height: 4),
          pw.Text(value, style: pw.TextStyle(fontSize: 12, color: PdfColors.white)),
        ],
      ),
    );
  }

  // 4. جدول العملاء التفصيلي
  static pw.Widget _buildCustomersTable(List customers) {
    return pw.TableHelper.fromTextArray(
      headers: [ 'اجمالي الدين', 'سقف الحساب', 'الهاتف', 'الحالة', 'العنوان', 'اسم العميل','م'],
      data: List<List<dynamic>>.generate(customers.length, (index) {
        final c = customers[index];
        return [
          c['debt'],
          c['limit'],
          c['phone'],
          c['status'],
          c['address'],
          c['name'],
          index + 1,
        ];
      }),
      headerStyle: pw.TextStyle( color: primaryBlue),
      headerDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xffE1F5FE)),
      cellAlignment: pw.Alignment.center,
      cellStyle: const pw.TextStyle(fontSize: 9),
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
    );
  }

  // 5. الملخص السفلي (الإجماليات الكبيرة)
  static pw.Widget _buildBottomSummary(Map summary) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            _summaryRow("إجمالي ديون العملاء:", "${summary['total_debt']}", cardRed),
            pw.SizedBox(height: 5),
            _summaryRow("إجمالي ديون اليوم:", "${summary['today_debt']}", cardOrange),
            pw.SizedBox(height: 5),
            _summaryRow("إجمالي سقف الحسابات:", "${summary['total_limits']}", cardBlue),
          ],
        ),
      ],
    );
  }

  static pw.Widget _summaryRow(String label, String value, PdfColor color) {
    return pw.Row(
      children: [
        pw.Text(label, style: pw.TextStyle( fontSize: 12)),
        pw.SizedBox(width: 10),
        pw.Container(
          width: 80,
          padding: const pw.EdgeInsets.symmetric(vertical: 4),
          decoration: pw.BoxDecoration(color: color, borderRadius: pw.BorderRadius.circular(5)),
          child: pw.Center(child: pw.Text(value, style: pw.TextStyle(color: PdfColors.white,))),
        ),


      ],
    );
  }

  static pw.Widget _statusLabel(String text, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: pw.BoxDecoration(color: color, borderRadius: pw.BorderRadius.circular(5)),
      child: pw.Text(text, style: const pw.TextStyle(color: PdfColors.white, fontSize: 9)),
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Column(
      children: [
        pw.Divider(color: PdfColors.grey300),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text("تم الإنشاء بواسطة تطبيق ديون", style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
            pw.Text("صفحة 1 من 1", style: const pw.TextStyle(fontSize: 10)),
          ],
        ),
      ],
    );
  }
}
