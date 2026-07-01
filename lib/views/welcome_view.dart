import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'login_view.dart';

class WelcomeView extends StatelessWidget {
   WelcomeView({super.key});
  final box = GetStorage();
  final Color primaryColor = const Color(0xFF0D47A1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // الشعار مع أنيميشن بسيط عند الانتقال
                Hero(
                  tag: 'auth_icon',
                  child: Image.asset(
                    'assets/images/logo.jpg',
                    height: 180,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.account_balance_wallet_rounded, size: 120, color: primaryColor),
                  ),
                ),
                const SizedBox(height: 30),

                Text("مرحباً بك في تطبيق ديوني",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: primaryColor)),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 15),
                  child: Text(
                    "الحل الأمثل لإدارة مديونيات كروت الشبكة وتتبع حساباتك بكل سهولة وأمان.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 15, height: 1.5),
                  ),
                ),

                const SizedBox(height: 50),

                // زر التاجر
                _buildActionButton(
                    text: " تاجر ",
                    icon: Icons.store_rounded,
                    color: primaryColor,
                    onTap: () {
                      Get.to(() => LoginView());
                      box.write('User-type', 'merchant');
                    }
                ),

                const SizedBox(height: 15),

                // زر العميل
                _buildActionButton(
                    text: " عميل ",
                    icon: Icons.person_rounded,
                    color: Colors.white,
                    isOutlined: true,
                    onTap: () {
                      Get.to(() => LoginView());
                      box.write('User-type', 'customer');
                    }
                ),

                const SizedBox(height: 40),

                Text("الإصدار 1.0.0", style: TextStyle(color: Colors.grey[400], fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isOutlined = false
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 35),
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: isOutlined ? primaryColor : Colors.white, size: 24),
        label: Text(
            text,
            style: TextStyle(
                color: isOutlined ? primaryColor : Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold
            )
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isOutlined ? Colors.white : color,
          minimumSize: const Size(double.infinity, 58),
          elevation: isOutlined ? 0 : 4,
          side: isOutlined ? BorderSide(color: primaryColor, width: 2) : null,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }
}
