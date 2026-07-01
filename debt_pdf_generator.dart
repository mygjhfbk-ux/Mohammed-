import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';


/// تقرير اجمالي العملاء
class DebtPdfGenerator {
  static GetStorage  box = GetStorage();

  /// دالة إنشاء التقرير
  static Future<void> generateCustomersDebtPdf(List<dynamic> customers  ) async {
    try {
      final pdf = pw.Document();
      final ByteData imageByteData = await rootBundle.load('assets/images/logo.jpg');
      final Uint8List logoBytes = imageByteData.buffer.asUint8List();
      final pw.ImageProvider logoImage = pw.MemoryImage(logoBytes);

      // استخدام خط محلي أو التأكد من التحميل الكامل
      final arabicFont = await PdfGoogleFonts.almaraiRegular();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          // تأكد من تحديد اتجاه النص هنا أيضاً
          theme: pw.ThemeData.withFont(base: arabicFont),
          textDirection: pw.TextDirection.rtl, // ضروري جداً للعربية
          build: (context) => [
            _buildHeader(customers.length,logoImage),
            pw.SizedBox(height: 20),
            _buildDebtTable(customers, arabicFont), // تمرير الخط للجدول
            pw.SizedBox(height: 20),
            _buildFooter(),
          ],
        ),
      );

      // استخدام الـ Uint8List مباشرة لتفادي مشاكل الـ Method Channel
      final bytes = await pdf.save();

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => bytes,
        name: 'تقرير_الديون_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
    } catch (e) {
      print("PDF Error: $e");
      Get.snackbar("خطأ", "فشل في توليد ملف PDF: $e", backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  /// 1. ترويسة التقرير (Header)
  static pw.Widget _buildHeader(int count,pw.ImageProvider logo) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(children: [
              pw.Text(box.read("Name").toString(), style: const pw.TextStyle(fontSize: 22)),
              pw.Text(box.read("saved_phone").toString(), style: const pw.TextStyle(fontSize: 22)),
            ]),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              decoration: pw.BoxDecoration(border: pw.Border.all()),
              child: pw.Text("تقرير العملاء بإجمالي الديون", style: pw.TextStyle(fontSize: 16)),
            ),
            pw.Container(
              width: 60,
              height: 60,
              child: pw.Image(logo),
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Align(
          alignment: pw.Alignment.centerLeft,
          child: pw.Text("عدد العملاء: $count", textDirection: pw.TextDirection.rtl),
        ),
      ],
    );
  }

  /// 2. جدول البيانات (Table)
  static pw.Widget _buildDebtTable(List<dynamic> customers, pw.Font font ) {
    double totalAll = 0;
    double total = 0 ;
    double credit = 0 ;
    double debit = 0 ;
    for (var c in customers) {
      totalAll += double.tryParse(c['Balance_After'].toString()) ?? 0;
      debit += double.tryParse(c['Debit'].toString()) ?? 0;
      credit += double.tryParse(c['Credit'].toString()) ?? 0;

    }

    return pw.TableHelper.fromTextArray(
      context: null,
      cellAlignment: pw.Alignment.center,
      headerStyle: pw.TextStyle(font: font, fontWeight: pw.FontWeight.bold, fontSize: 10),
      cellStyle: pw.TextStyle(font: font, fontSize: 9),
      columnWidths: {
        6: const pw.FixedColumnWidth(30), // م
        5: const pw.FlexColumnWidth(3),   // اسم العميل
        4: const pw.FlexColumnWidth(3),   // اسم العميل
        3: const pw.FlexColumnWidth(2),   // رقم الهاتف
        2: const pw.FlexColumnWidth(2),   // العنوان
        1: const pw.FlexColumnWidth(2),   // اجمالي الدين
        0: const pw.FlexColumnWidth(2),   // اجمالي الدين
      },
      headers: ['الرصيد','دائن','مدين','البيان','التاريخ','اسم العميل','م'    ],
      data: [
        ...List.generate(customers.length, (index) {
          var c = customers[index];
          total += double.parse(c['Credit'].toString()) - double.parse(c['Debit'].toString());
          return [
            total.toString(),
            c['Debit'].toString(),
            c['Credit'] ?? "صنعاء",
            c['Description'] ?? "",
            c['Transaction-Date'],
            c['Customer-Name'] ?? c['name'],
            (index + 1).toString(),
          ];
        }),
        // سطر الإجمالي النهائي
        [ (credit - debit).toStringAsFixed(2),debit.toStringAsFixed(2), credit.toStringAsFixed(2), '', ''],
      ],
    );
  }

  /// 3. التذييل (Footer)
  static pw.Widget _buildFooter() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text("تاريخ الطباعة: ${DateTime.now().toString().split(' ')[0]}", style: const pw.TextStyle(fontSize: 10)),
        pw.SizedBox(height: 40),
        pw.Align(
          alignment: pw.Alignment.centerLeft,
          child: pw.Text("صفحة 1 من 1", style: const pw.TextStyle(fontSize: 10)),
        )
      ],
    );
  }
}

/// كشف حساب عميل
class CustomerStatementPdfGenerator {
  static GetStorage  box = GetStorage();

  static Future<void> generateDetailedPdf({
    required Map customerInfo,
    required List<dynamic> transactions,
  }) async
  {
    final pdf = pw.Document();
    final ByteData imageByteData = await rootBundle.load('assets/images/logo.jpg');
    final Uint8List logoBytes = imageByteData.buffer.asUint8List();
    final pw.ImageProvider logoImage = pw.MemoryImage(logoBytes);

    // تحميل الخطوط لدعم العربية
    final arabicFont = await PdfGoogleFonts.almaraiRegular();
    final boldFont = await PdfGoogleFonts.amiriBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: arabicFont, bold: boldFont),
        textDirection: pw.TextDirection.rtl, // اتجاه النص من اليمين لليسار
        margin: const pw.EdgeInsets.all(30),
        build: (context) => [
          _buildHeader(customerInfo,logoImage),
          pw.SizedBox(height: 20),
          _buildTransactionTable(transactions, arabicFont),
          pw.SizedBox(height: 20),
          _buildFinalSummary(customerInfo),
          _buildFooter(),
        ],
      ),
    );

    // معاينة وطباعة
    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'كشف_حساب_${customerInfo['name']}.pdf',
    );
  }

  /// 1. ترويسة التقرير وبيانات العميل
  static pw.Widget _buildHeader(Map info,pw.ImageProvider logo) {
    return pw.Column(
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(children: [
              pw.Text(box.read("Name").toString(), style: const pw.TextStyle(fontSize: 15)),
              pw.Text(box.read("saved_phone").toString(), style: const pw.TextStyle(fontSize: 15)),
            ]),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              decoration: pw.BoxDecoration(border: pw.Border.all()),
              child: pw.Text("تقارير العميل", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            ),
            pw.Container(
              width: 60,
              height: 60,
              child: pw.Image(logo),
            ),
          ],
        ),
        pw.SizedBox(height: 25),
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
          ),
          child: pw.Column(
            children: [
              pw.Text(info['name'] ?? "اسم العميل", style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.Text("الهاتف: ${info['phone'] ?? "---"}", style: const pw.TextStyle(fontSize: 12)),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  pw.Text("سقف الحساب: ${info['account_limit']}"),
                  pw.Text("إجمالي الدين: ${info['total_debt']}", style: pw.TextStyle(color: PdfColors.red, fontWeight: pw.FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text("اسحب العنصر لليمين للحذف أو لليسار للتعديل (تنبيه توضيحي)", style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey)),
        ),
      ],
    );
  }


  /// 2. جدول العمليات التفصيلي (البيان والمبلغ)
  static pw.Widget _buildTransactionTable(List<dynamic> transactions, pw.Font font) {
    return pw.TableHelper.fromTextArray(
      context: null,
      border: pw.TableBorder.symmetric(inside: pw.BorderSide(color: PdfColors.grey100)),
      headerStyle: pw.TextStyle(font: font, fontWeight: pw.FontWeight.bold, fontSize: 11),
      cellStyle: pw.TextStyle(font: font, fontSize: 10),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey50),
      columnWidths: {
        0: const pw.FlexColumnWidth(1), // المبلغ
        1: const pw.FlexColumnWidth(3), // البيان / الأصناف
        2: const pw.FlexColumnWidth(1.5), // التاريخ
      },
      headers: ['المبلغ', 'البيان', 'التاريخ'],
      data: transactions.map((tx) {
        bool isDebt = tx['type'] == 'debt' || tx['type'] == 'purchase';
        return [
          pw.Text(
            "${tx['amount']}",
            style: pw.TextStyle(
              color: isDebt ? PdfColors.green : PdfColors.red,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          tx['items_summary'] ?? tx['note'] ?? "عملية مالية",
          tx['date'].toString().split(' ')[0],
        ];
      }).toList(),
    );
  }

  /// 3. ملخص نهائي وتوقيع
  static pw.Widget _buildFinalSummary(Map info) {
    return pw.Container(
      alignment: pw.Alignment.centerLeft,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Divider(),
          pw.Text("صافي المديونية المتبقية: ${info['total_debt']} ر.ي",
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 5),
          pw.Text("تاريخ التقرير: ${DateTime.now().toString()}", style: const pw.TextStyle(fontSize: 8)),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 50),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text("ختم المتجر: ....................", style: const pw.TextStyle(fontSize: 10)),
          pw.Text("توقيع العميل: ....................", style: const pw.TextStyle(fontSize: 10)),
        ],
      ),
    );
  }
}

/// تقرير تفصيلي لعميل محدد
class CustomerDetailedPdfGenerator {
  static GetStorage  box = GetStorage();

  /// تقرير تفصيلي
  static Future<void> generateDetailedPdf({
    required Map customerInfo,
    required List<dynamic> transactions,
  }) async
  {
    final pdf = pw.Document();

    // 1. تحميل الشعار والخطوط
    final arabicFont = await PdfGoogleFonts.amiriRegular();
    final boldFont = await PdfGoogleFonts.amiriBold();

    // تأكد من مسار الشعار في ملفاتك
    pw.ImageProvider? logo;
    try {
      final ByteData imageByteData = await rootBundle.load('assets/images/logo.jpg');
      logo = pw.MemoryImage(imageByteData.buffer.asUint8List());
    } catch (e) {
      print("Logo not found, proceeding without it");
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: arabicFont, bold: boldFont),
        textDirection: pw.TextDirection.rtl,
        margin: const pw.EdgeInsets.all(20),
        build: (context) => [
          _buildHeader(customerInfo, logo),
          pw.SizedBox(height: 10),
          _buildCustomerInfoSection(customerInfo),
          pw.SizedBox(height: 15),
          _buildDetailedTable(transactions),
          pw.SizedBox(height: 20),
          _buildFooter(context),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'كشف_تفصيلي_${customerInfo['name']}.pdf',
    );
  }

  /// الترويسة العلوية (الشعار واسم الشركة)
  static pw.Widget _buildHeader(Map info, pw.ImageProvider? logo) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(children: [
          pw.Text(box.read("merchantName").toString(), style: const pw.TextStyle(fontSize: 20)),
          pw.Text(box.read("merchantPhone").toString(), style: const pw.TextStyle(fontSize: 20)),
        ]),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.black)),
          child: pw.Text("تقرير تفصيلي", style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
        ),
        if (logo != null) pw.Container(width: 50, height: 50, child: pw.Image(logo)),
      ],
    );
  }

  /// قسم بيانات صاحب الحساب
  static pw.Widget _buildCustomerInfoSection(Map info) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text("صاحب الحساب: ${info['name']}", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.Text("رقم الهاتف: ${box.read("saved_phone") ?? '0'}", style: const pw.TextStyle(fontSize: 16)),
        pw.Align(
          alignment: pw.Alignment.centerLeft,
          child: pw.Text("من: 11/01/2026  إلى: ${DateTime.now().toString().split(' ')[0]}", style: const pw.TextStyle(fontSize: 13)),
        ),
      ],
    );
  }

  /// الجدول التفصيلي
  static pw.Widget _buildDetailedTable(List<dynamic> transactions) {
    double totalAmount = 0;
    for (var tx in transactions) {
      totalAmount += double.tryParse(tx['amount'].toString()) ?? 0;
    }

    return pw.TableHelper.fromTextArray(
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 15),
      cellStyle: const pw.TextStyle(fontSize: 13),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
      cellAlignment: pw.Alignment.center,
      columnWidths: {
        5: const pw.FixedColumnWidth(30), // م
        4: const pw.FixedColumnWidth(80), // التاريخ
        3: const pw.FlexColumnWidth(),   // السلعة
        2: const pw.FixedColumnWidth(50), // الكمية
        1: const pw.FixedColumnWidth(80), // السعر
        0: const pw.FixedColumnWidth(80), // الإجمالي
      },
      headers: [ 'الإجمالي', 'السعر', 'الكمية', 'السلعة','التاريخ','م'  ],
      data: [
        ...List.generate(transactions.length, (index) {
          var tx = transactions[index];
          return [
            tx['amount'].toString(),
            tx['amount'].toString(),
            "1.0",
            tx['items_summary'] ?? tx['note'] ?? "غير محدد",
            // يمكنك ربطها بحقل الكمية الفعلي لاحقاً
            tx['date'].toString().split(' ')[0],
            (index + 1).toString()
          ];
        }),
        // أسطر الملخص في نهاية الجدول كما في الصورة
        [totalAmount.toString(), '', '', '', 'اجمالي العمليات','' , ''],

      ],
    );
  }

  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Column(
      children: [
        pw.Align(
          alignment: pw.Alignment.centerLeft,
          child: pw.Text("تاريخ الطباعة: ${DateTime.now().toString().split(' ')[0]}", style: const pw.TextStyle(fontSize: 9)),
        ),
        pw.SizedBox(height: 20),
        pw.Align(
          alignment: pw.Alignment.centerLeft,
          child: pw.Text("صفحة ", style: const pw.TextStyle(fontSize: 8)),
        ),
      ],
    );
  }
}

/// تقرير مالي لعميل محدد
class CustomerFinancialPdfGenerator {
  static GetStorage  box = GetStorage();

  /// تقرير مالي
  static Future<void> generateFinancialPdf({
    required Map customerInfo,
    required List<dynamic> transactions,
  }) async
  {
    final pdf = pw.Document();

    final arabicFont = await PdfGoogleFonts.almaraiRegular();
    final boldFont = await PdfGoogleFonts.almaraiRegular();

    // تحميل الشعار
    pw.ImageProvider? logo;
    try {
      final ByteData imageByteData = await rootBundle.load('assets/images/logo.jpg');
      logo = pw.MemoryImage(imageByteData.buffer.asUint8List());
    } catch (e) { print("Logo load error: $e"); }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: arabicFont, bold: boldFont),
        textDirection: pw.TextDirection.rtl,
        margin: const pw.EdgeInsets.all(20),
        build: (context) => [
          _buildHeader(logo),
          pw.SizedBox(height: 10),
          _buildCustomerData(customerInfo),
          pw.SizedBox(height: 15),
          _buildFinancialTable(transactions),
          pw.SizedBox(height: 20),
          _buildSignatures(),
          pw.Align(
            alignment: pw.Alignment.centerLeft,
            child: pw.Text("تاريخ الطباعة: 07/02/2026", style: const pw.TextStyle(fontSize: 9)),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  static pw.Widget _buildHeader(pw.ImageProvider? logo) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(children: [
          pw.Text(box.read("Name").toString(), style: const pw.TextStyle(fontSize: 20)),
          pw.Text(box.read("saved_phone").toString(), style: const pw.TextStyle(fontSize: 20)),
        ]),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 25, vertical: 5),
          decoration: pw.BoxDecoration(border: pw.Border.all()),
          child: pw.Text("تقرير مالي", style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
        ),
        if (logo != null) pw.Container(width: 50, height: 50, child: pw.Image(logo)),
      ],
    );
  }

  static pw.Widget _buildCustomerData(Map info) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text("صاحب الحساب: ${info['name']}", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.Text("رقم الهاتف: ${info['phone'] ?? '0'}", style: const pw.TextStyle(fontSize: 16)),
        pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Text("من: 11/01/2026", style: const pw.TextStyle(fontSize: 14)),
              pw.SizedBox(width: 20),
              pw.Text("إلى: 06/02/2026", style: const pw.TextStyle(fontSize: 14)),
            ],
          ),


      ],
    );
  }

  static pw.Widget _buildFinancialTable(List<dynamic> transactions) {
    double totalDebit = 0;  // مدين
    double totalCredit = 0; // دائن
    double credit = 0 ;
    double debit = 0 ;
    return pw.TableHelper.fromTextArray(
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
      cellStyle: const pw.TextStyle(fontSize: 9),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
      cellAlignment: pw.Alignment.center,
      columnWidths: {
        0: const pw.FixedColumnWidth(40), // م
        1: const pw.FixedColumnWidth(70), // التاريخ
        2: const pw.FlexColumnWidth(),   // البيان
        3: const pw.FixedColumnWidth(60), // مدين
        4: const pw.FixedColumnWidth(60), // دائن
        5: const pw.FixedColumnWidth(60), // الرصيد
      },
      headers: ['م', 'التاريخ', 'البيان', 'مدين', 'دائن', 'الرصيد'],
      data: [
        ...List.generate(transactions.length, (index) {
          var tx = transactions[index];
          bool isDebt = tx['type'] == 'debt' || tx['type'] == 'purchase';
          double amount = double.tryParse(tx['amount'].toString()) ?? 0;

          debit += double.tryParse(tx['Debit'].toString()) ?? 0;
          credit += double.tryParse(tx['Credit'].toString()) ?? 0;

          if (isDebt) totalDebit += amount; else totalCredit += amount;

          return [
            (index + 1).toString(),
            tx['date'].toString().split(' ')[0],
            tx['items_summary'] ?? tx['note'] ?? "---",
            isDebt ? amount.toStringAsFixed(1) : "0.0",
            !isDebt ? amount.toStringAsFixed(1) : "0.0",
            (debit - credit).toString() ?? "0.0", // الرصيد المتراكم بعد الحركة
          ];
        }),
        // سطر مجموع العمليات
        ['', '', 'مجموع العمليات', totalDebit.toString(), totalCredit.toString(), ''],
        // سطر المتبقي
        ['', '', 'المتبقي', '', '', (totalDebit - totalCredit).toString(), ''],
      ],
    );
  }

  static pw.Widget _buildSignatures() {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 10),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text("توقيع المحاسب: ....................", style: const pw.TextStyle(fontSize: 10)),
          pw.Text("توقيع العميل: ....................", style: const pw.TextStyle(fontSize: 10)),
        ],
      ),
    );
  }
}






