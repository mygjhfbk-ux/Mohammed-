import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/customers_controller.dart';
import '../controllers/wallets_controller.dart';
import 'transactions_view.dart';

class CustomerDashboard extends StatelessWidget {
  CustomerDashboard({super.key});
  final CustomersController customersCtrl = Get.put(CustomersController());
  final WalletsController walletsCtrl = Get.put(WalletsController());

  @override
  Widget build(BuildContext context) {
    // For demo, fetch all customers
    customersCtrl.fetchCustomers();

    return Scaffold(
      appBar: AppBar(title: Text('لوحة العميل')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(onPressed: () => Get.to(() => TransactionsView()), child: Text('المعاملات')),
            ElevatedButton(onPressed: () => Get.to(() => WalletsView()), child: Text('محافظي')),
            ElevatedButton(onPressed: () => Get.to(() => CustomerListView()), child: Text('ملفي الشخصي')),
          ],
        ),
      ),
    );
  }
}
