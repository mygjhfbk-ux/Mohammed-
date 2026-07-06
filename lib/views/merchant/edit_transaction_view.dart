import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/merchant_controller/transactions_controller.dart';
import '../../widgets/build_text_field.dart';

class EditTransactionView extends StatefulWidget {
  const EditTransactionView({super.key});

  @override
  State<EditTransactionView> createState() => _EditTransactionViewState();
}

class _EditTransactionViewState extends State<EditTransactionView> {
  final controller = Get.find<TransactionsController>();
  final Color primaryColor = const Color(0xFF07477E);

  @override
  void initState() {
    super.initState();
    final tx = Get.arguments;
    if (tx != null) {
      controller.fetchTransactionDetails(tx['id'].toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final tx   = Get.arguments ?? {};
    final isDebt = tx['type'] == 'debt' || tx['type'] == 'purchase';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          isDebt ? "تعديل فاتورة دين" : "تعديل عملية سداد",
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        leading: BackButton(color: primaryColor),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Obx(() {
          if (controller.isLoading.value) {
            return Center(child: CircularProgressIndicator(color: primaryColor));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      Icon(isDebt ? Icons.receipt_long : Icons.payments_outlined,
                          color: primaryColor),
                      const SizedBox(width: 12),
                      Text(
                        isDebt ? "فاتورة دين" : "عملية سداد",
                        style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                BuildTextField(
                  controller: controller.amountController,
                  hint: "المبلغ",
                  icon: Icons.monetization_on_outlined,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 15),
                BuildTextField(
                  controller: controller.descriptionController,
                  hint: "البيان / الملاحظات",
                  icon: Icons.description_outlined,
                ),
                if (isDebt) ...[
                  const SizedBox(height: 25),
                  const Text("الأصناف:",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  Obx(() => Column(
                    children: [
                      for (int i = 0; i < controller.editingItems.length; i++)
                        _editItemRow(i),
                    ],
                  )),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () => controller.editingItems
                        .add({"name": "", "qty": 1.0, "price": 0.0}),
                    icon: const Icon(Icons.add),
                    label: const Text("إضافة صنف"),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: primaryColor),
                      minimumSize: const Size(double.infinity, 45),
                    ),
                  ),
                ],
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: controller.submitUpdate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                  child: Obx(() => controller.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("حفظ التعديلات",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold))),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _editItemRow(int index) {
    final item = controller.editingItems[index];
    final nameCtrl  = TextEditingController(text: item['name']?.toString() ?? "");
    final qtyCtrl   = TextEditingController(text: item['qty']?.toString() ?? "1");
    final priceCtrl = TextEditingController(text: item['price']?.toString() ?? "0");

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextField(
              controller: nameCtrl,
              onChanged: (v) {
                controller.editingItems[index]['name'] = v;
                controller.editingItems.refresh();
              },
              decoration: InputDecoration(
                hintText: "الصنف",
                contentPadding: const EdgeInsets.all(10),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            flex: 1,
            child: TextField(
              controller: qtyCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.center,
              onChanged: (v) {
                controller.editingItems[index]['qty'] = double.tryParse(v) ?? 1.0;
                controller.editingItems.refresh();
                controller.calculateTotalFromItems();
              },
              decoration: InputDecoration(
                hintText: "كمية",
                contentPadding: const EdgeInsets.all(10),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            flex: 1,
            child: TextField(
              controller: priceCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.center,
              onChanged: (v) {
                controller.editingItems[index]['price'] = double.tryParse(v) ?? 0.0;
                controller.editingItems.refresh();
                controller.calculateTotalFromItems();
              },
              decoration: InputDecoration(
                hintText: "سعر",
                contentPadding: const EdgeInsets.all(10),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline,
                color: Colors.redAccent, size: 20),
            onPressed: () {
              controller.editingItems.removeAt(index);
              controller.calculateTotalFromItems();
            },
          ),
        ],
      ),
    );
  }
}
