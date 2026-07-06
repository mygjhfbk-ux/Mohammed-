import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'custom_button_back.dart';

class SupportDialog {
  static void show() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.support_agent_rounded, size: 60, color: Color(0xFF1A4D7E)),
              const SizedBox(height: 10),
              const Text("الدعم والمساعدة",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A4D7E))),
              const SizedBox(height: 8),
              const Text("نحن هنا لمساعدتك",
                  textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 25),
              _buildOption(Icons.chat_outlined, "تواصل عبر الواتساب", Colors.green),
              _buildOption(Icons.phone_in_talk_outlined, "اتصال مباشر", const Color(0xFF1A4D7E)),
              _buildOption(Icons.email_outlined, "إرسال بريد إلكتروني", Colors.orange),
              const SizedBox(height: 20),
              CustomButtonBack(),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildOption(IconData icon, String title, Color color) {
    return Container(
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
          Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(width: 15),
          Icon(icon, color: color),
        ],
      ),
    );
  }
}
