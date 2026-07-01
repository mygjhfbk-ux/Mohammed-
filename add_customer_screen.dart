import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/merchant_controller/add_customer_controller.dart';
import 'package:app_merchant_customer/widgets/build_text_field.dart';

/// واجهة اضافة طلب لعميل
class AddCustomerScreen extends GetView<AddCustomerController> {
  const AddCustomerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF0D47A1);
    controller.clearFields();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "إضافة عميل جديد",
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // قسم اختيار نوع الحساب باستخدام Obx ليكون تفاعلياً
            Obx(() => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Checkbox(
                    value: controller.hasAccount.value,
                    activeColor: primaryColor,
                    onChanged: (value) => controller.hasAccount.value = value!,
                  ),
                  Text(
                    "هل يمتلك حساب على منصة يمن ديون؟",
                    style: TextStyle(color: primaryColor, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            )),

            const SizedBox(height: 25),

            BuildTextField(
              icon: Icons.person_outline,
              hint: "اسم العميل الكامل *",
              controller: controller.nameController,
            ),

            const SizedBox(height: 15),

            // عرض حقل الهاتف فقط إذا كان العميل يمتلك حساباً
            Obx(() => controller.hasAccount.value
                ? Column(
              children: [
                Directionality(
                  textDirection: TextDirection.rtl, // لضمان تنسيق الرقم الدولي
                  child: BuildTextField(
                    icon: Icons.phone_android,
                    textAlign: TextAlign.left,
                    hint: "رقم الهاتف (بدون الصفر)",
                    controller: controller.phoneController,
                    keyboardType: TextInputType.phone,
                    suffixIcon: Container(
                      width: 85,
                      padding: const EdgeInsets.only(right: 5 , left: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Text("967+", style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: Image.asset(
                                "assets/images/logo.jpg",
                                width: 30, height: 30,
                                errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.flag, size: 20, color: Colors.grey),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
              ],
            )
                : const SizedBox.shrink(),
            ),

            BuildTextField(
              icon: Icons.map_outlined,
              hint: "عنوان العميل (اختياري)",
              controller: controller.addressController,
            ),

            const SizedBox(height: 15),

            BuildTextField(
              icon: Icons. monetization_on_outlined,
              hint: "سقف الدين المسموح (Limit) *",
              controller: controller.limitController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),

            const SizedBox(height: 40),

            // زر الإرسال التفاعلي
            Obx(() => SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () => _validateAndSubmit(controller),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: controller.isLoading.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  "إرسال طلب مديونية",
                  style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            )),

            const SizedBox(height: 20),
            const Center(
              child: Text(
                "* لن يتم تفعيل المديونية إلا بعد موافقة العميل",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _validateAndSubmit(AddCustomerController controller) {
    if (controller.nameController.text.trim().isEmpty) {
      Get.snackbar("تنبيه", "يرجى إدخال اسم العميل",
          snackPosition: SnackPosition.TOP, backgroundColor: Colors.orange.withOpacity(0.8), colorText: Colors.white);
      return;
    }

    if (controller.hasAccount.value && controller.phoneController.text.length < 9) {
      Get.snackbar("تنبيه", "يرجى إدخال رقم هاتف صحيح",
          snackPosition: SnackPosition.TOP, backgroundColor: Colors.orange.withOpacity(0.8), colorText: Colors.white);
      return;
    }

    if (double.tryParse(controller.limitController.text) == null) {
      Get.snackbar("تنبيه", "يرجى إدخال رقم صحيح لسقف الدين",
          snackPosition: SnackPosition.TOP, backgroundColor: Colors.orange.withOpacity(0.8), colorText: Colors.white);
      return;
    }

    controller.sendAddRequest();
  }
}
