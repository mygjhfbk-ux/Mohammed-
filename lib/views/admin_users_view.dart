import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/merchants_controller.dart';

class AdminUsersView extends StatelessWidget {
  AdminUsersView({super.key});
  final MerchantsController merchantsCtrl = Get.put(MerchantsController());

  @override
  Widget build(BuildContext context) {
    merchantsCtrl.fetchMerchants();
    return Scaffold(
      appBar: AppBar(title: Text('إدارة المستخدمين')),
      body: Obx(() {
        if (merchantsCtrl.isLoading.value) return Center(child: CircularProgressIndicator());
        if (merchantsCtrl.merchants.isEmpty) return Center(child: Text('لا يوجد تجار'));
        return ListView.builder(
          itemCount: merchantsCtrl.merchants.length,
          itemBuilder: (context, idx) {
            final m = merchantsCtrl.merchants[idx];
            final profile = m['profile'] ?? {};
            return ListTile(
              title: Text(profile['business_name'] ?? profile['name'] ?? 'تاجر'),
              subtitle: Text(profile['phone'] ?? ''),
              trailing: IconButton(icon: Icon(Icons.edit), onPressed: () => Get.to(() => MerchantDetailsView(merchant: m))),
            );
          },
        );
      }),
    );
  }
}
