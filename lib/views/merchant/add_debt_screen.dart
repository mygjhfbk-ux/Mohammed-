import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/merchant_controller/transactions_controller.dart';
import '../../widgets/build_text_field.dart';

class AddDebtScreen extends StatelessWidget {
  final String? requestId;
  final String? merchantId;
  final String? customerName;

  const AddDebtScreen({super.key, this.requestId, this.merchantId, this.customerName});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TransactionsController>();
    const Color primaryColor = Color(0xFF07477E);
    controller.resetForm();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text("تسجيل دين جديد",
            style: TextStyle(color: primaryColor, fontSize: 18, fontWeight: FontWeight.bold)),
        leading: const BackButton(color: primaryColor),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: primaryColor.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.person, color: primaryColor),
                      const SizedBox(width: 10),
                      Text(customerName ?? "عميل",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor)),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Obx(() => Column(
                          children: [
                            for (int i = 0; i < controller.items.length; i++)
                              _itemRow(controller, i),
                          ],
                        )),
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed: controller.addItem,
                          icon: const Icon(Icons.add),
                          label: const Text("إضافة صنف"),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: primaryColor),
                            minimumSize: const Size(double.infinity, 45),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(height: 20),
                        BuildTextField(
                          controller: controller.descriptionController,
                          icon: Icons.description,
                          hint: "ملاحظات / بيان الدين",
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Obx(() => Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("إجمالي الفاتورة:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text("${controller.totalAmount.value} ريال",
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryColor)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : () => controller.saveDebt(requestId: requestId ?? ""),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: controller.isLoading.value
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("حفظ الفاتورة",
                              style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              )),
            ),
            Obx(() => controller.isLoading.value
                ? Container(
                    color: Colors.white.withOpacity(0.7),
                    child: const Center(child: CircularProgressIndicator(color: primaryColor)))
                : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }

  Widget _itemRow(TransactionsController controller, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(flex: 3, child: _smallInput("اسم السلعة", (v) => controller.updateItem(index, name: v))),
          const SizedBox(width: 5),
          Expanded(flex: 1, child: _smallInput("كمية", (v) => controller.updateItem(index, qty: v),
              keyboard: const TextInputType.numberWithOptions(decimal: true))),
          const SizedBox(width: 5),
          Expanded(flex: 1, child: _smallInput("سعر", (v) => controller.updateItem(index, price: v),
              keyboard: const TextInputType.numberWithOptions(decimal: true))),
          const SizedBox(width: 5),
          Expanded(
            flex: 1,
            child: Obx(() => Center(
              child: Text("${controller.items[index]['total']}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF07477E))),
            )),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 20),
            onPressed: () => controller.removeItem(index),
          ),
        ],
      ),
    );
  }

  Widget _smallInput(String hint, Function(String) onChanged,
      {TextInputType keyboard = TextInputType.text}) {
    return TextField(
      onChanged: onChanged,
      keyboardType: keyboard,
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      ),
    );
  }
}
