import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../controllers/customer_controller/merchant_controller.dart';
import '../reports/merchant_general_reports_view.dart';
import 'merchant_wallets_view.dart';

class MerchantDetailsView extends StatefulWidget {
  const MerchantDetailsView({super.key});

  @override
  State<MerchantDetailsView> createState() => _MerchantDetailsViewState();
}

class _MerchantDetailsViewState extends State<MerchantDetailsView> {
  final controller = Get.find<MerchantController>();
  final box = GetStorage();
  final Color primaryColor = const Color(0xFF1A4D7E);

  String? merchantName;
  String? merchantId;
  String? requestId;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments ?? {};
    merchantName = args['merchantName'] ?? "تفاصيل المتجر";
    merchantId   = args['merchantId']?.toString();
    requestId    = args['requestId']?.toString();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (merchantId != null) {
        controller.fetchDetails(merchantId!, box.read('User-id') ?? '');
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
          title: const Text("بيانات المتجر",
              style: TextStyle(color: Color(0xFF1A4D7E), fontWeight: FontWeight.bold, fontSize: 18)),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0.5,
          leading: const BackButton(color: Color(0xFF1A4D7E)),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          final details = controller.merchantDetails;
          return RefreshIndicator(
            onRefresh: () => controller.fetchDetails(merchantId ?? '', box.read('User-id') ?? ''),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  _buildTopInfoCard(details),
                  if ((details['total_debt'] ?? 0) > 0) _buildDebtAlert(),
                  _buildSectionHeader("الخدمات المتاحة"),
                  _buildServicesGrid(details),
                  _buildSectionHeader("ديون سجلت اليوم"),
                  _buildTodayDebts(details),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTopInfoCard(Map data) {
    return Container(
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15)]),
      child: Column(
        children: [
          Text(merchantName ?? "",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryColor)),
          const SizedBox(height: 10),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.verified_user_rounded, color: Colors.green, size: 16),
              SizedBox(width: 5),
              Text("حساب معتمد نشط", style: TextStyle(color: Colors.green, fontSize: 12)),
            ],
          ),
          const Divider(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _columnDetail("سقف الائتمان", "${data['account_limit'] ?? '0.0'}", Colors.black87),
              _columnDetail("إجمالي المديونية", "${data['total_debt'] ?? '0.0'}", Colors.redAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _columnDetail(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 8),
        Text("$value ر.ي", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildDebtAlert() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.red.shade100)),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notification_important_rounded, color: Colors.redAccent),
          SizedBox(width: 10),
          Text("تذكير: يرجى تسديد الديون المتأخرة",
              style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildServicesGrid(Map data) {
    final args = {
      'requestId':    requestId,
      'merchantId':   merchantId,
      'merchantName': merchantName,
      'Request-id':   data['id'] ?? requestId,
    };
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _serviceCard("كشف حساب", Icons.analytics_rounded,
            () => Get.to(() => const MerchantGeneralReportsView(no: 2), arguments: args)),
        _serviceCard("طرق الدفع", Icons.account_balance_wallet_outlined,
            () => Get.to(() => MerchantWalletsView(), arguments: args)),
      ],
    );
  }

  Widget _serviceCard(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: primaryColor, size: 28),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayDebts(Map data) {
    final items = data['today_transactions'] as List? ?? [];
    return Container(
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text("لا توجد مديونيات مسجلة اليوم", style: TextStyle(color: Colors.grey)),
            )
          else
            ...items.map((item) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(item['type'] == "debt" ? "دين" : "سند دفع",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  trailing: Text("${item['amount']} ر.ي",
                      style: TextStyle(
                          color: item['type'] == "debt" ? Colors.red : Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                )),
          const Divider(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.orange.shade800, borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("إجمالي دين اليوم:", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text("${data['today_debt_total'] ?? '0.0'} ريال",
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
