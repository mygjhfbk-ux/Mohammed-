import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/merchant_controller/merchant_customers_controller.dart';

/// هاذا الملف خاص بفلترة عرض العملاء
class FilterDialog extends GetView<MerchantCustomersController> {
  const FilterDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF07477E);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // العنوان
              Row(
                children: [
                  Icon(Icons.filter_alt_outlined, color: primaryColor),
                  const SizedBox(width: 10),
                  Text("فلترة العملاء",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor)),
                ],
              ),
              const SizedBox(height: 15),

              // قائمة خيارات الفلترة باستخدام Obx لتتبع الحالة في Controller
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _filterOption(controller, "كافة العملاء"),
                      _filterOption(controller, "نشط فقط"),
                      _filterOption(controller, "الموقفين فقط"),
                      _filterOption(controller, "الموثقين"),
                      _filterOption(controller, "الغير موثقين"),
                      _filterOption(controller, "الأكثر ديناً"),
                      _filterOption(controller, "ترتيب حسب الأبجدية"),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // أزرار التحكم
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // تنفيذ الفلترة وجلب البيانات الجديدة
                        controller.fetchCustomer();
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text("تنفيذ",
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: primaryColor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text("إلغاء",
                          style: TextStyle(color: primaryColor, fontSize: 16)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterOption(MerchantCustomersController controller, String title) {
    return Obx(() => RadioListTile<String>(
      title: Text(title, style: const TextStyle(fontSize: 15)),
      value: title,
      groupValue: controller.selectedFilter.value,
      activeColor: const Color(0xFF07477E),
      contentPadding: EdgeInsets.zero,
      onChanged: (value) {
        controller.selectedFilter.value = value!;
      },
    ));
  }
}
