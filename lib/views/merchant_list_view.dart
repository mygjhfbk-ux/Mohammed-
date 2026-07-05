import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/merchants_controller.dart';

class MerchantListView extends StatelessWidget {
  MerchantListView({super.key});
  final MerchantsController ctrl = Get.put(MerchantsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('التجار')),
      body: Obx(() {
        if (ctrl.isLoading.value) return Center(child: CircularProgressIndicator());
        if (ctrl.merchants.isEmpty) return Center(child: Text('لا توجد بيانات'));
        return ListView.builder(
          itemCount: ctrl.merchants.length,
          itemBuilder: (context, idx) {
            final m = ctrl.merchants[idx];
            final profile = m['profile'] ?? {};
            return ListTile(
              title: Text(profile['business_name'] ?? m['merchant_name'] ?? 'غير معروف'),
              subtitle: Text(profile['phone'] ?? ''),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => ctrl.deleteMerchant(m['id']),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final phoneCtrl = TextEditingController();
          final nameCtrl = TextEditingController();
          final businessCtrl = TextEditingController();
          await Get.defaultDialog(
            title: 'إضافة تاجر',
            content: Column(
              children: [
                TextField(controller: nameCtrl, decoration: InputDecoration(labelText: 'الاسم')),
                TextField(controller: phoneCtrl, decoration: InputDecoration(labelText: 'الهاتف')),
                TextField(controller: businessCtrl, decoration: InputDecoration(labelText: 'اسم النشاط')),
              ],
            ),
            confirm: ElevatedButton(
              onPressed: () async {
                await ctrl.createMerchant(phone: phoneCtrl.text.trim(), name: nameCtrl.text.trim(), businessName: businessCtrl.text.trim());
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
