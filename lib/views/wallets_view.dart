import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/wallets_controller.dart';

class WalletsView extends StatelessWidget {
  WalletsView({super.key, this.merchantId});
  final String? merchantId;
  final WalletsController ctrl = Get.put(WalletsController());

  @override
  Widget build(BuildContext context) {
    if (merchantId != null) ctrl.fetchWallets(merchantId!);
    return Scaffold(
      appBar: AppBar(title: Text('المحافظ')),
      body: Obx(() {
        if (ctrl.isLoading.value) return Center(child: CircularProgressIndicator());
        if (ctrl.wallets.isEmpty) return Center(child: Text('لا توجد محافظ'));
        return ListView.builder(
          itemCount: ctrl.wallets.length,
          itemBuilder: (context, idx) {
            final w = ctrl.wallets[idx];
            return ListTile(
              title: Text(w['name'] ?? 'محفظة'),
              subtitle: Text('الرصيد: \\${w['balance'] ?? 0}'),
              trailing: IconButton(icon: Icon(Icons.delete), onPressed: () => ctrl.deleteWallet(w['id'], merchantId: merchantId)),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final nameCtrl = TextEditingController();
          final balanceCtrl = TextEditingController(text: '0');
          await Get.defaultDialog(
            title: 'إضافة محفظة',
            content: Column(
              children: [
                TextField(controller: nameCtrl, decoration: InputDecoration(labelText: 'الاسم')),
                TextField(controller: balanceCtrl, decoration: InputDecoration(labelText: 'الرصيد الابتدائي'), keyboardType: TextInputType.number),
              ],
            ),
            confirm: ElevatedButton(
              onPressed: () async {
                if (merchantId != null) {
                  await ctrl.createWallet(merchantId: merchantId!, name: nameCtrl.text.trim(), initialBalance: double.tryParse(balanceCtrl.text) ?? 0);
                }
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
