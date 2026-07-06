import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/merchant_controller/wallet_controller.dart';

void showAddWalletDialog() {
  final controller  = Get.find<WalletController>();
  final numberCtrl  = TextEditingController();
  String selectedType = "يمن كاش";
  final types = ["يمن كاش", "كريمي", "بنك كريمي", "بنك اليمن والخليج", "أخرى"];

  Get.dialog(
    StatefulBuilder(
      builder: (context, setState) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("إضافة محفظة / حساب",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF07477E))),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: InputDecoration(
                    labelText: "نوع المحفظة",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: types
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) => setState(() => selectedType = v!),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: numberCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: "رقم الحساب / المحفظة",
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
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("إلغاء"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (numberCtrl.text.isEmpty) {
                            Get.snackbar("تنبيه", "يرجى إدخال رقم الحساب");
                            return;
                          }
                          controller.addWallet(
                            type: selectedType,
                            number: numberCtrl.text.trim(),
                          );
                          Get.back();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF07477E),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("إضافة", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
