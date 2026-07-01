import 'package:app_merchant_customer/widgets/build_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/merchant_controller/transactions_controller.dart';

/// واجهة اضافة دين
class AddDebtScreen extends GetView<TransactionsController> {
  final int? requestId;
  final int? merchantId;
  final String? customerName;

  const AddDebtScreen({
    super.key,
    this.requestId,
    this.merchantId,
    this.customerName,
  });

  // استدعاء الكنترولر الموحد
  final Color primaryColor = const Color(0xFF07477E);

  @override
  Widget build(BuildContext context) {
    controller.fetchCustomers();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text("تسجيل دين جديد",
            style: TextStyle(color: primaryColor, fontSize: 18, fontWeight: FontWeight.bold)),
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: primaryColor),
            onPressed: () => Get.back()),
      ),
      body: Stack(
        children: [
          Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              children: [
                // 1. قسم اختيار العميل
                _buildCustomerSelector(),

                const SizedBox(height: 5),

                // 2. خيارات النوع: مبلغ إجمالي أو تفصيلي
                Obx(() => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      // Expanded(child: _radioOption("مبلغ إجمالي", false)),
                      Expanded(child: _radioOption("قائمة أصناف", true)),
                    ],
                  ),
                )),

                const SizedBox(height: 5),

                // 3. عرض الواجهة بناءً على الخيار المختار
                Expanded(
                  child: Obx(() => controller.isDetailed.value
                      ? _buildDetailedView()
                      : _buildNormalView()),
                ),

                // شريط الحفظ والإجمالي
                _buildBottomBar(),
              ],
            ),
          ),

          // مؤشر التحميل
          Obx(() => controller.isLoading.value
              ? Container(
            color: Colors.white.withOpacity(0.7),
            child: Center(child: CircularProgressIndicator(color: primaryColor)),
          )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildCustomerSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: primaryColor.withOpacity(0.2))
      ),
      child: requestId != null
          ? ListTile( // في حال تم تمرير عميل محدد مسبقاً
        contentPadding: EdgeInsets.zero,
        title: Text(customerName ?? "", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor)),
        leading: Icon(Icons.person, color: primaryColor),
      )
          : Obx(() => DropdownButtonHideUnderline(
        child: DropdownButton<int>( // نستخدم int هنا
          isExpanded: true,
          hint: const Text("اختر العميل من القائمة"),
          value: controller.selectedCustomerId.value, // نربطه بالـ ID
          items: controller.customers.map((customer) {
            return DropdownMenuItem<int>(
              value: customer['Request-id'], // القيمة هنا هي الـ ID
              child: Text(customer['Customer-Name'] ?? ""),
            );
          }).toList(),
          onChanged: (val) {
            controller.selectedCustomerId.value = val; // تحديث الـ ID المختار
          },
        ),
      ))
      ,
    );
  }

  Widget _buildNormalView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 10),
          BuildTextField(
            controller: controller.amountController,
              icon: Icons.monetization_on,
              hint: "المبلغ المالي",
          ),
          const SizedBox(height: 15),
          BuildTextField(
            controller: controller.descriptionController,
            icon: Icons.description,
            hint: "ملاحظات / بيان الدين",
          ),
          const SizedBox(height: 30),
          if (!controller.isDetailed.value)
            _actionButton("تأكيد وحفظ الدين", primaryColor, onTap: () => _handleSave()),
        ],
      ),
    );
  }

  Widget _buildDetailedView() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          color: primaryColor.withOpacity(0.05),
          child: Row(
            children: const [
              Expanded(flex: 3, child: Text("الصنف", style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(flex: 1, child: Center(child: Text("الكمية", style: TextStyle(fontWeight: FontWeight.bold)))),
              Expanded(flex: 1, child: Center(child: Text("سعر", style: TextStyle(fontWeight: FontWeight.bold)))),
              Expanded(flex: 1, child: Center(child: Text("إجمالي", style: TextStyle(fontWeight: FontWeight.bold)))),
              SizedBox(width: 40),
            ],
          ),
        ),
        Expanded(
          child: Obx(() => ListView.builder(
            itemCount: controller.items.length,
            itemBuilder: (context, index) => _itemRow(index),
          )),
        ),
      ],
    );
  }

  Widget _itemRow(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        children: [
          // 1. حقل اسم الصنف
          Expanded(
            flex: 3,
            child: _smallInput(
              hint: "اسم السلعة",
              onChanged: (v) => controller.updateItem(index, name: v),
            ),
          ),
          const SizedBox(width: 5),

          // 2. حقل الكمية (الجديد)
          Expanded(
            flex: 1,
            child: _smallInput(
              hint: "كمية",
              keyboard: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (v) => controller.updateItem(index, qty: v),
            ),
          ),
          const SizedBox(width: 5),

          // 3. حقل السعر
          Expanded(
            flex: 1,
            child: _smallInput(
              hint: "سعر",
              keyboard: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (v) => controller.updateItem(index, price: v),
            ),
          ),

          // 4. عرض الإجمالي لهذا الصنف
          Expanded(
            flex: 1,
            child: Center(
              child: Obx(() => Text(
                "${controller.items[index]['total']}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                  fontSize: 12,
                ),
              )),
            ),
          ),

          // 5. زر الحذف
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 20),
            onPressed: () => controller.removeItem(index),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Obx(() {
      if (!controller.isDetailed.value) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30))
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("إجمالي الفاتورة:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text("${controller.totalAmount.value} ريال",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryColor)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: OutlinedButton.icon(
                  onPressed: () => controller.addItem(),
                  icon: const Icon(Icons.add),
                  label: const Text("صنف جديد"),
                  style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      side: BorderSide(color: primaryColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                  ),
                )),
                const SizedBox(width: 10),
                Expanded(child: _actionButton("حفظ الفاتورة", primaryColor, onTap: () => _handleSave())),
              ],
            )
          ],
        ),
      );
    });
  }

  void _handleSave() {
    // نأخذ الـ ID الممرر للواجهة أو المختار من القائمة
    int? finalId = requestId ?? controller.selectedCustomerId.value;

    if (finalId == null) {
      Get.snackbar("تنبيه", "يرجى تحديد العميل أولاً",
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    controller.saveDebt(requestId: finalId);
  }

  // --- راديو اوبشن ---
  Widget _radioOption(String title, bool value) {
    bool isSelected = controller.isDetailed.value == value;
    return InkWell(
      onTap: () => controller.isDetailed.value = value,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(title,
              style: TextStyle(
                  fontSize: 16,
                  color: isSelected ? Colors.white : Colors.grey[600],
                  fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }


  Widget _smallInput({String? hint, TextInputType keyboard = TextInputType.text, Function(String)? onChanged}) {
    return TextField(
      onChanged: onChanged,
      keyboardType: keyboard,
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _actionButton(String label, Color color, {VoidCallback? onTap}) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
          backgroundColor: color,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }
}
