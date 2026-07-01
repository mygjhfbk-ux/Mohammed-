import 'package:app_merchant_customer/views/merchant/add_debt_screen.dart';
import 'package:app_merchant_customer/views/merchant/edit_customer_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../controllers/merchant_controller/merchant_customers_controller.dart';
import '../../controllers/merchant_controller/report_controller.dart';
import '../reports/debt_pdf_generator.dart';
import 'filter_dialog.dart';
import '../reports/merchant_general_reports_view.dart';
import 'add_customer_screen.dart';
import 'link_customer.dart';
import 'payment_dialog.dart';

/// واجهة ادارة العملاء
class CustomerManagementScreen extends StatefulWidget {
  const CustomerManagementScreen({super.key});

  @override
  State<CustomerManagementScreen> createState() => _CustomerManagementScreenState();
}

class _CustomerManagementScreenState extends State<CustomerManagementScreen> {
  final controller = Get.find<MerchantCustomersController>();
  final controllers = Get.find<ReportController>();
  final Color primaryColor = const Color(0xFF07477E);
  final box = GetStorage();

  // دالة موحدة لتحديث البيانات لضمان المزامنة
  void refreshData() => controller.fetchCustomer();

  @override
  Widget build(BuildContext context) {
    controller.fetchCustomer();
    final int merchantId = box.read("Profile-id") ?? 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text("إدارة العملاء",
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: primaryColor),
            onPressed: () => Get.back()),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: primaryColor),
            onPressed: () => refreshData(),
          )
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            _buildTopActions(),
            _buildSearchBar(),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(child: CircularProgressIndicator(color: primaryColor));
                }
                if (controller.customerList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_search, size: 60, color: Colors.grey[300]),
                        const Text("لا يوجد عملاء مطابقين"),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => refreshData(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: controller.customerList.length,
                    itemBuilder: (context, index) {
                      var customer = controller.customerList[index];
                      return _customerCard(customer, merchantId);
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _customerCard(dynamic customer, int merchantId) {
    String name = customer['Customer-Name']?.toString() ?? customer['name']?.toString() ?? "بدون اسم";
    String debt = customer['total_debt']?.toString() ?? "0.0";
    String limit = customer['account_limit']?.toString() ?? "0.0";
    int requestId = int.tryParse(customer['Request-id']?.toString() ?? "0") ?? 0;
    var isLocal = (customer['status'] == 0);

    return Card(
      elevation: 3,
      shadowColor: Colors.black12,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: primaryColor.withOpacity(0.1),
                  child: Text(name[0], style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.verified, color: isLocal ? Colors.black26 : Colors.blue[700], size: 20),
                          SizedBox(width: 5,),
                          Text(name, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: primaryColor)),
                        ],
                      ),
                      Text("رقم: ${customer['phone'] ?? "0"}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                _statusBadge(int.tryParse(customer['is_active']?.toString() ?? "0") ?? 0),
                const SizedBox(width: 10),
                if ((customer['phone'] ?? "0") == "0")
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _actionIcon(Icons.connecting_airports, "ربط", () async {
                        box.write("isLocal", true);
                        showLinkCustomerDialog(customer);
                        // var result = await Get.to(() => EditCustomerView(), arguments: customer);
                        // if (result == true) refreshData();
                      }),
                    ),
                  ),
              ],
            ),
            const Divider(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _dataItem("السقف", limit, Colors.blueGrey),
                _dataItem("إجمالي الدين", debt, Colors.redAccent),
                _dataItem("اليوم", customer['today_debt']?.toString() ?? "0.0", Colors.orange),
              ],
            ),
            const SizedBox(height: 15),
            // الأزرار التفاعلية
            Container(
              padding: const EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _actionIcon(Icons.add_shopping_cart, "دين", () async {
                    var result = await Get.to(() => AddDebtScreen(
                      customerName: name,
                      merchantId: merchantId,
                      requestId: requestId,
                    ));
                    if (result == true) refreshData();
                  }),
                  _actionIcon(Icons.payments_outlined, "قبض", () {
                    showPaymentDialog(customer);
                    // ملاحظة: الـ Dialog يحتاج لاستدعاء refreshData داخله عند النجاح
                  }),
                  _actionIcon(Icons.history_edu, "كشف", () {
                    Get.to(() => MerchantGeneralReportsView(no: 1,), arguments: customer);
                  }),
                  _actionIcon(Icons.edit_note, "تعديل", () async {
                    box.write("isLocal", false);
                    var result = await Get.to(() => EditCustomerView(), arguments: customer);
                    if (result == true) refreshData();
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dataItem(String title, String value, Color color) {
    return Column(
      children: [
        Text(title, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: color)),
      ],
    );
  }

  Widget _actionIcon(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: primaryColor, size: 22),
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTopActions() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () async {
                await Get.to(() => AddCustomerScreen());
                refreshData();
              },
              icon: const Icon(Icons.person_add, color: Colors.white),
              label: const Text("عميل جديد", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // في شاشة قائمة العملاء الخاصة بالتاجر

          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                controllers.printMerchantDebtsReport(box.read('Profile-id'));
              },
              icon: Icon(Icons.analytics_outlined, color: primaryColor),
              label: Text("التقارير", style: TextStyle(color: primaryColor)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                side: BorderSide(color: primaryColor),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// دالة عرض الحالة (نشط/موقف)
  Widget _statusBadge(int status) {
    bool isActive = (status == 1);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: isActive ? Colors.green[50] : Colors.red[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isActive ? Colors.green : Colors.red, width: 0.5)
      ),
      child: Row(
        children: [
          Text(isActive ? "نشط" : "موقف",
              style: TextStyle(color: isActive ? Colors.green[700] : Colors.red[700], fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Row(
        children: [
          // حقل البحث
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: TextField(
                controller: controller.searchedQuery,
                onChanged: (value) => controller.updateSearch(value),
                decoration: const InputDecoration(
                  hintText: "ابحث بالاسم أو رقم الهاتف...",
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // زر الفلترة
          GestureDetector(
            onTap: () => Get.dialog(FilterDialog()) ,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: primaryColor.withOpacity(0.2)),
              ),
              child: Icon(Icons.filter_list_rounded, color: primaryColor),
            ),
          ),
        ],
      ),
    );
  }

}
