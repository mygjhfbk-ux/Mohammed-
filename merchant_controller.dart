import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../../core/api_constants.dart';
import 'customer_dashboard_controller.dart';

class MerchantController extends GetxController {
  // حالة التحميل والقوائم
  var isLoading = false.obs;
  var pendingRequests = [].obs;    // طلبات بانتظار موافقة العميل (للتاجر) أو العكس
  var merchantDetails = {}.obs;    // تفاصيل مديونية بقالة محددة
  // بيانات إضافية
  var allTransactions = <dynamic>[].obs;
  var merchantWallets = <dynamic>[].obs;
  var paymentReports = <dynamic>[].obs;
  var customerInfo = {}.obs; // لتخزين بيانات العميل (السقف، الاسم، الهاتف)
  final box = GetStorage();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  var startDate = Rxn<DateTime>();
  var endDate = Rxn<DateTime>();

// دالة لجلب القائمة المفلترة
  List get filteredTransactions {
    if (startDate.value == null || endDate.value == null) return allTransactions;
    return allTransactions.where((tx) {
      DateTime txDate = DateTime.parse(tx['date']);
      return txDate.isAfter(startDate.value!.subtract(const Duration(days: 1))) &&
          txDate.isBefore(endDate.value!.add(const Duration(days: 1)));
    }).toList();
  }

  /// 2. [للعميل] قبول طلب انضمام من تاجر
  Future<void> acceptRequest(String requestId, int userId) async {
    try {
      var response = await http.post(
        Uri.parse(ApiConstants.respondRequest),
        body: {
          'request_id': requestId,
          'Request-status': '1', // 1 تعني موافقة العميل
          'Customer-id' : userId.toString()
        },
      );
      if (response.statusCode == 200) {
        Get.snackbar("نجاح", "تم قبول التعامل مع البقالة وتفعيل حسابك");
        fetchPendingRequests(userId); // تحديث قائمة الطلبات المعلقة
        Get.find<CustomerDashboardController>().fetchMerchants(userId);       // تحديث قائمة المتاجر المقبولة
      }
    } catch (e) {
      Get.snackbar("خطأ", "فشل تنفيذ العملية");
    }
  }

  /// 4. جلب طلبات الإضافة المعلقة (ليراها العميل ويوافق عليها)
  void fetchPendingRequests(int userId) async {
    try {
      var response = await http.get(
          Uri.parse(ApiConstants.getPendingRequestsUrl(userId)),
          headers: ApiConstants.getHeaders()
      );

      var result = json.decode(response.body);
      if (response.statusCode == 200 && result['status'] == 'success') {
        pendingRequests.value = result['data'];
      }
    } catch (e) {
      print("Error fetching pending: $e");
    }
  }

  /// 5. جلب تفاصيل المديونية لمتجر محدد
  Future<void> fetchDetails(int merchantId, int userId) async {
    try {
      isLoading(true);
      var response = await http.get(
        Uri.parse(ApiConstants.getMerchantDetailsUrl(merchantId, userId)),
        headers: ApiConstants.getHeaders(),
      );

      var result = json.decode(response.body);
      if (response.statusCode == 200 && result['status'] == 'success') {
        merchantDetails.value = result['data'];
      }
    } catch (e) {
      Get.snackbar("خطأ", "فشل جلب بيانات المتجر");
    } finally {
      isLoading(false);
    }
  }

  /// 6. تقارير السداد (الأموال التي دفعها العميل)
  Future<void> fetchPaymentReports(int merchantId, int userId) async {
    try {
      isLoading(true);
      var response = await http.get(
        Uri.parse(ApiConstants.getPaymentReports(merchantId, userId)),
        headers: ApiConstants.getHeaders(),
      );

      var result = json.decode(response.body);
      if (response.statusCode == 200 && result['status'] == 'success') {
        paymentReports.value = result['data'];
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      isLoading(false);
    }
  }


  /// 7. التقارير العامة (كشف حساب شامل)
  Future<void> fetchGeneralReports(int merchantId, int requestId) async {
    try {
      isLoading(true);

      final String url = ApiConstants.getGeneralReports(merchantId,requestId);

      var response = await http.get(
        Uri.parse(url),
        headers: ApiConstants.getHeaders(),
      );

      var result = json.decode(response.body);

      if (response.statusCode == 200 && result['status'] == 'success') {
        // 1. تحديث قائمة العمليات (بما فيها الأصناف المدمجة items_summary)
        allTransactions.value = result['transactions'] ?? [];
        allTransactions.value = filteredTransactions;

        // 2. تحديث بيانات العميل المعروضة في البطاقة العلوية (الاسم، السقف، الدين)
        customerInfo.value = result['customer_info'] ?? {};

      } else {
        Get.snackbar("تنبيه", result['message'] ?? "لم يتم العثور على بيانات");
      }
    } catch (e) {
      print("Error fetching reports: $e");
      Get.snackbar("خطأ", "فشل الاتصال بالسيرفر");
    } finally {
      isLoading(false);
    }
  }

  Future<void> deleteTransaction(int transactionId, int requestId) async {
    try {
      isLoading(true);
      int merchantId = box.read('Profile-id');

      var response = await http.post(
        Uri.parse(ApiConstants.deletedTransaction),
        headers: ApiConstants.getHeaders(),
        body: jsonEncode({
          "transaction_id": transactionId,
          "merchant_id": merchantId,
        }),
      );

      var result = json.decode(response.body);
      if (response.statusCode == 200 && result['status'] == 'success') {
        // إعادة جلب التقارير لتحديث الواجهة فوراً
        fetchGeneralReports(merchantId, requestId);
        Get.snackbar("نجاح", "تم حذف العملية وتحديث الرصيد", backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        Get.snackbar("خطأ", result['message'] ?? "فشل الحذف");
      }
    } catch (e) {
      Get.snackbar("خطأ", "مشكلة في الاتصال بالسيرفر");
    } finally {
      isLoading(false);
    }
  }

}
