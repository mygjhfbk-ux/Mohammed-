import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/transactions_controller.dart';

class EditTransactionView extends StatelessWidget {
  EditTransactionView({super.key, required this.transaction});
  final Map<String, dynamic> transaction;
  final TransactionsController ctrl = Get.find();
  final TextEditingController amountCtrl = TextEditingController();
  final TextEditingController notesCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    amountCtrl.text = transaction['amount']?.toString() ?? '';
    notesCtrl.text = transaction['notes'] ?? '';

    return Scaffold(
      appBar: AppBar(title: Text('تعديل معاملة')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: amountCtrl, decoration: InputDecoration(labelText: 'المبلغ'), keyboardType: TextInputType.number),
            TextField(controller: notesCtrl, decoration: InputDecoration(labelText: 'ملاحظات')),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                await ctrl.updateTransaction(transaction['id'], {'amount': double.tryParse(amountCtrl.text) ?? 0, 'notes': notesCtrl.text});
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
