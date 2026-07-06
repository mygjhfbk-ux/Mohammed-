import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/merchant_controller/transactions_controller.dart';

void showPaymentDialog(dynamic customer, {dynamic transaction}) {
  final controller   = Get.find<TransactionsController>();
  final amountCtrl   = TextEditingController(text: transaction?['amount']?.toString() ?? "");
  final noteCtrl     = TextEditingController(text: transaction?['note'] ?? "");
  const primaryColor = Color(0xFF07477E);

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
              Text(
                transaction == null ? "تسجيل قبض مبلغ" : "تعديل عملية السداد",
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: "المبلغ المستلم",
                  prefixIcon: const Icon(Icons.monetization_on_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: noteCtrl,
                decoration: InputDecoration(
                  labelText: "ملاحظة (اختياري)",
                  prefixIcon: const Icon(Icons.notes),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 25),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text("إلغاء"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final amount = double.tryParse(amountCtrl.text);
                        if (amount == null || amount <= 0) {
                          Get.snackbar("تنبيه", "يرجى إدخال مبلغ صحيح",
                              backgroundColor: Colors.orange, colorText: Colors.white);
                          return;
                        }
                        final requestId = customer['id']?.toString() ?? "";
                        if (transaction == null) {
                          controller.savePayment(
                              requestId: requestId, amount: amount, note: noteCtrl.text);
                        } else {
                          controller.updatePayment(
                              transactionId: transaction['id'].toString(),
                              amount: amount,
                              note: noteCtrl.text,
                              requestId: requestId);
                        }
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text("تأكيد", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
