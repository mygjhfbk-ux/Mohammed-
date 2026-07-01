import 'package:app_merchant_customer/widgets/build_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/merchant_controller/transactions_controller.dart';

/// واجهة اضافة سداد
void showPaymentDialog(Map customer , {Map? transaction}) {
  final  controller = Get.find<TransactionsController>();
  bool isEdit = transaction     != null;
  if (isEdit) {
    controller.amountController.text = transaction['amount'].toString();
    controller.descriptionController.text = transaction['note'] ?? "";
  } else {
    controller.amountController.clear();
    controller.descriptionController.clear();
  }
  const Color primaryColor = Color(0xFF07477E);
  Get.dialog(
      Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          elevation: 10,
          child: Directionality(
              textDirection: TextDirection.rtl,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // رأس الحوار
                        Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isEdit ? Colors.orange.withOpacity(0.1) : primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child:  Icon(isEdit ? Icons.edit_note_rounded : Icons.account_balance_wallet_rounded,
                          color: isEdit ? Colors.orange[800] : primaryColor,
                          size: 40,),
                      ),
                        const SizedBox(height: 15),
                        Text(
                          isEdit
                              ? "تعديل دفعة سداد"
                              : "قبض دفعة من ${customer['customer_name'] ?? customer['name']}",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isEdit ? Colors.orange[900] : primaryColor
                          ),
                        ),
                        const SizedBox(height: 8),
                        // عرض الدين الحالي بشكل واضح
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "الدين المتبقي: ${customer['total_debt']} ريال",
                            style: TextStyle(color: Colors.red[700], fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 25),
                        // حقل إدخال المبلغ
                        BuildTextField(
                          hint: "المبلغ المدفوع ",
                          controller:  controller.amountController,
                          icon: Icons.money,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          textAlign: TextAlign.center,

                        ),
                        const SizedBox(height: 15),
                        // حقل البيان (مهم جداً للمحاسبة)
                        BuildTextField(
                          hint: "بيان السداد (اختياري)",
                          controller:  controller.descriptionController,
                          icon: Icons.description_outlined,
                        ),
                        const SizedBox(height: 15),
                        // طريقة الدفع
                        DropdownButtonFormField<String>(
                          value: "نقد",
                          decoration: InputDecoration(
                            labelText: "طريقة الاستلام",
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          items: ["نقد", "تحويل بنكي", "شبكة"]
                              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                              .toList(),
                          onChanged: (val) {
                            // يمكنك حفظ طريقة الدفع في متغير داخل الكنترولر إذا لزم الأمر
                          },
                        ),
                        const SizedBox(height: 30),
                        // أزرار التحكم
                        // Obx(() => Row(
                        //   children: [
                        //     Expanded(
                        //       child: ElevatedButton(
                        //         style: ElevatedButton.styleFrom(
                        //           backgroundColor: Colors.green[700],
                        //           padding: const EdgeInsets.symmetric(vertical: 15),
                        //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        //           elevation: 2,
                        //         ),
                        //         onPressed: controller.isLoading.value
                        //             ? null
                        //             : () => controller.savePayment(requestId: customer['Request-id']),
                        //         child: controller.isLoading.value
                        //             ? const SizedBox(height: 20, width: 20,
                        //             child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        //             : const Text("تأكيد القبض",
                        //             style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        //       ),
                        //     ),
                        //     const SizedBox(width: 12),
                        //     Expanded(
                        //       child: OutlinedButton(
                        //         style: OutlinedButton.styleFrom(
                        //           padding: const EdgeInsets.symmetric(vertical: 15),
                        //           side: BorderSide(color: Colors.grey[400]!),
                        //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        //         ),
                        //         onPressed: () => Get.back(),
                        //         child: Text("إلغاء",
                        //             style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                        //       ),
                        //     ),
                        //   ],
                        // )),
                        // const SizedBox(height: 10),
                        Obx(() => Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isEdit ? Colors.orange[700] : Colors.green[700],
                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                  elevation: 2,
                                ),
                                onPressed: controller.isLoading.value
                                    ? null
                                    : () {
                                  if (isEdit) {
                                    // استدعاء دالة التعديل في الكنترولر
                                    controller.updatePayment(
                                      transactionId: int.parse(transaction['id'].toString()),
                                    );
                                  } else {
                                    // استدعاء دالة الحفظ الجديدة
                                    controller.savePayment(
                                      requestId: customer['Request-id'],
                                    );
                                  }
                                },
                                child: controller.isLoading.value
                                    ? const SizedBox(height: 20, width: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                    : Text(
                                    isEdit ? "حفظ التعديلات" : "تأكيد القبض",
                                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                  side: BorderSide(color: Colors.grey[400]!),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                ),
                                onPressed: () => Get.back(),
                                child: Text("إلغاء",
                                    style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                              ),
                            ),
                          ],
                        )),
                        const SizedBox(height: 10),
                      ],
                  ),
                ),
              ),
          ),
      ),
    barrierDismissible: false,
  );
}
