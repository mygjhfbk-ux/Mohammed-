import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../controllers/customer_controller/merchant_controller.dart';
import '../merchant/payment_dialog.dart';
import 'debt_pdf_generator.dart';

class MerchantGeneralReportsView extends StatefulWidget {
  final int? no;
  const MerchantGeneralReportsView({super.key, required this.no});

  @override
  State<MerchantGeneralReportsView> createState() =>
      _MerchantGeneralReportsViewState();
}

class _MerchantGeneralReportsViewState
    extends State<MerchantGeneralReportsView> {
  final controller = Get.find<MerchantController>();
  final box = GetStorage();
  final Color primaryColor = const Color(0xFF1A4D7E);

  late String requestId;
  late String merchantId;
  String? name;
  dynamic data;

  DateTime fromDate = DateTime(2025, 1, 1);
  DateTime toDate   = DateTime.now();

  @override
  void initState() {
    super.initState();
    data      = Get.arguments ?? {};
    requestId = data['Request-id']?.toString() ?? data['requestId']?.toString() ?? "";
    merchantId = data['merchantId']?.toString() ?? box.read('Profile-id')?.toString() ?? "";
    name      = data['merchantName'] ?? data['Customer-Name'] ?? "المستخدم";

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchGeneralReports(merchantId, requestId);
    });
  }

  void _fetchData() {
    controller.startDate.value = fromDate;
    controller.endDate.value   = toDate;
    controller.fetchGeneralReports(merchantId, requestId);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FB),
        appBar: AppBar(
          title: const Text("تقارير العميل",
              style: TextStyle(color: Color(0xFF1A4D7E), fontWeight: FontWeight.bold, fontSize: 18)),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          leading: const BackButton(),
          actions: [
            IconButton(
              icon: const Icon(Icons.picture_as_pdf_outlined, color: Colors.red),
              onPressed: () => DebtPdfGenerator.generateCustomerStatement(
                  controller.customerInfo, controller.allTransactions),
            ),
          ],
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          final info = controller.customerInfo;
          return RefreshIndicator(
            onRefresh: () => controller.fetchGeneralReports(merchantId, requestId),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  _buildHeader(info),
                  _buildFilters(),
                  _buildActionButtons(),
                  _buildTransactionsList(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHeader(Map info) {
    return Container(
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15)]),
      child: Column(
        children: [
          Text(name ?? info['name'] ?? "",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A4D7E))),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _stat("سقف الحساب", info['account_limit']?.toString() ?? "0.0", Colors.blueGrey),
              _stat("اجمالي الدين", info['total_debt']?.toString() ?? "0.0", Colors.redAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 5),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.grey[50],
      child: Row(
        children: [
          _datePickerBox("من تاريخ", fromDate,
              (d) => setState(() { fromDate = d; _fetchData(); })),
          const SizedBox(width: 10),
          _datePickerBox("الى تاريخ", toDate,
              (d) => setState(() { toDate = d; _fetchData(); })),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: primaryColor, borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.filter_alt_outlined, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _datePickerBox(String label, DateTime date, Function(DateTime) onSelect) {
    return Expanded(
      child: InkWell(
        onTap: () async {
          final picked = await showDatePicker(
              context: context, initialDate: date,
              firstDate: DateTime(2020), lastDate: DateTime(2030));
          if (picked != null) onSelect(picked);
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white),
          child: Column(
            children: [
              Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              Text(DateFormat('yyyy-MM-dd').format(date),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Row(
        children: [
          Expanded(child: _reportBtn("تقرير تفصيلي", Icons.analytics_outlined, () {
            DebtPdfGenerator.generateCustomerStatement(
                controller.customerInfo, controller.allTransactions);
          })),
        ],
      ),
    );
  }

  Widget _reportBtn(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: primaryColor)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: primaryColor, size: 18),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsList() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Obx(() => ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.allTransactions.length,
        separatorBuilder: (_, __) => const Divider(height: 1, indent: 20, endIndent: 20),
        itemBuilder: (context, index) {
          final tx     = controller.allTransactions[index];
          final isDebt = tx['type'] == 'debt' || tx['type'] == 'purchase';
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            title: Text(tx['note'] ?? "عملية مالية",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            subtitle: Text(tx['date']?.toString().substring(0, 10) ?? "",
                style: const TextStyle(fontSize: 11, color: Colors.grey)),
            leading: Text("${tx['amount']}",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDebt ? Colors.green : Colors.redAccent)),
            trailing: widget.no == 1
                ? PopupMenuButton(
                    icon: const Icon(Icons.more_vert, size: 18),
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: 'delete', child: Text("حذف")),
                    ],
                    onSelected: (v) {
                      if (v == 'delete') {
                        _confirmDelete(tx['id'].toString());
                      }
                    })
                : null,
          );
        },
      )),
    );
  }

  void _confirmDelete(String transactionId) {
    Get.defaultDialog(
      title: "تأكيد الحذف",
      middleText: "هل أنت متأكد من حذف هذه العملية؟",
      textConfirm: "نعم، احذف",
      textCancel: "تراجع",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        Get.back();
        controller.deleteTransaction(transactionId, requestId);
      },
    );
  }
}
