import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/customers_controller.dart';
import '../controllers/wallets_controller.dart';
import '../controllers/transactions_controller.dart';

class TransactionsView extends StatefulWidget {
  TransactionsView({super.key, this.merchantId});
  final String? merchantId;

  @override
  State<TransactionsView> createState() => _TransactionsViewState();
}

class _TransactionsViewState extends State<TransactionsView> {
  final TransactionsController ctrl = Get.put(TransactionsController());
  final CustomersController customersCtrl = Get.put(CustomersController());
  final WalletsController walletsCtrl = Get.put(WalletsController());

  String? selectedCustomerId;
  String? selectedWalletId;
  String selectedType = 'debt';

  @override
  void initState() {
    super.initState();
    if (widget.merchantId != null) {
      ctrl.fetchTransactions(merchantId: widget.merchantId);
      customersCtrl.fetchCustomers(merchantId: widget.merchantId);
      walletsCtrl.fetchWallets(widget.merchantId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.merchantId != null) ctrl.fetchTransactions(merchantId: widget.merchantId);
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
              trailing: IconButton(icon: Icon(Icons.delete), onPressed: () => ctrl.deleteTransaction(t['id'], merchantId: widget.merchantId)),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final amountCtrl = TextEditingController();
          final notesCtrl = TextEditingController();

          await Get.bottomSheet(
            StatefulBuilder(builder: (context, setState) {
              return Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Obx(() {
                        return DropdownButtonFormField<String>(
                          value: selectedCustomerId,
                          items: customersCtrl.customers.map((c) {
                            final profile = c['profile'] ?? {};
                            return DropdownMenuItem<String>(value: c['id'], child: Text(profile['name'] ?? profile['phone'] ?? 'عميل'));
                          }).toList(),
                          onChanged: (v) => setState(() => selectedCustomerId = v),
                          decoration: InputDecoration(labelText: 'العميل'),
                        );
                      }),
                      const SizedBox(height: 8),
                      Obx(() {
                        return DropdownButtonFormField<String>(
                          value: selectedWalletId,
                          items: walletsCtrl.wallets.map((w) {
                            return DropdownMenuItem<String>(value: w['id'], child: Text(w['name'] ?? 'محفظة'));
                          }).toList(),
                          onChanged: (v) => setState(() => selectedWalletId = v),
                          decoration: InputDecoration(labelText: 'المحفظة'),
                        );
                      }),
                      const SizedBox(height: 8),
                      TextField(controller: amountCtrl, decoration: InputDecoration(labelText: 'المبلغ'), keyboardType: TextInputType.number),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: selectedType,
                        items: ['debt', 'payment'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                        onChanged: (v) => setState(() => selectedType = v ?? 'debt'),
                        decoration: InputDecoration(labelText: 'النوع'),
                      ),
                      const SizedBox(height: 8),
                      TextField(controller: notesCtrl, decoration: InputDecoration(labelText: 'ملاحظات')),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () async {
                          if (widget.merchantId != null && selectedCustomerId != null && selectedWalletId != null) {
                            await ctrl.addTransaction(
                              merchantId: widget.merchantId!,
                              customerId: selectedCustomerId!,
                              walletId: selectedWalletId!,
                              amount: double.tryParse(amountCtrl.text) ?? 0,
                              type: selectedType,
                              notes: notesCtrl.text.trim(),
                            );
                          }
                          Get.back();
                        },
                        child: Text('حفظ'),
                      )
                    ],
                  ),
                ),
              );
            }),
            isScrollControlled: true,
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
