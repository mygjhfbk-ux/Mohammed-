import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../controllers/merchant_controller/transactions_controller.dart';
import '../reports/debt_pdf_generator.dart';

/// واجهة تقارير المتجر
class MerchantOverallReportsView extends StatefulWidget {
  const MerchantOverallReportsView({super.key});

  @override
  State<MerchantOverallReportsView> createState() => _MerchantOverallReportsViewState();
}

class _MerchantOverallReportsViewState extends State<MerchantOverallReportsView> {
  final  controller = Get.find<TransactionsController>();
  final box = GetStorage();


  // متغيرات الفلترة
  DateTime fromDate = DateTime.now();
  DateTime toDate = DateTime.now();
  String selectedType = "كافه التقارير";

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    // استدعاء دالة جلب التقارير العامة من الكنترولر
    controller.fetchMerchantOverallReports(
      fromDate: DateFormat('yyyy-MM-dd').format(fromDate),
      toDate: DateFormat('yyyy-MM-dd').format(toDate),
      type: selectedType,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("تقرير المتجر", style: TextStyle(color: Color(0xFF1A4D7E), fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0.5,
          actions: [
            IconButton(icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
                onPressed: () {
                  DebtPdfGenerator.generateCustomersDebtPdf(controller.overallReports);
            }),
          ],
        ),
        body: Column(
          children: [
            _buildFilters(),
            _buildTableHeader(),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
                if (controller.overallReports.isEmpty) return const Center(child: Text("لا توجد بيانات لهذه الفترة"));

                return ListView.separated(
                  itemCount: controller.overallReports.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final report = controller.overallReports[index];
                    return _buildReportRow(report);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // بناء قسم الفلاتر (التاريخ والنوع)
  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.grey[50],
      child: Column(
        children: [
          Row(
            children: [
              _datePickerBox("من تاريخ", fromDate, (date) => setState(() { fromDate = date; _fetchData(); })),
              const SizedBox(width: 10),
              _datePickerBox("الى تاريخ", toDate, (date) => setState(() { toDate = date; _fetchData(); })),
              const SizedBox(width: 10),
              _filterButton(),
            ],
          ),
          const SizedBox(height: 12),
          _typeDropdown(),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      color: Colors.grey[200],
      child: const Row(
        children: [
          Expanded(flex: 2, child: Text("التاريخ", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
          Expanded(flex: 2, child: Text("البيان", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
          Expanded(flex: 2, child: Text("العميل", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
          Expanded(flex: 1, child: Text("المبلغ", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
          Expanded(flex: 1, child: Text("الاجراء", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
        ],
      ),
    );
  }

  Widget _buildReportRow(Map report) {
    bool isDebt = report['Transaction-type'] == 'debt' || report['Transaction-type'] == 'purchase';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 5),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(report['Transaction-Date'].toString().split(' ')[0], textAlign: TextAlign.center, style: const TextStyle(fontSize: 11))),
          Expanded(flex: 2, child: Text(report['items_summary'] ?? report['Description'] ?? "", textAlign: TextAlign.center, style: const TextStyle(fontSize: 11))),
          Expanded(flex: 2, child: Text(report['Customer-Name'] ?? "", textAlign: TextAlign.center, style: const TextStyle(fontSize: 11))),
          Expanded(flex: 1, child: Text("${report['Amount']}", textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDebt ? Colors.green : Colors.red))),
          Expanded(flex: 1, child: IconButton(
              icon: Icon(Icons.more_vert, size: 18, color: Colors.blue[800]),
            onPressed: (){}),
          ),
        ],
      ),
    );
  }

  // أداة اختيار التاريخ
  Widget _datePickerBox(String label, DateTime date, Function(DateTime) onSelect) {
    return Expanded(
      child: InkWell(
        onTap: () async {
          DateTime? picked = await showDatePicker(context: context, initialDate: date, firstDate: DateTime(2020), lastDate: DateTime(2030));
          if (picked != null) onSelect(picked);
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8), color: Colors.white),
          child: Column(
            children: [
              Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              Text(DateFormat('yyyy-MM-dd').format(date), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _typeDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8), color: Colors.white),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: selectedType,
          items: ["كافه التقارير", "قبض مبلغ", "دين جديد"].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
          onChanged: (val) => setState(() { selectedType = val!; _fetchData(); }),
        ),
      ),
    );
  }

  Widget _filterButton() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF1A4D7E), borderRadius: BorderRadius.circular(8)),
      child: const Icon(Icons.filter_alt_outlined, color: Colors.white, size: 20),
    );
  }

}


