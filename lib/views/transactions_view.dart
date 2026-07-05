import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/transactions_controller.dart';

class TransactionsView extends StatelessWidget {
  TransactionsView({super.key, this.merchantId});
  final String? merchantId;
  final TransactionsController ctrl = Get.put(TransactionsController());

  @override
  Widget build(BuildContext context) {
    if (merchantId != null) ctrl.fetchTransactions(merchantId: merchantId);
    return Scaffold(
      appBar: AppBar(title: Text('المعاملات')),
      body: Obx(() {
        if (ctrl.isLoading.value) return Center(child: CircularProgressIndicator());
        if (ctrl.transactions.isEmpty) return Center(child: Text('لا توجد معاملات'));
        return ListView.builder(
          itemCount: ctrl.transactions.length,
          itemBuilder: (context, idx) {
            final t = ctrl.transactions[idx];
            return ListTile(
              title: Text('${t['type']} - ${t['amount']}'),
              subtitle: Text(t['notes'] ?? ''),
              trailing: IconButton(icon: Icon(Icons.delete), onPressed: () => ctrl.deleteTransaction(t['id'], merchantId: merchantId)),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final amountCtrl = TextEditingController();
          final typeCtrl = TextEditingController(text: 'debt');
          final walletCtrl = TextEditingController();
          final customerCtrl = TextEditingController();
          await Get.defaultDialog(
            title: 'إضافة معاملة',
            content: Column(
              children: [
                TextField(controller: customerCtrl, decoration: InputDecoration(labelText: 'customer_id')), // in a full app, provide selector
                TextField(controller: walletCtrl, decoration: InputDecoration(labelText: 'wallet_id')),
                TextField(controller: amountCtrl, decoration: InputDecoration(labelText: 'المبلغ'), keyboardType: TextInputType.number),
                TextField(controller: typeCtrl, decoration: InputDecoration(labelText: 'النوع (debt/payment)')),
              ],
            ),
            confirm: ElevatedButton(
              onPressed: () async {
                if (merchantId != null) {
                  await ctrl.addTransaction(
                    merchantId: merchantId!,
                    customerId: customerCtrl.text.trim(),
                    walletId: walletCtrl.text.trim(),
                    amount: double.tryParse(amountCtrl.text) ?? 0,
                    type: typeCtrl.text.trim(),
                  );
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
