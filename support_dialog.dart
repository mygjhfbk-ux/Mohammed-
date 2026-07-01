import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../widgets/custom_button_back.dart';

/// واجهة تواصل بنا
class SupportDialog {
  static void show() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.support_agent_rounded,
                size: 60,
                color: Color(0xFF1A4D7E),
              ),
              const SizedBox(height: 10),
              
              const Text(
                "الدعم والمساعدة",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A4D7E),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "نحن هنا لمساعدتك، اختر وسيلة التواصل المناسبة لك",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              
              const SizedBox(height: 25),
              
              // خيارات التواصل
              _buildSupportOption(
                icon: Icons.chat_outlined,
                title: "تواصل عبر الواتساب",
                color: Colors.green,
                onTap: () => _launchURL("https://wa.me/967777777777"),
              ),
              
              _buildSupportOption(
                icon: Icons.phone_in_talk_outlined,
                title: "اتصال مباشر",
                color: const Color(0xFF1A4D7E),
                onTap: () => _launchURL("tel:+967777777777"),
              ),
              
              _buildSupportOption(
                icon: Icons.email_outlined,
                title: "إرسال بريد إلكتروني",
                color: Colors.orange,
                onTap: () => _launchURL("mailto:support@gmail.com"),
              ),
              const SizedBox(height: 20),
              CustomButtonBack(),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildSupportOption({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              title,
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(width: 15),
            Icon(icon, color: color),
          ],
        ),
      ),
    );
  }

  /// دالة لفتح الروابط
  static void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Get.snackbar("خطأ", "لا يمكن فتح الرابط حالياً");
    }
  }
}
