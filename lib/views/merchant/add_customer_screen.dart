import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/merchant_controller/add_customer_controller.dart';
import '../../widgets/build_text_field.dart';

class AddCustomerScreen extends GetView<AddCustomerController> {
  const AddCustomerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF0D47A1);
    controller.clearFields();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text("إضافة عميل جديد",
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
        leading: const BackButton(color: primaryColor),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Obx(() => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(15)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Checkbox(
                      value: controller.hasAccount.value,
                      activeColor: primaryColor,
                      onChanged: (v) => controller.hasAccount.value = v!,
                    ),
                    const Text("هل يمتلك حساب على منصة ديوني؟",
                        style: TextStyle(
                            color: primaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500)),
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
              Obx(() => controller.hasAccount.value
                  ? Column(
                      children: [
                        BuildTextField(
                          icon: Icons.phone_android,
                          hint: "رقم الهاتف",
                          controller: controller.phoneController,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 15),
                      ],
                    )
                  : const SizedBox.shrink()),
              BuildTextField(
                icon: Icons.map_outlined,
                hint: "عنوان العميل (اختياري)",
                controller: controller.addressController,
              ),
              const SizedBox(height: 15),
              BuildTextField(
                icon: Icons.monetization_on_outlined,
                hint: "سقف الدين المسموح *",
                controller: controller.limitController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 40),
              Obx(() => SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value ? null : _validateAndSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("إرسال طلب مديونية",
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                ),
              )),
              const SizedBox(height: 20),
              const Center(
                child: Text("* لن يتم تفعيل المديونية إلا بعد موافقة العميل",
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _validateAndSubmit() {
    if (controller.nameController.text.trim().isEmpty) {
      Get.snackbar("تنبيه", "يرجى إدخال اسم العميل",
          backgroundColor: Colors.orange.withOpacity(0.8), colorText: Colors.white);
      return;
    }
    if (double.tryParse(controller.limitController.text) == null) {
      Get.snackbar("تنبيه", "يرجى إدخال رقم صحيح لسقف الدين",
          backgroundColor: Colors.orange.withOpacity(0.8), colorText: Colors.white);
      return;
    }
    controller.sendAddRequest();
  }
}
