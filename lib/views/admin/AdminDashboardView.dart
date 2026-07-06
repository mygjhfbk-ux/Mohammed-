import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../controllers/admin_controller/AdminDashboardController.dart';
import '../../controllers/admin_controller/AdsManagementController.dart';
import '../../controllers/admin_controller/UsersManagementController.dart';
import '../settings_view.dart';
import 'AdsManagementView.dart';
import 'UsersManagementView.dart';

class AdminDashboardView extends GetView<AdminDashboardController> {
  AdminDashboardView({super.key});
  final box = GetStorage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("إدارة نظام ديوني",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () => Get.to(() => SettingsView(), arguments: {
            'Phone': box.read('saved_phone') ?? "",
            'Name':  box.read('User-Name'),
          }),
        ),
        actions: [
          IconButton(
            onPressed: () => controller.refreshDashboard(),
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: () => controller.refreshDashboard(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("إحصائيات المستخدمين"),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildStatBox("إجمالي التجار",
                          controller.merchantsCount.toString(), Icons.store, Colors.blue),
                      const SizedBox(width: 10),
                      _buildStatBox("إجمالي العملاء",
                          controller.customersCount.toString(), Icons.person_outline, Colors.orange),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSectionTitle("المالية والطلبات"),
                  const SizedBox(height: 10),
                  _buildLongStatCard(
                      "إجمالي الديون المسجلة",
                      "${controller.totalDebt.value} ريال",
                      Icons.account_balance_wallet,
                      Colors.green),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildStatBox("طلبات ربط معلقة",
                          controller.pendingReq.toString(), Icons.hourglass_empty, Colors.red),
                      const SizedBox(width: 10),
                      _buildStatBox("إعلانات نشطة",
                          controller.activeAds.toString(), Icons.campaign, Colors.purple),
                    ],
                  ),
                  const SizedBox(height: 25),
                  _buildSectionTitle("إجراءات سريعة"),
                  const SizedBox(height: 10),
                  _buildAdminAction("إدارة المستخدمين", Icons.people_alt, () {
                    Get.to(() => UsersManagementView(),
                        binding: BindingsBuilder(() {
                          Get.lazyPut(() => UsersManagementController());
                        }));
                  }),
                  _buildAdminAction("مراجعة الإعلانات", Icons.ads_click, () {
                    Get.to(() => AdsManagementView(),
                        binding: BindingsBuilder(() {
                          Get.lazyPut(() => AdsManagementController());
                        }));
                  }),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF07477E)));
  }

  Widget _buildStatBox(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 10),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildLongStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
              backgroundColor: color, child: Icon(icon, color: Colors.white)),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, color: Colors.black54)),
              Text(value,
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildAdminAction(String title, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Colors.grey[200]!)),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF07477E)),
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: onTap,
      ),
    );
  }
}
