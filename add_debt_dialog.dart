import 'package:app_merchant_customer/widgets/build_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/merchant_controller/transactions_controller.dart';

/// واجهة اضافة دين
void showAddDebtDialog({int? requestId, String? customerName}) {
  final  dController = Get.find<TransactionsController>();

  // إعادة ضبط الحقول والخيارات عند الفتح
  dController.amountController.clear();
  dController.descriptionController.clear();
  dController.isDetailed.value = false; // نثبتها على "بسيط" في الـ Dialog السريع

  const Color primaryColor = Color(0xFF07477E);
  dController.fetchCustomers();
  Get.dialog(
    Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // العنوان
                      Row(
                        children: [
                          const Icon(Icons.add_circle_outline, color: primaryColor),
                          const SizedBox(width: 8),
                          Text(
                            customerName != null ? "إضافة دين لـ $customerName" : "إضافة دين سريع",
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor),
                          ),
                        ],
                      ),
                      const Divider(height: 30),
                      // 1. اختيار العميل (يظهر فقط إذا لم يتم تمرير عميل محدد)
                      if (requestId == null) ...[
                        const Align(
                          alignment: Alignment.centerRight,
                          child: Text("اختر العميل:", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 8),
                        Obx(() => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[400]!),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              isExpanded: true,
                              value: dController.selectedCustomerId.value,
                              hint: const Text("قائمة العملاء المرتبطين"),
                              items: dController.customers.map((c) {
                                return DropdownMenuItem<int>(
                                  value: c['Request-id'],
                                  child: Text(c['Customer-Name'] ?? ""),
                                );
                              }).toList(),
                              onChanged: (val) => dController.selectedCustomerId.value = val,
                            ),
                          ),
                        )),
                        const SizedBox(height: 15),
                      ],
                      // 2. حقل المبلغ
                      BuildTextField(
                        controller: dController.amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        icon: Icons.monetization_on,
                        hint: "المبلغ المستحق",
                      ),
                      const SizedBox(height: 15),
                      // 3. حقل التفاصيل (البيان)
                      BuildTextField(
                        controller: dController.descriptionController,
                        icon: Icons.description,
                        hint: "البيان (تفاصيل الدين)",

                      ),
                      const SizedBox(height: 25),
                      // 4. أزرار التحكم
                      Obx(() => Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: dController.isLoading.value
                                  ? null
                                  : () {
                                // تحديد الـ ID النهائي سواء الممرر أو المختار من القائمة
                                int? finalId = requestId ?? dController.selectedCustomerId.value;
                                if (finalId != null) {
                                  dController.saveDebt(requestId: finalId);
                                } else {
                                  Get.snackbar("تنبيه", "يرجى اختيار العميل أولاً", backgroundColor: Colors.orange);
                                }
                              },
                              child: dController.isLoading.value
                                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : const Text("حفظ الدين", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () => Get.back(),
                              child: const Text("إلغاء", style: TextStyle(fontSize: 16)),
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
    barrierDismissible: false,
  );
}
