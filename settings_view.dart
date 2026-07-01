import 'package:app_merchant_customer/views/welcome_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'about_app_dialog.dart';
import '../reset_password_view.dart';
import 'support_dialog.dart';

/// واجهة اعدادات التطبيق
class SettingsView extends StatelessWidget {
  String? initialPhone;
  String? initialName;
   SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = Get.arguments;
    initialPhone = args['Phone'];
    initialName = args['Name'] ?? "تفاصيل المتجر";
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: const Text("الإعدادات", 
          style: TextStyle(color: Color(0xFF1A4D7E), fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildUserProfileCard(),

            const SizedBox(height: 20),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  _buildSettingsItem(Icons.settings_outlined, "ادارة الحساب", () {Get.to(() => ResetPasswordView());}),
                  _buildSettingsItem(Icons.help_outline, "الدعم والمساعدة", () {SupportDialog.show();}),
                  _buildSettingsItem(Icons.info_outline, "عن التطبيق", () {AboutAppDialog.show();}),
                  _buildSettingsItem(Icons.code, "الشركة المطورة", () {}),
                  _buildSettingsItem(Icons.restore, "الخروج الى الصفحة الرئيسية", () => Get.back()),
                  _buildSettingsItem(Icons.logout, "الخروج من الحساب", () => _showLogoutDialog(), isExit: true),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _buildSwitchOption(),

            const SizedBox(height: 20),
            const Text("1.1", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfileCard() {
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
           Text(initialName!,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const Divider(height: 30),
           Text(" ${initialPhone ?? "777777777"} 967+",textAlign: TextAlign.left,
            style: TextStyle( fontSize: 16, color: Colors.grey, letterSpacing: 1.2)),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, VoidCallback onTap, {bool isExit = false}) {
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          leading: const Icon(Icons.arrow_back_ios, size: 16, color: Colors.black54),
          trailing: Icon(icon, color: isExit ? Colors.red : const Color(0xFF1A4D7E)),
          title: Align(
            alignment: Alignment.centerRight,
            child: Text(title, 
              style: TextStyle(
                fontSize: 16, 
                fontWeight: FontWeight.w500,
                color: isExit ? Colors.red : Colors.black87
              )
            ),
          ),
        ),
        const Divider(height: 1, indent: 20, endIndent: 20),
      ],
    );
  }

  Widget _buildSwitchOption() {
    var isSwitched = true.obs;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(() => Switch(
            value: isSwitched.value,
            onChanged: (value) => isSwitched.value = value,
            activeColor: const Color(0xFF1A4D7E),
          )),
          Row(
            children: const [
              Text("تثبيت تطبيق العميل كرئيسي", 
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              SizedBox(width: 10),
              Icon(Icons.grid_view_rounded, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    Get.defaultDialog(
      title: "تسجيل الخروج",
      middleText: "هل أنت متأكد من رغبتك في الخروج؟",
      textConfirm: "نعم",
      textCancel: "إلغاء",
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.offAll(WelcomeView());
      }
    );
  }
}
