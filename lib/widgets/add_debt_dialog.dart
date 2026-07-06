import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../views/merchant/customer_management.dart';

void showAddDebtDialog() {
  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add_shopping_cart_rounded, size: 60, color: Color(0xFF07477E)),
              const SizedBox(height: 15),
              const Text("إضافة دين",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text("اختر العميل من قائمة العملاء لتسجيل الدين",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: () {
                  Get.back();
                  Get.to(() => const CustomerManagementScreen());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF07477E),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("اختر عميل", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => Get.back(),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 45),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("إلغاء"),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
