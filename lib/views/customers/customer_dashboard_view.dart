import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../controllers/customer_controller/customer_dashboard_controller.dart';
import '../../widgets/ads_slider_widget.dart';
import '../login_view.dart';
import 'join_requests_view.dart';
import 'merchant_details_view.dart';
import 'notifications_view.dart';
import '../settings_view.dart';

class CustomerDashboardView extends GetView<CustomerDashboardController> {
  CustomerDashboardView({super.key});

  final box = GetStorage();
  final Color primaryColor = const Color(0xFF104A81);

  void _initializeUser() {
    final userId = box.read('User-id');
    if (userId != null) {
      controller.fetchDashboardData(userId);
    } else {
      Get.offAll(() => LoginView());
    }
  }

  @override
  Widget build(BuildContext context) {
    _initializeUser();
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text("لوحة التحكم",
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.settings_outlined, color: primaryColor),
          onPressed: () => Get.to(() => SettingsView(), arguments: {
            'Phone': box.read('saved_phone') ?? "",
            'Name':  controller.customerName,
          }),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none_rounded, color: primaryColor, size: 28),
            onPressed: () => Get.to(() => NotificationsView()),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.fetchDashboardData(box.read('User-id') ?? ''),
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return Directionality(
            textDirection: TextDirection.rtl,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCard(),
                  _buildJoinRequestsButton(),
                  AdsSliderWidget(),
                  _buildSectionTitle("المتاجر المتاحة"),
                  _buildMerchantGrid(),
                  _buildSectionTitle("آخر العمليات"),
                  _buildRecentTransactions(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, const Color(0xFF1A5A96)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.account_circle, color: Colors.white70, size: 40),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(controller.customerName,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  const Text("عميل نشط", style: TextStyle(color: Colors.greenAccent, fontSize: 12)),
                ],
              ),
            ],
          ),
          const Divider(color: Colors.white24, height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _summaryItem(controller.totalDebt, "إجمالي الدين", Colors.white),
              _summaryItem(controller.todayDebt, "دين اليوم", Colors.orangeAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 25, 16, 10),
      child: Text(title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor)),
    );
  }

  Widget _buildMerchantGrid() {
    return Obx(() {
      if (controller.acceptedMerchants.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(Icons.store_outlined, size: 60, color: Colors.grey[300]),
                const SizedBox(height: 10),
                const Text("لا توجد متاجر مفعّلة", style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        );
      }
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.85,
          mainAxisSpacing: 15,
          crossAxisSpacing: 15,
        ),
        itemCount: controller.acceptedMerchants.length,
        itemBuilder: (context, index) {
          final req      = controller.acceptedMerchants[index];
          final merchant = req['merchants'] ?? {};
          return InkWell(
            onTap: () => Get.to(() => MerchantDetailsView(), arguments: {
              'requestId':    req['id'],
              'merchantId':   merchant['id'],
              'merchantName': merchant['merchant_name'],
            }),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.store_mall_directory_outlined, size: 36, color: primaryColor),
                  const SizedBox(height: 8),
                  Text(
                    merchant['merchant_name'] ?? "متجر",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildRecentTransactions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: controller.recentTransactions.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: Text("لا توجد عمليات مسجلة")))
          : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.recentTransactions.length,
              separatorBuilder: (_, __) =>
                  const Divider(indent: 20, endIndent: 20),
              itemBuilder: (context, index) {
                final tx = controller.recentTransactions[index];
                final isPayment = tx['type'] == 'payment';
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        isPayment ? Colors.green[50] : Colors.red[50],
                    child: Icon(
                      isPayment ? Icons.arrow_downward : Icons.arrow_upward,
                      color: isPayment ? Colors.green : Colors.red,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    tx['requests']?['merchants']?['merchant_name'] ?? "متجر",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  subtitle: Text(tx['date']?.toString().substring(0, 10) ?? ""),
                  trailing: Text(
                    "${tx['amount']}",
                    style: TextStyle(
                        color: isPayment ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildJoinRequestsButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: InkWell(
        onTap: () => Get.to(() => JoinRequestsView()),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: BoxDecoration(
            color: Colors.orange[100],
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.mark_email_unread_outlined, color: Colors.orange[800]),
              const SizedBox(width: 15),
              Expanded(
                child: Text("طلبات فتح حساب مع متاجر جديدة",
                    style: TextStyle(
                        color: Colors.orange[900],
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.orange[800]),
            ],
          ),
        ),
      ),
    );
  }
}
