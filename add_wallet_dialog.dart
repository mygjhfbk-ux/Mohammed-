import 'package:app_merchant_customer/widgets/build_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/merchant_controller/wallet_controller.dart';

/// واجهة اضافة محفظة
void showAddWalletDialog() {
  // استخدام Get.find إذا كان الـ Controller موجوداً مسبقاً، أو put إذا كانت أول مرة
  final controller = Get.find<WalletController>();

  // استخدام RxString لتحديث الواجهة داخل الدايلوج إذا لزم الأمر
  String selectedType = "كريمي";
  final numberController = TextEditingController();
  final noteController = TextEditingController();
  final Color primaryColor = const Color(0xFF07477E);

  Get.dialog(
      Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Directionality(
              textDirection: TextDirection.rtl,
              child: SingleChildScrollView( // لضمان عدم حدوث Overflow عند ظهور الكيبورد
                  child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                        // تصحيح العنوان ليتناسب مع الوظيفة
                        Text(
                        "إضافة وسيلة سداد",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        "أضف حساباتك البنكية أو محافظك ليتمكن العملاء من السداد عبرها",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 20),

                      // اختيار نوع المحفظة/البنك
                      DropdownButtonFormField<String>(
                        value: selectedType,
                        decoration: InputDecoration(
                          labelText: "نوع الحساب/المحفظة",
                          labelStyle: TextStyle(color: primaryColor),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: primaryColor, width: 2),
                          ),
                        ),
                        items: ["كريمي", "أم فلوس", "ون كاش", "جوالي", "فلوسك"]
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (val) => selectedType = val!,
                      ),
                      const SizedBox(height: 15),

                      // رقم الحساب أو الهاتف المرتبط بالمحفظة
                          BuildTextField(
                            controller: numberController,
                            icon: Icons.account_balance_wallet_outlined,
                            hint:"رقم الحساب أو الهاتف",
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.left,
                          ),

                      const SizedBox(height: 15),
                      // ملاحظات (مثل اسم صاحب الحساب)
                          BuildTextField(
                            controller: noteController,
                            icon: Icons.note_add_outlined,
                            hint:"ملاحظات ",
                          ),
                      const SizedBox(height: 25),

                      // أزرار التحكم
                      Obx(() => Row(
                        children: [
                      Expanded(
                      child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                        onPressed: controller.isLoading.value
                            ? null
                            : () {
                          if (numberController.text.isNotEmpty) {
                            controller.addWallet(
                                selectedType,
                                numberController.text,
                                noteController.text
                            );
                          } else {
                            Get.snackbar("تنبيه", "يرجى إدخال رقم الحساب");
                          }
                        },
                        child: controller.isLoading.value
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text("حفظ البيانات", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                      ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: primaryColor),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () => Get.back(),
                              child: Text("إلغاء", style: TextStyle(color: primaryColor)),
                            ),
                          ),
                        ],
                      )),
                        ],
                      ),
                  ),
              ),
          ),
      ),
    barrierDismissible: false, // منع إغلاق الدايلوج عند الضغط خارجه أثناء الحفظ
  );
}
