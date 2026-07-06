import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../controllers/merchant_controller/merchant_dashboard_controller.dart';
import '../../widgets/ads_slider_widget.dart';
import '../settings_view.dart';
import '../customers/notifications_view.dart';
import '../login_view.dart';
import '../../widgets/add_debt_dialog.dart';
import 'customer_management.dart';
import 'merchant_overall_reports_view.dart';
import 'wallet_screen.dart';

class MerchantDashboardScreen extends StatefulWidget {
  const MerchantDashboardScreen({super.key});

  @override
  State<MerchantDashboardScreen> createState() => _MerchantDashboardScreenState();
}

class _MerchantDashboardScreenState extends State<MerchantDashboardScreen> {
  final controller = Get.find<MerchantDashboardController>();
  final Color primaryColor = const Color(0xFF07477E);
  final box = GetStorage();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAuthAndFetch());
  }

  void _checkAuthAndFetch() {
    final merchantId = box.read('Profile-id');
    if (merchantId != null) {
      controller.fetchDashboardData(merchantId);
    } else {
      Get.offAll(() => LoginView());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: primaryColor),
            onPressed: () => Get.to(() => SettingsView(), arguments: {
              'Phone': controller.phoneNumber.value,
              'Name':  controller.merchantName.value,
            }),
          ),
          IconButton(
            icon: Icon(Icons.notifications_none_rounded, color: primaryColor),
            onPressed: () => Get.to(() => NotificationsView()),
          ),
        ],
        title: Text("ديوني - لوحة التاجر",
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async => _checkAuthAndFetch(),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatsCard(),
                const SizedBox(height: 25),
                const Text("الوصول السريع",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                _buildActionsGrid(),
                const SizedBox(height: 25),
                _buildSubscriptionBanner(),
                const SizedBox(height: 10),
                AdsSliderWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: primaryColor.withOpacity(0.1),
                child: Icon(Icons.storefront, color: primaryColor, size: 30),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() => Text(controller.merchantName.value,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor))),
                    Obx(() => Text(controller.businessType.value,
                        style: TextStyle(color: Colors.grey[600], fontSize: 13))),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 30, thickness: 0.5),
          Obx(() => controller.isLoading.value
              ? const LinearProgressIndicator()
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _statItem("العملاء", "${controller.totalCustomers.value}", Icons.people_outline),
                    _statItem("إجمالي الديون", "${controller.totalDebts.value}", Icons.account_balance_wallet_outlined),
                    _statItem("ديون اليوم", "${controller.todayDebts.value}", Icons.today_outlined),
                  ],
                )),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(height: 8),
        Text(value,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: label.contains("ديون") ? Colors.red[700] : Colors.black87)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildActionsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 1.3,
      children: [
        _actionCard("إدارة العملاء", Icons.people_alt_rounded, Colors.blue,
            () => Get.to(() => CustomerManagementScreen())),
        _actionCard("المحافظ", Icons.account_balance_rounded, Colors.teal,
            () => Get.to(() => WalletScreen())),
        _actionCard("إضافة دين", Icons.post_add_rounded, Colors.orange,
            () => Get.to(() => CustomerManagementScreen())),
        _actionCard("التقارير", Icons.analytics_outlined, Colors.indigo,
            () => Get.to(() => MerchantOverallReportsView())),
      ],
    );
  }

  Widget _actionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionBanner() {
    String expiryDateStr = box.read('sub_expiry') ?? "";
    bool isTrial = box.read('sub_status') == 'trial';
    int daysLeft = 0;
    if (expiryDateStr.isNotEmpty) {
      try {
        DateTime expiry = DateTime.parse(expiryDateStr);
        daysLeft = expiry.difference(DateTime.now()).inDays;
      } catch (_) {}
    }
    Color bannerColor = daysLeft <= 5 ? Colors.redAccent : primaryColor;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: [bannerColor, bannerColor.withOpacity(0.8)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isTrial ? "الفترة التجريبية" : "الاشتراك الاحترافي",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(
                  daysLeft > 0 ? "متبقي لديك $daysLeft يوم" : "انتهى الاشتراك",
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          Icon(Icons.verified_user, color: Colors.white.withOpacity(0.5), size: 40),
        ],
      ),
    );
  }
}
