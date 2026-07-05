import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/customers_controller.dart';

class EditCustomerView extends StatelessWidget {
  EditCustomerView({super.key, required this.customer});
  final Map<String, dynamic> customer;
  final CustomersController ctrl = Get.find();
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final profile = customer['profile'] ?? {};
    nameCtrl.text = profile['name'] ?? '';
    phoneCtrl.text = profile['phone'] ?? '';

    return Scaffold(
      appBar: AppBar(title: Text('تعديل عميل')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: nameCtrl, decoration: InputDecoration(labelText: 'الاسم')),
            TextField(controller: phoneCtrl, decoration: InputDecoration(labelText: 'الهاتف')),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                await ctrl.updateCustomer(customer['id'], {'accepted': true});
                Get.back();
              },
              child: Text('حفظ'),
            )
          ],
        ),
      ),
    );
  }
}
