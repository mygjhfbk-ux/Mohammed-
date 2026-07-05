import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'merchant_list_view.dart';
import 'customer_list_view.dart';
import 'wallets_view.dart';
import 'transactions_view.dart';
import 'ads_view.dart';
import 'notifications_view.dart';

class MerchantDashboard extends StatelessWidget {
  const MerchantDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('لوحة التاجر')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(onPressed: () => Get.to(() => MerchantListView()), child: Text('عرض التجار')),
            ElevatedButton(onPressed: () => Get.to(() => CustomerListView()), child: Text('عرض العملاء')),
            ElevatedButton(onPressed: () => Get.to(() => WalletsView()), child: Text('المحافظ')),
            ElevatedButton(onPressed: () => Get.to(() => TransactionsView()), child: Text('المعاملات')),
            ElevatedButton(onPressed: () => Get.to(() => AdsView()), child: Text('الإعلانات')),
            // For Notifications view we need a profileId; for demo use a placeholder
            ElevatedButton(onPressed: () => Get.to(() => NotificationsView(profileId: 'PLACEHOLDER_PROFILE_ID')), child: Text('الإشعارات')),
          ],
        ),
      ),
    );
  }
}
