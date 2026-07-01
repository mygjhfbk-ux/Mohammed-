import 'package:app_merchant_customer/widgets/build_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/merchant_controller/add_customer_controller.dart';

void showLinkCustomerDialog(Map customerData) {
  final  controller = Get.find<AddCustomerController>();
  final int requestId = customerData["Request-id"];
  TextEditingController nameController = TextEditingController(text: customerData["name"]);
  TextEditingController phoneController = TextEditingController(text: customerData["phone"]);


  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // الرأس (Header)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "ربط العميل",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A4D7E),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close, color: Colors.grey),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 15),

              // حقل اسم العميل (قراءة فقط غالباً)
              BuildTextField(
                hint: 'رقم الهاتف',
                icon:Icons.contact_phone ,
                controller: nameController,
                onChanged: (value) => controller.nameController.text = value),


              const SizedBox(height: 20),

              // حقل رقم الهاتف مع اختيار الدولة
              BuildTextField(
                  hint: 'رقم الهاتف',
                icon:Icons.contact_phone ,
                controller: phoneController,
                  onChanged: (value) => controller.phoneController.text = value),


              const SizedBox(height: 30),

              // أزرار التحكم
              Row(
                children: [
                  // زر الربط
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        controller.updateCustomerRequest(requestId);
                        // استدعاء دالة الربط من الكنترولر
                        // controller.linkCustomer(customerData['Request-id'], phoneNumber);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF005682),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text("ربط", style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 15),
                  // زر الإلغاء
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text("إلغاء", style: TextStyle(color: Colors.grey, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
