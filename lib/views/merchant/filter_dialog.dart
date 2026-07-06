import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/merchant_controller/merchant_customers_controller.dart';

class FilterDialog extends StatelessWidget {
  final controller = Get.find<MerchantCustomersController>();
  final Color primaryColor = const Color(0xFF07477E);

  FilterDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("تصفية العملاء",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor)),
              const SizedBox(height: 20),
              _filterOption("الكل", "all"),
              _filterOption("النشطون فقط", "active"),
              _filterOption("الموقوفون فقط", "inactive"),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  minimumSize: const Size(double.infinity, 45),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("تطبيق", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterOption(String title, String value) {
    return Obx(() => ListTile(
      title: Text(title),
      trailing: controller.activeFilter.value == value
          ? Icon(Icons.check_circle, color: primaryColor)
          : const Icon(Icons.circle_outlined, color: Colors.grey),
      onTap: () {
        controller.activeFilter.value = value;
        controller.applyFilter();
      },
    ));
  }
}
