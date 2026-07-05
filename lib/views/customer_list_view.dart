import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/customers_controller.dart';

class CustomerListView extends StatelessWidget {
  CustomerListView({super.key});
  final CustomersController ctrl = Get.put(CustomersController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('العملاء')),
      body: Obx(() {
        if (ctrl.isLoading.value) return Center(child: CircularProgressIndicator());
        if (ctrl.customers.isEmpty) return Center(child: Text('لا توجد بيانات'));
        return ListView.builder(
          itemCount: ctrl.customers.length,
          itemBuilder: (context, idx) {
            final c = ctrl.customers[idx];
            final profile = c['profile'] ?? {};
            return ListTile(
              title: Text(profile['name'] ?? 'عميل'),
              subtitle: Text(profile['phone'] ?? ''),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => ctrl.deleteCustomer(c['id']),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final phoneCtrl = TextEditingController();
          final nameCtrl = TextEditingController();
          await Get.defaultDialog(
            title: 'إضافة عميل',
            content: Column(
              children: [
                TextField(controller: nameCtrl, decoration: InputDecoration(labelText: 'الاسم')),
                TextField(controller: phoneCtrl, decoration: InputDecoration(labelText: 'الهاتف')),
              ],
            ),
            confirm: ElevatedButton(
              onPressed: () async {
                await ctrl.createCustomer(phone: phoneCtrl.text.trim(), name: nameCtrl.text.trim());
                Get.back();
              },
              child: Text('حفظ'),
            ),
            onCancel: () {},
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
