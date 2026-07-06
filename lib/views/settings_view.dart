import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import 'reset_password_view.dart';
import '../widgets/about_app_dialog.dart';
import '../widgets/support_dialog.dart';

class SettingsView extends StatelessWidget {
  SettingsView({super.key});

  final Color primaryColor = const Color(0xFF1A4D7E);

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = Get.arguments ?? {};
    final String phone = args['Phone'] ?? "";
    final String name  = args['Name']  ?? "المستخدم";

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: const Text("الإعدادات",
            style: TextStyle(color: Color(0xFF1A4D7E), fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildUserProfileCard(name, phone),
              const SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    _buildSettingsItem(Icons.lock_reset, "تغيير كلمة المرور",
                        () => Get.to(() => ResetPasswordView(phone: phone))),
                    _buildSettingsItem(Icons.help_outline, "الدعم والمساعدة",
                        () => SupportDialog.show()),
                    _buildSettingsItem(Icons.info_outline, "عن التطبيق",
                        () => AboutAppDialog.show()),
                    _buildSettingsItem(
                        Icons.logout, "تسجيل الخروج", () => _showLogoutDialog(),
                        isExit: true),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              const Text("الإصدار 1.0.0", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserProfileCard(String name, String phone) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          const Icon(Icons.account_circle, size: 80, color: Colors.grey),
          const SizedBox(height: 10),
          Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const Divider(height: 30),
          Text("+967 $phone",
              style: const TextStyle(fontSize: 16, color: Colors.grey, letterSpacing: 1.2)),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, VoidCallback onTap,
      {bool isExit = false}) {
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          leading: const Icon(Icons.arrow_back_ios, size: 16, color: Colors.black54),
          trailing: Icon(icon, color: isExit ? Colors.red : primaryColor),
          title: Align(
            alignment: Alignment.centerRight,
            child: Text(title,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isExit ? Colors.red : Colors.black87)),
          ),
        ),
        const Divider(height: 1, indent: 20, endIndent: 20),
      ],
    );
  }

  void _showLogoutDialog() {
    Get.defaultDialog(
      title: "تسجيل الخروج",
      middleText: "هل أنت متأكد من رغبتك في الخروج؟",
      textConfirm: "نعم",
      textCancel: "إلغاء",
      confirmTextColor: Colors.white,
      onConfirm: () => Get.find<AuthController>().logout(),
    );
  }
}
