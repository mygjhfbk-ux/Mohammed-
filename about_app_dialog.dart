import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/custom_button_back.dart';

/// واجهة حول التطبيق
class AboutAppDialog {
  static void show() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A4D7E).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Image.asset('assets/images/logo.jpg', height: 80),
              ),
              const SizedBox(height: 15),
              const Text(
                "تطبيق ديوني",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A4D7E),
                ),
              ),
              const Text(
                "الإصدار 1.1",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 20),
              const Text(
                "نظام متكامل لإدارة مديونيات العملاء وتسهيل عمليات البيع بالدين والتحصيل المالي. يهدف التطبيق إلى تنظيم العلاقة بين التاجر والعميل وضمان دقة البيانات المالية.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, height: 1.5),
              ),
              const Divider(height: 30),
              _buildInfoRow(Icons.language, "الموقع الإلكتروني", "www.diony.com"),
              _buildInfoRow(Icons.support_agent, "الدعم الفني", "+967 777777777"),
              const SizedBox(height: 20),
              CustomButtonBack(),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildInfoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
          Row(
            children: [
              Text(title, style: const TextStyle(color: Colors.grey)),
              const SizedBox(width: 8),
              Icon(icon, size: 18, color: const Color(0xFF1A4D7E)),
            ],
          ),
        ],
      ),
    );
  }
}
