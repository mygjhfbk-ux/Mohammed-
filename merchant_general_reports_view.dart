import 'package:app_merchant_customer/controllers/customer_controller/merchant_controller.dart';
import 'package:app_merchant_customer/views/merchant/payment_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'debt_pdf_generator.dart';
import '../merchant/edit_transaction_view.dart';

/// واجهة تقارير العميل تستخدم مع التاجر والعميل
class MerchantGeneralReportsView extends StatefulWidget {
  final int? no;
  const MerchantGeneralReportsView({super.key,required this.no});

  @override
  State<MerchantGeneralReportsView> createState() => _MerchantGeneralReportsViewState();
}

class _MerchantGeneralReportsViewState extends State<MerchantGeneralReportsView> {
  final controller = Get.find<MerchantController>();
  final box = GetStorage();
  final Color primaryColor = const Color(0xFF1A4D7E);

  late int requestId;
   int? no;
  late int merchantId;
  String? phone;
  String? name;
  dynamic data;
  DateTime fromDate = DateTime(2025,DateTime.april,1);
  DateTime toDate = DateTime.now();

  @override
  void initState() {
    super.initState();
     _initParams();
  }

  void _initParams() {
     data = Get.arguments;
    if(widget.no == 1){
      // استقبال البيانات المارة من واجهة إدارة العملاء
      requestId = data['Request-id'] ?? 0;
      phone = data['phone'] ?? "0";
      merchantId = box.read('Profile-id') ?? data["merchantId"];
    }
    else if(widget.no == 2){
      // استقبال البيانات المارة من واجهة إدارة العملاء
      requestId = data['Request-id'] ?? 0;
      phone =  data["merchantPhone"];
      merchantId =  data["merchantId"];
      name = data["merchantName"] ?? "مستخدم";
      box.write('merchantName', name);
      box.write('merchantPhone', phone);
    }

    // طلب البيانات من السيرفر فور الدخول
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchGeneralReports(merchantId, requestId);
    });
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
          leading: BackButton(),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          // نأخذ البيانات من customerInfo التي حدثناها في الكنترولر
          var info = controller.customerInfo;

          return RefreshIndicator(
            onRefresh: () => controller.fetchGeneralReports(merchantId, requestId),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  _buildCustomerHeader(info),
                  _buildFilters(),
                  _buildActionButtons(),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text("اسحب العنصر لليمين للحذف أو لليسار للتعديل",
                        style: TextStyle(color: Colors.grey, fontSize: 11)),
                  ),
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

  Widget _buildCustomerHeader(Map info) {
    return Container(
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          Text(name ?? info['name'],
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A4D7E))),
          const SizedBox(height: 5),
          Text("الهاتف: $phone", style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _headerStat("سقف الحساب", info['account_limit']?.toString() ?? "0.0", Colors.blueGrey),
              _headerStat("اجمالي الدين", info['total_debt']?.toString() ?? "0.0", Colors.redAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 5),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          Expanded(child: _reportBtn("تقرير تفصيلي", Icons.analytics_outlined,() {
            CustomerDetailedPdfGenerator.generateDetailedPdf(
            customerInfo: controller.customerInfo, // البيانات العلوية
            transactions: controller.allTransactions, // قائمة العمليات
          );
          },)),
          const SizedBox(width: 12),
          Expanded(child: _reportBtn("تقرير مالي", Icons.account_balance_wallet_outlined,() {
            CustomerFinancialPdfGenerator.generateFinancialPdf(
              customerInfo: controller.customerInfo, // البيانات العلوية
              transactions: controller.allTransactions, // قائمة العمليات
            );
          },)),
        ],
      ),
    );
  }

  Widget _buildTransactionsList() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.allTransactions.length,
        separatorBuilder: (context, index) => const Divider(height: 1, indent: 20, endIndent: 20),
        itemBuilder: (context, index) {
          final tx = controller.allTransactions[index];
          return _buildSlidableItem(tx);
        },
      ),
    );
  }

  Widget _buildSlidableItem(Map tx) {
    bool isDebt = tx['type'] == 'debt' || tx['type'] == 'purchase';
    // عرض الأصناف إذا وجدت، وإلا عرض الوصف
    String title = tx['items_summary'] ?? tx['note'] ?? "عملية مالية";
    return Slidable(
      key: ValueKey(tx['id']),
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              if(widget.no == 1){
                _confirmDelete(tx['id']);
              }

            } ,
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'حذف',
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context)
            {
            if(widget.no == 1) {
              if (tx['type'] == "debt") {
                Get.to(() => EditDetailedDebtView(transactionId: tx['id'],));
              }
              else {
                showPaymentDialog(data,transaction: tx);
              }
            }
            },
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'تعديل',
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        title: Text(title,
            maxLines: 1, overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2D3142))),
        subtitle: Text(tx['date'] ?? "", style: const TextStyle(fontSize: 11, color: Colors.grey)),
        leading: Text("${tx['amount']}",
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDebt ? const Color(0xFF4CAF50) : Colors.redAccent // الأخضر للدين، الأحمر للقبض
            )),
      ),
    );
  }

  Widget _reportBtn(String label, IconData icon,GestureTapCallback? onTap ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: primaryColor),
        ),
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

  /// دوال الحذف
  void _confirmDelete(int transactionId) {
    Get.defaultDialog(
      title: "تأكيد الحذف",
      middleText: "هل أنت متأكد من حذف هذه العملية؟ سيتم تعديل رصيد العميل تلقائياً.",
      textConfirm: "نعم، احذف",
      textCancel: "تراجع",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        Get.back(); // إغلاق الديالوج
        controller.deleteTransaction(transactionId, requestId);
      },
    );
  }

  Widget _filterButton() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF1A4D7E), borderRadius: BorderRadius.circular(8)),
      child: const Icon(Icons.filter_alt_outlined, color: Colors.white, size: 20),
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


  void _fetchData() {

    controller.startDate.value = fromDate;
    controller.endDate.value = toDate;
    controller.fetchGeneralReports(merchantId, requestId);
  }

  // بناء قسم الفلاتر (التاريخ والنوع)
  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.grey[50],
      child: Row(
        children: [
          _datePickerBox("من تاريخ", fromDate, (date) => setState(() { fromDate = date; _fetchData(); })),
          const SizedBox(width: 10),
          _datePickerBox("الى تاريخ", toDate, (date) => setState(() { toDate = date; _fetchData(); })),
          const SizedBox(width: 10),
          _filterButton(),
        ],
      ),
    );
  }

}
