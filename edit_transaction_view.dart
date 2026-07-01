import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/merchant_controller/transactions_controller.dart';
import '../../widgets/build_text_field.dart';

/// واجهة اضافة عملية
class EditDetailedDebtView extends StatefulWidget {
  final int transactionId;

  const EditDetailedDebtView({super.key, required this.transactionId});

  @override
  State<EditDetailedDebtView> createState() => _EditDetailedDebtViewState();
}

class _EditDetailedDebtViewState extends State<EditDetailedDebtView> {
  final  editController = Get.find<TransactionsController>();
  final Color primaryColor = const Color(0xFF1A4D7E); // لون تطبيقك الأساسي

  @override
  void initState() {
    super.initState();
    editController.fetchTransactionDetails(widget.transactionId);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FB),
        appBar: AppBar(
          title: const Text("تعديل دين تفصيلي", style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0.5,
          leading: BackButton(),
        ),
        body: Obx(() {
          if (editController.isLoading.value) {
            return Center(child: CircularProgressIndicator(color: primaryColor));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // حقل الوصف
                _buildSectionTitle("بيانات العملية العامة"),
                const SizedBox(height: 10),
                _buildCustomTextField(
                  controller: editController.descriptionController,
                  label: "وصف العملية",
                  icon: Icons.description_outlined,
                ),

                const SizedBox(height: 25),

                // قسم الأصناف
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionTitle("تفاصيل الأصناف"),
                    TextButton.icon(
                      onPressed: () => _showEditItemDialog(-1, null),
                      icon: const Icon(Icons.add_circle_outline, size: 20),
                      label: const Text("إضافة صنف"),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildDetailedEditSection(),

                const SizedBox(height: 30),

                // ملخص المبلغ
                _buildTotalSummary(),
              ],
            ),
          );
        }),
        bottomNavigationBar: _buildBottomAction(),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 16));
  }

  Widget _buildCustomTextField({required TextEditingController controller, required String label, required IconData icon}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: BuildTextField(
        controller: controller,
        icon: icon,
        hint: label,
      ),
    );
  }

  Widget _buildDetailedEditSection() {
    return Obx(() {
      if (editController.editingItems.isEmpty) {
        return _buildEmptyState();
      }
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: editController.editingItems.length,
        itemBuilder: (context, index) {
          var item = editController.editingItems[index];
          return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("الكمية: ${item['qty']}  |  السعر: ${item['price']} ر.ي",
                    style: TextStyle(color: Colors.grey.shade600)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_note, color: Colors.blue),
                      onPressed: () => _showEditItemDialog(index, item),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () {
                        editController.editingItems.removeAt(index);
                        editController.calculateTotalFromItems();
                      },
                    ),
                  ],
                ),
              ),
          );
        },
      );
    });
  }

  Widget _buildTotalSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: primaryColor.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("إجمالي :", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Expanded(
            child: Obx(() => Text(
              "${editController.amount.value} ر.ي",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(30),
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          Icon(Icons.shopping_basket_outlined, size: 50, color: Colors.grey.shade300),
          const SizedBox(height: 10),
          const Text("لا توجد أصناف حالياً", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFEEEEEE)))),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          minimumSize: const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () => editController.submitUpdate(),
        child: const Text("حفظ التعديلات النهائية", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  void _showEditItemDialog(int index, Map? item) {
    final nameController = TextEditingController(text: item != null ? item['name'] : "");
    final qtyController = TextEditingController(text: item != null ? item['qty'].toString() : "1");
    final priceController = TextEditingController(text: item != null ? item['price'].toString() : "");

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(25),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(item == null ? "إضافة صنف جديد" : "تعديل بيانات الصنف",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor)),
              const SizedBox(height: 20),
              TextField(controller: nameController, decoration: const InputDecoration(labelText: "اسم السلعة", border: OutlineInputBorder())),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(child: BuildTextField(
                        controller: qtyController,
                        icon: Icons.description,
                        hint: "الكمية",
                          keyboardType: TextInputType.number
                      ),),
                  const SizedBox(width: 15),
                  Expanded(child: BuildTextField(
                      controller: priceController,
                      icon: Icons.money,
                      hint: "السعر",
                      keyboardType: TextInputType.number
                  ),),
                ],
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: primaryColor, minimumSize: const Size(double.infinity, 50)),
                onPressed: () {
                  double q = double.tryParse(qtyController.text) ?? 1.0;
                  double p = double.tryParse(priceController.text) ?? 0.0;
                  if (index == -1) {
                    editController.editingItems.add({"name": nameController.text, "qty": q, "price": p});
                  } else {
                    editController.editingItems[index] = {"name": nameController.text, "qty": q, "price": p};
                  }
                  editController.calculateTotalFromItems();
                  Get.back();
                },
                child: const Text("تم", style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

