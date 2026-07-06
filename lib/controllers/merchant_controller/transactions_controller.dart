import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/app_constants.dart';
import '../../core/supabase_service.dart';

class TransactionsController extends GetxController {
  final box = GetStorage();
  var isLoading   = false.obs;
  var items = <Map<String, dynamic>>[
    {"name": "", "qty": 1.0, "price": 0.0, "total": 0.0}
  ].obs;
  var totalAmount        = 0.0.obs;
  var isDetailed         = true.obs;
  var customers          = <dynamic>[].obs;
  var selectedCustomerId = Rxn<String>();
  var overallReports     = <dynamic>[].obs;
  var editingItems       = <Map<String, dynamic>>[].obs;

  final TextEditingController amountController      = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String? currentTransactionId;

  void resetForm() {
    items.value = [{"name": "", "qty": 1.0, "price": 0.0, "total": 0.0}];
    totalAmount.value = 0.0;
    amountController.clear();
    descriptionController.clear();
    selectedCustomerId.value = null;
  }

  void addItem() => items.add({"name": "", "qty": 1.0, "price": 0.0, "total": 0.0});

  void removeItem(int index) {
    if (items.length > 1) {
      items.removeAt(index);
      calculateGrandTotal();
    }
  }

  void updateItem(int index, {String? price, String? qty, String? name}) {
    if (index >= items.length) return;
    if (name  != null) items[index]['name']  = name;
    final p = double.tryParse(price ?? items[index]['price'].toString()) ?? 0.0;
    final q = double.tryParse(qty   ?? items[index]['qty'].toString())   ?? 1.0;
    items[index]['price'] = p;
    items[index]['qty']   = q;
    items[index]['total'] = p * q;
    items.refresh();
    calculateGrandTotal();
  }

  void calculateGrandTotal() {
    totalAmount.value = items.fold(0.0, (sum, item) {
      final t = item['total'];
      return sum + (t is double ? t : double.tryParse(t.toString()) ?? 0.0);
    });
  }

  void calculateTotalFromItems() {
    double total = 0.0;
    for (var item in editingItems) {
      final qty   = double.tryParse(item['qty'].toString()) ?? 0.0;
      final price = double.tryParse(item['price'].toString()) ?? 0.0;
      total += qty * price;
    }
    amountController.text = total.toStringAsFixed(2);
  }

  Future<void> saveDebt({required String requestId}) async {
    final merchantId = box.read("Profile-id")?.toString() ?? "";
    final finalAmount = totalAmount.value > 0 ? totalAmount.value :
        (double.tryParse(amountController.text) ?? 0.0);

    if (finalAmount <= 0) {
      Get.snackbar("تنبيه", "يرجى إدخال مبلغ صحيح أكبر من صفر",
          backgroundColor: Colors.orange);
      return;
    }
    if (requestId.isEmpty) {
      Get.snackbar("تنبيه", "يرجى تحديد العميل أولاً",
          backgroundColor: Colors.orange);
      return;
    }

    try {
      isLoading(true);

      final tx = await SupabaseService.client
          .from(AppTables.transactions)
          .insert({
            'request_id':  requestId,
            'merchant_id': merchantId,
            'type':        TransactionType.debt,
            'amount':      finalAmount,
            'note': descriptionController.text.isEmpty ? "دين" : descriptionController.text,
          })
          .select()
          .single();

      if (items.isNotEmpty && items.any((i) => i['name'].toString().isNotEmpty)) {
        await SupabaseService.client
            .from(AppTables.transactionItems)
            .insert(items.map((item) => {
                  'transaction_id': tx['id'],
                  'item_name':      item['name'],
                  'quantity':       item['qty'],
                  'price':          item['price'],
                  'total':          item['total'],
                }).toList());
      }

      Get.back(result: true);
      Get.snackbar("نجاح", "تم تسجيل الدين بنجاح",
          backgroundColor: Colors.green, colorText: Colors.white);
      resetForm();
    } catch (e) {
      Get.snackbar("خطأ", "مشكلة في الاتصال: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> savePayment({
    required String requestId,
    required double amount,
    String note = "",
  }) async {
    final merchantId = box.read("Profile-id")?.toString() ?? "";

    if (amount <= 0) {
      Get.snackbar("تنبيه", "يرجى إدخال مبلغ صحيح", backgroundColor: Colors.orange);
      return;
    }
    try {
      isLoading(true);

      await SupabaseService.client.from(AppTables.transactions).insert({
        'request_id':  requestId,
        'merchant_id': merchantId,
        'type':        TransactionType.payment,
        'amount':      amount,
        'note':        note.isEmpty ? "سداد نقدي" : note,
      });

      Get.snackbar("نجاح", "تم خصم المبلغ من حساب العميل بنجاح",
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("خطأ", "مشكلة في الاتصال: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> updatePayment({
    required String transactionId,
    required double amount,
    String note = "",
    required String requestId,
  }) async {
    try {
      isLoading(true);
      await SupabaseService.client
          .from(AppTables.transactions)
          .update({'amount': amount, 'note': note})
          .eq('id', transactionId);

      Get.snackbar("تم التعديل", "تمت تحديث بيانات السداد",
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("خطأ", "تعذر الاتصال: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading(false);
    }
  }

  Future<void> deleteTransaction(String transactionId, String requestId) async {
    try {
      isLoading(true);
      final merchantId = box.read('Profile-id')?.toString() ?? "";
      await SupabaseService.client
          .from(AppTables.transactions)
          .delete()
          .eq('id', transactionId)
          .eq('merchant_id', merchantId);

      Get.snackbar("نجاح", "تم حذف العملية",
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("خطأ", "مشكلة في الاتصال");
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchCustomers() async {
    try {
      final merchantId = box.read("Profile-id")?.toString() ?? "";
      final data = await SupabaseService.client
          .from(AppTables.requests)
          .select('id, customers(id, customer_name)')
          .eq('merchant_id', merchantId)
          .eq('status', RequestStatus.accepted);
      customers.value = data;
    } catch (e) {
      print("fetchCustomers: $e");
    }
  }

  Future<void> fetchMerchantOverallReports({
    required String fromDate,
    required String toDate,
    required String type,
  }) async {
    try {
      isLoading(true);
      final merchantId = box.read('Profile-id')?.toString() ?? "";

      var query = SupabaseService.client
          .from(AppTables.transactions)
          .select('*, requests(customers(customer_name))')
          .eq('merchant_id', merchantId)
          .gte('date', fromDate)
          .lte('date', toDate);

      if (type == 'قبض مبلغ') {
        query = query.eq('type', TransactionType.payment);
      } else if (type == 'دين جديد') {
        query = query.eq('type', TransactionType.debt);
      }

      final data = await query.order('date', ascending: false);
      overallReports.value = data;
    } catch (e) {
      print("fetchMerchantOverallReports: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchTransactionDetails(String transactionId) async {
    try {
      isLoading(true);
      final result = await SupabaseService.client
          .from(AppTables.transactions)
          .select('*, ${AppTables.transactionItems}(*)')
          .eq('id', transactionId)
          .single();

      currentTransactionId  = result['id'].toString();
      amountController.text = result['amount'].toString();
      descriptionController.text = result['note'] ?? "";

      editingItems.clear();
      final details = result[AppTables.transactionItems] as List? ?? [];
      for (var item in details) {
        editingItems.add({
          "name":  item['item_name'],
          "qty":   item['quantity'],
          "price": item['price'],
        });
      }
    } catch (e) {
      Get.snackbar("خطأ", "فشل في جلب بيانات العملية");
    } finally {
      isLoading(false);
    }
  }

  Future<void> submitUpdate() async {
    if (amountController.text.isEmpty) {
      Get.snackbar("تنبيه", "يرجى إدخال مبلغ صحيح",
          backgroundColor: Colors.orange);
      return;
    }
    try {
      isLoading(true);

      await SupabaseService.client
          .from(AppTables.transactions)
          .update({
            'amount': double.parse(amountController.text),
            'note':   descriptionController.text,
          })
          .eq('id', currentTransactionId!);

      if (editingItems.isNotEmpty) {
        await SupabaseService.client
            .from(AppTables.transactionItems)
            .delete()
            .eq('transaction_id', currentTransactionId!);

        await SupabaseService.client
            .from(AppTables.transactionItems)
            .insert(editingItems.map((item) => {
                  'transaction_id': currentTransactionId,
                  'item_name':      item['name'],
                  'quantity':       item['qty'],
                  'price':          item['price'],
                  'total':
                      (double.tryParse(item['qty'].toString()) ?? 0) *
                      (double.tryParse(item['price'].toString()) ?? 0),
                }).toList());
      }

      Get.back();
      Get.snackbar("تم بنجاح", "تم تحديث العملية",
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("خطأ", "مشكلة في الاتصال: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading(false);
    }
  }

  @override
  void onClose() {
    amountController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}
