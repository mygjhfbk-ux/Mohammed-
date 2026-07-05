import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/merchants_controller.dart';
import '../controllers/customers_controller.dart';

class MerchantDetailsView extends StatelessWidget {
  MerchantDetailsView({super.key, required this.merchant});
  final Map<String, dynamic> merchant;
  final MerchantsController merchantsCtrl = Get.find();
  final CustomersController customersCtrl = Get.find();

  @override
  Widget build(BuildContext context) {
    final profile = merchant['profile'] ?? {};
    return Scaffold(
      appBar: AppBar(title: Text(profile['business_name'] ?? 'تفاصيل التاجر')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الاسم: ' + (profile['name'] ?? '')),
            SizedBox(height: 8),
            Text('الهاتف: ' + (profile['phone'] ?? '')),
            SizedBox(height: 16),
            ElevatedButton(onPressed: () async {
              // show customers linked to this merchant
              await customersCtrl.fetchCustomers(merchantId: merchant['id']);
              Get.to(() => CustomerListView());
            }, child: Text('عرض العملاء')),
          ],
        ),
      ),
    );
  }
}
