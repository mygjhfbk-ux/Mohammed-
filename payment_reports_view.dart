import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../controllers/customer_controller/merchant_controller.dart';

/// واجهة سجل السداد خاصة بالعميل
class PaymentReportsView extends StatefulWidget {
  const PaymentReportsView({super.key});

  @override
  State<PaymentReportsView> createState() => _PaymentReportsViewState();
}

class _PaymentReportsViewState extends State<PaymentReportsView> {
  final MerchantController controller = Get.find<MerchantController>();
  final box = GetStorage();
  final Color primaryColor = const Color(0xFF1A4D7E);

  String? initialMerchantName;
  int? userId;
  int? merchantId;

  @override
  void initState() {
    super.initState();
    final Map<String, dynamic>? args = Get.arguments;
    userId = box.read('User-id') ?? 0;

    if (args != null) {
      initialMerchantName = args['merchantName'];
      merchantId = args['merchantId'];
    }

    // جلب البيانات بعد بناء الواجهة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (userId != 0 && merchantId != null) {
        controller.fetchPaymentReports(merchantId!, userId!);
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FB),
        appBar: AppBar(
          title: Column(
            children: [
              const Text("سجل المدفوعات",
                  style: TextStyle(color: Color(0xFF1A4D7E), fontWeight: FontWeight.bold, fontSize: 18)),
              if (initialMerchantName != null)
                Text(initialMerchantName!,
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0.5,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1A4D7E), size: 20),
            onPressed: () => Get.back(),
          ),
        ),
        body: Column(
          children: [
            _buildHeaderSummary(),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.paymentReports.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: controller.paymentReports.length,
                  itemBuilder: (context, index) {
                    return _buildReportCard(controller.paymentReports[index]);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("المبالغ المسددة",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(Icons.history_rounded, size: 16, color: primaryColor),
                const SizedBox(width: 5),
                Obx(() => Text("${controller.paymentReports.length} عملية",
                    style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(Map report) {
    String type = report['Transaction-type'] ?? "سداد";
    String amount = report['amount']?.toString() ?? "0";
    String date = report['date'] ?? "--/--/----";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        leading: CircleAvatar(
          backgroundColor: Colors.green[50],
          child: const Icon(Icons.check_circle_outline, color: Colors.green),
        ),
        title: Text("تم سداد مبلغ $amount ر.ي",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            children: [
              Icon(Icons.payment, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 5),
              Text(type, style: TextStyle(color: Colors.grey[600])),
              const Spacer(),
              Icon(Icons.access_time, size: 14, color: Colors.grey[400]),
              const SizedBox(width: 5),
              Text(date, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[200]),
          const SizedBox(height: 15),
          const Text("لا توجد تقارير دفع لهذا المتجر", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}







