import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../controllers/merchant_controller/merchant_dashboard_controller.dart';
import '../../widgets/ads_slider_widget.dart';
import '../core/settings_view.dart';
import '../customers/notifications_view.dart';
import '../login_view.dart';
import 'add_debt_dialog.dart';
import 'customer_anagement.dart';
import 'merchant_overall_reports_view.dart';
import 'wallet_screen.dart';

/// واجهة لوحة تحكم التاجر
class MerchantDashboardScreen extends StatefulWidget {
  const MerchantDashboardScreen({super.key});

  @override
  State<MerchantDashboardScreen> createState() => _MerchantDashboardScreenState();
}

class _MerchantDashboardScreenState extends State<MerchantDashboardScreen> {
  // استخدام Get.put أو Get.find
  final controller = Get.put(MerchantDashboardController());
  final Color primaryColor = const Color(0xFF07477E);
  final box = GetStorage();
  int? userId;

  @override
  void initState() {
    super.initState();
    // تنفيذ التحقق بعد أول Frame لضمان استقرار التطبيق
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthAndFetch();
    });
  }

  void _checkAuthAndFetch() {
     userId = box.read('User-id') ?? 0;
    if (userId != 0) {
      controller.fetchDashboardData(userId!);
    } else {
      Get.offAll(() =>  LoginView());
    }
  }

  @override
  Widget build(BuildContext context) {
    _checkAuthAndFetch();
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          IconButton(icon: Icon(Icons.settings_outlined, color: primaryColor),
            onPressed: () => Get.to(() => SettingsView(), arguments: {
              'Phone': controller.phoneNumber.value,
              'Name': controller.merchantName.value,
            }),
          ),
          IconButton(icon: Icon(Icons.notifications_none_rounded, color: primaryColor),
              onPressed: () => Get.to(() => NotificationsView())
          ),
        ],
        title: Text("ديوني - لوحة التاجر",
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // int userId = box.read('User-id') ?? 0;
          await controller.fetchDashboardData(userId!);
        },
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
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
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
              Icon(Icons.verified, color: Colors.blue[700], size: 20),
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
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: label.contains("ديون") ? Colors.red[700] : Colors.black87)),
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
        _actionCard("إدارة العملاء", Icons.people_alt_rounded, Colors.blue, () {
          // هنا يفضل الانتقال لصفحة إدارة العملاء أولاً ليختار العميل
          Get.to(() => CustomerManagementScreen());
        }),
        _actionCard("المحافظ", Icons.account_balance_rounded, Colors.teal, () => Get.to(() =>  WalletScreen())),
        _actionCard("إضافة دين", Icons.post_add_rounded, Colors.orange, () {
          // هنا يفضل الانتقال لصفحة إدارة العملاء أولاً ليختار العميل
          showAddDebtDialog();
        }),
        _actionCard("التقارير", Icons.analytics_outlined, Colors.indigo, () => Get.to(() => MerchantOverallReportsView())),
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
    // جلب البيانات من التخزين المحلي
    final box = GetStorage();
    String expiryDateStr = box.read('sub_expiry') ?? "";
    bool isTrial = box.read('sub_status') == 'trial';

    // حساب الأيام المتبقية
    int daysLeft = 0;
    if (expiryDateStr.isNotEmpty) {
      DateTime expiry = DateTime.parse(expiryDateStr);
      daysLeft = expiry.difference(DateTime.now()).inDays;
    }

    // تحديد اللون بناءً على المدة المتبقية
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
        boxShadow: [
          BoxShadow(color: bannerColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      isTrial ? "الفترة التجريبية" : "الاشتراك الاحترافي",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                    if (daysLeft <= 5)
                      const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 18),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  daysLeft > 0
                      ? "متبقي لديك $daysLeft يوم"
                      : "انتهى الاشتراك اليوم",
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          // زر "تجديد" يظهر فقط إذا قارب الاشتراك على الانتهاء
          if (daysLeft <= 7)
            ElevatedButton(
              onPressed: () {
                // هنا يمكن وضع كود لفتح واتساب الإدارة
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: bannerColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: const Text("تجديد الآن", style: TextStyle(fontWeight: FontWeight.bold)),
            )
          else
            Icon(Icons.verified_user, color: Colors.white.withOpacity(0.5), size: 40),
        ],
      ),
    );
  }

}



