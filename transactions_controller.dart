import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../../core/api_constants.dart';

class TransactionsController extends GetxController {
  final box = GetStorage();
  var isLoading = false.obs;
  var amount = "0".obs;
  var transactionsId = 0.obs;
  var items = <Map<String, dynamic>>[
    {"name": "", "qty": 1.0, "price": 0.0, "total": 0.0}
  ].obs;

  var totalAmount = 0.0.obs;
  /// حقول الدين التفصيلي
  var isDetailed = false.obs;
  var customers = <dynamic>[].obs; // قائمة العملاء
  var selectedCustomerId = Rxn<int>(); // تخزين الرقم الفريد فقط
  var overallReports = <dynamic>[].obs;
  var editingItems = <Map<String, dynamic>>[].obs;   // قائمة الأصناف للدين التفصيلي

  // الحقول النصية للواجهة
  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  // معرفات العملية الحالية
  int? currentTransactionId;
  int? currentRequestId;

  @override
  void onInit() {
    super.onInit();

  }

  /// دالة إضافة صنف في الواجهة التفصيلية
  void addItem() {
    items.add({"name": "", "qty": 1.0, "price": 0.0, "total": 0.0});
  }

  void removeItem(int index) {
    if (items.length > 1) {
      items.removeAt(index);
      calculateGrandTotal();
    }
  }

  // 2. دالة حساب الإجمالي تلقائياً عند تغيير أي صنف
  void calculateTotalFromItems() {
    double total = 0.0;
    for (var item in editingItems) {
      double qty = double.tryParse(item['qty'].toString()) ?? 0.0;
      double price = double.tryParse(item['price'].toString()) ?? 0.0;
      total += (qty * price);
    }
    // تحديث حقل المبلغ في الواجهة
    amountController.text = total.toStringAsFixed(2);
    amount.value = total.toStringAsFixed(2);
  }

  /// 3. دالة الحفظ وإرسال بيانات تعديل دين
  Future<void> submitUpdate() async {
    if (amountController.text.isEmpty || double.tryParse(amountController.text) == 0) {
      Get.snackbar("تنبيه", "يرجى إدخال مبلغ صحيح", backgroundColor: Colors.orange);
      return;
    }
    try {
      isLoading(true);
      var bodyData = {
        "transaction_id": currentTransactionId,
        "amount": amount.value,
        "description": descriptionController.text,
        "items": editingItems.toList(), // سترسل كـ [] في الدين العادي
      };
      var response = await http.post(
        Uri.parse(ApiConstants.updateTransaction),
        headers:ApiConstants.getHeaders(),
        body: jsonEncode(bodyData),
      );

      var result = json.decode(response.body);

      if (response.statusCode == 200 && result['status'] == 'success') {
        Get.back(); // إغلاق واجهة التعديل
        Get.snackbar("تم بنجاح", result['message'], backgroundColor: Colors.green, colorText: Colors.white);

        // تحديث البيانات في الكنترولر الرئيسي (التاجر) لإظهار التعديلات فوراً
        // Get.find<MerchantController>().fetchGeneralReports(merchantId, requestId);
      } else {
        Get.snackbar("خطأ", result['message'] ?? "فشل التعديل", backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("خطأ في الاتصال", "يرجى التحقق من الشبكة", backgroundColor: Colors.red, colorText: Colors.white);
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

  /// دالة جلب بيانات دين
  Future<void> fetchTransactionDetails(int transactionId) async {
    try {
      isLoading(true);
      // استدعاء ملف PHP لجلب تفاصيل عملية محددة
      var response = await http.get(
        Uri.parse(ApiConstants.getTransaction(transactionId)),
      );

      if (response.statusCode == 200) {
        var result = json.decode(response.body);

        // تعبئة الحقول الأساسية
        transactionsId.value = result['main']['Transaction-id'];
        currentTransactionId =result['main']['Transaction-id'] ;
        amountController.text = result['main']['Amount'].toString();
        amount.value = result['main']['Amount'].toString();
        descriptionController.text = result['main']['Description'] ?? "";
        // تعبئة الأصناف التفصيلية
        editingItems.clear();
        if (result['details'] != null) {
          for (var item in result['details']) {
            editingItems.add({
              "name": item['Item-Name'],
              "qty": item['Quantity'],
              "price": item['Price'],
            });
          }
        }
      }
    } catch (e) {
      Get.snackbar("خطأ", "فشل في جلب بيانات العملية");
    } finally {
      isLoading(false);
    }
  }

  /// تحديث إجمالي الصنف عند تغيير السعر أو الكمية
  void updateItem(int index, {String? price, String? qty, String? name}) {
    if (name != null) items[index]['name'] = name;

    double p = double.tryParse(price ?? items[index]['price'].toString()) ?? 0.0;
    double q = double.tryParse(qty ?? items[index]['qty'].toString()) ?? 1.0;

    items[index]['price'] = p;
    items[index]['qty'] = q;
    items[index]['total'] = p * q;

    items.refresh();
    calculateGrandTotal();
  }

  void calculateGrandTotal() {
    totalAmount.value = items.fold(0.0, (sum, item) => sum + item['total']);
  }

  /// --- الدالة الرئيسية للحفظ ---
  Future<void> saveDebt({required int requestId}) async {
    // جلب معرف التاجر من الـ GetStorage
    int? merchantId = box.read("Profile-id");

    // تحديد المبلغ النهائي بناءً على نوع الواجهة (بسيطة أو تفصيلية)
    double finalAmount = isDetailed.value
        ? totalAmount.value
        : (double.tryParse(amountController.text) ?? 0.0);

    if (finalAmount <= 0) {
      Get.snackbar("تنبيه", "يرجى إدخال مبلغ صحيح أكبر من صفر", backgroundColor: Colors.orange);
      return;
    }

    try {
      isLoading(true);

      var body = {
        "merchant_id": merchantId,
        "request_id": requestId,
        "amount": finalAmount,
        "description": descriptionController.text.isEmpty
            ? (isDetailed.value ? "دين تفصيلي" : "دين مبلغ")
            : descriptionController.text,
        "items": isDetailed.value ? items : [],
      };

      final response = await http.post(
        Uri.parse(ApiConstants.addDebtTransaction),
        headers: ApiConstants.getHeaders(),
        body: jsonEncode(body),
      );

      final result = json.decode(response.body);

      if (response.statusCode == 200 && result['status'] == 'success') {
        Get.back(result: true);
        Get.snackbar("نجاح", "تم تسجيل الدين وتحديث الرصيد بنجاح",
            backgroundColor: Colors.green, colorText: Colors.white);
        _clearFields();
      } else {
        Get.snackbar("خطأ", result['message'] ?? "فشل تسجيل العملية",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("خطأ", "مشكلة في الاتصال بالسيرفر: $e");
    } finally {
      isLoading(false);
    }
  }

  void _clearFields() {
    amountController.clear();
    descriptionController.clear();
    items.value = [{"name": "", "qty": 1.0, "price": 0.0, "total": 0.0}];
    totalAmount.value = 0.0;
  }

  /// دالة لجلب العملاء المرتبطين بالتاجر
  Future<void> fetchCustomers() async {
    try {
      int merchantId = box.read("Profile-id");
      final response = await http.get(
        Uri.parse(ApiConstants.getCustomerByMerchant(merchantId)),
        headers: ApiConstants.getHeaders(),
      );
      if (response.statusCode == 200) {
        customers.value = json.decode(response.body);
      }
    } catch (e) {
      print("Error fetching customers: $e");
    }
  }

  /// دالة تسجيل عملية القبض
  Future<void> savePayment({required int requestId}) async {
    int? merchantId = box.read("Profile-id");
    double amount = double.tryParse(amountController.text) ?? 0.0;

    if (amount <= 0) {
      Get.snackbar("تنبيه", "يرجى إدخال مبلغ صحيح", backgroundColor: Colors.orange);
      return;
    }

    try {
      isLoading(true);
      var body = {
        "merchant_id": merchantId,
        "request_id": requestId,
        "amount": amount,
        "description": descriptionController.text.isEmpty ? "سداد نقدي" : descriptionController.text,
      };

      final response = await http.post(
        Uri.parse(ApiConstants.addPayment),
        headers: ApiConstants.getHeaders(),
        body: jsonEncode(body),
      );

      final result = json.decode(response.body);

      if (response.statusCode == 200 && result['status'] == 'success') {
        Get.back(result: true);
        // Get.snackbar("نجاح", "تم خصم المبلغ من حساب العميل ${result['message']}",
        //     backgroundColor: Colors.green, colorText: Colors.white);
        Get.snackbar("نجاح", result['message'].toString(),
            backgroundColor: Colors.green, colorText: Colors.white);
        _clearFields();
      } else {
        Get.snackbar("خطأ", result['message'] ?? "فشل تسجيل العملية");
      }
    } catch (e) {
      Get.snackbar("خطأ", "مشكلة في الاتصال بالسيرفر");
      print("error: $e");
    } finally {
      isLoading(false);
    }
  }

  // دالة تعديل عملية السداد
  Future<void> updatePayment({required int transactionId}) async {
    // 1. التحقق من إدخال المبلغ
    if (amountController.text.isEmpty) {
      Get.snackbar("خطأ", "يرجى إدخال المبلغ",
          backgroundColor: Colors.red[400], colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;

      // 2. تجهيز البيانات للإرسال
      var body = {
        "transaction_id": transactionId.toString(),
        "amount": amountController.text.trim(),
        "description": descriptionController.text.trim(),
      };

      // 3. استدعاء الـ API (تأكد من تغيير الرابط لرابط ملف التعديل لديك)
      var response = await http.post(
        Uri.parse(ApiConstants.updatePayment),
        headers: ApiConstants.getHeaders(),
        body: body,
      );
      final result = json.decode(response.body);
      if (result['status'] == 'success') {
        // 4. نجاح العملية
        Get.back(); // إغلاق الديالوج
        Get.snackbar("تم التعديل", "تمت تحديث بيانات السداد والأرصدة بنجاح",
            backgroundColor: Colors.green[400], colorText: Colors.white);
        _clearFields();
        // 5. تحديث البيانات في الصفحة الحالية (إعادة جلب العمليات أو تحديث القائمة)
      } else {
        // فشل من جهة السيرفر
        Get.snackbar("فشل التعديل", result['message'] ?? "حدث خطأ ما",
            backgroundColor: Colors.orange[400], colorText: Colors.white);
      }
    } catch (e) {
      // خطأ في الشبكة أو السيرفر
      Get.snackbar("خطأ نظام", "تعذر الاتصال الانترنت: $e",
          backgroundColor: Colors.red[700], colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }


  ///  دالة جلب التقارير العامة
  Future<void> fetchMerchantOverallReports({required String fromDate, required String toDate, required String type}) async {
    try {
      isLoading(true);
      int merchantId = box.read('Profile-id');

      var response = await http.post(
        Uri.parse(ApiConstants.getMerchantOverallReports()),
        headers: ApiConstants.getHeaders(),
        body: jsonEncode({
          "merchant_id": merchantId,
          "from": fromDate,
          "to": toDate,
          "type": type,
        }),
      );

      var result = json.decode(response.body);
      if (result['status'] == 'success') {
        overallReports.value = result['data'] ?? [];
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      isLoading(false);
    }
  }

  // Future<void> updateDebt({
  //   required int transactionId,
  //   required double amount,
  //   required String description,
  //   List<Map<String, dynamic>>? items,
  // }) async
  // {
  //   try {
  //     isLoading(true);
  //     var response = await http.post(
  //       Uri.parse(ApiConstants.updateTransaction),
  //       body: jsonEncode({
  //         "transaction_id": transactionId,
  //         "amount": amount,
  //         "description": description,
  //         "items": items ?? [], // إذا كانت فارغة سيتم التعامل معه كدين عادي
  //       }),
  //     );
  //
  //     var result = json.decode(response.body);
  //     if (result['status'] == 'success') {
  //       Get.back(); // العودة للواجهة السابقة
  //       Get.snackbar("نجاح", result['message'], backgroundColor: Colors.green, colorText: Colors.white);
  //       // إعادة تحديث البيانات
  //       //fetchGeneralReports(currentMerchantId, currentRequestId);
  //     }
  //   } catch (e) {
  //     Get.snackbar("خطأ", "حدث خطأ أثناء التعديل");
  //   } finally {
  //     isLoading(false);
  //   }
  // }

  //
  // void prepareEditData(Map transaction, List itemsFromServer) {
  //   // تفريغ القائمة القديمة
  //   editingItems.clear();
  //
  //   // تعبئة البيانات الجديدة من السيرفر (اسم، كمية، سعر)
  //   for (var item in itemsFromServer) {
  //     editingItems.add({
  //       "name": item['Item-Name'],
  //       "qty": item['Quantity'],
  //       "price": item['Price'],
  //     });
  //   }
  //   // تعيين الوصف والمبلغ الأصلي
  //   descriptionController.text = transaction['Description'] ?? "";
  //   amountController.text = transaction['Amount'].toString();
  // }

}
