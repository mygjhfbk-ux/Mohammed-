import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../../core/api_constants.dart';

class MerchantCustomersController extends GetxController {
  var isLoading = true.obs;
  var customerList = [].obs;
  var searchedQuery = TextEditingController();
  var selectedFilter = "كافة العملاء".obs;
  final box = GetStorage();
  int? merchantId;
  String searchQuery = "";

  @override
  void onInit() {
    // جلب معرف التاجر (Profile-id) المخزن عند تسجيل الدخول
    merchantId = box.read("Profile-id");
    searchQuery = "";
    searchedQuery.text = "";
    // fetchCustomer();
    super.onInit();
  }

  /// 1. جلب قائمة العملاء المرتبطين بالبقالة
  void fetchCustomer() async {
    merchantId = box.read("Profile-id");
    if (merchantId == null) {
      Get.snackbar("خطأ", "لم يتم العثور على بيانات التاجر");
      return;
    }

    try {
      isLoading(true);
      String url = ApiConstants.getMerchantCustomers(
          merchantId!,
          filter: _mapFilter(selectedFilter.value),
          search: searchedQuery.text
      );

      var response = await http.get(
        Uri.parse(url),
        headers: ApiConstants.getHeaders(),
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['status'] == 'success') {
          customerList.assignAll(data['data']);
        }
      }
    } catch (ex) {
      print("Error fetching customers: $ex");
    } finally {
      isLoading(false);
    }
  }

  // /// 2. [جديد] دالة إرسال طلب إضافة لعميل غير موجود في القائمة
  // Future<void> inviteNewCustomer(String phone) async {
  //   if (phone.isEmpty) return;
  //
  //   try {
  //     isLoading(true);
  //     var response = await http.post(
  //       Uri.parse(ApiConstants.respondRequest), // الملف الذي يعالج الطلبات
  //       body: {
  //         'Merchant-id': merchantId.toString(),
  //         'Customer-phone': phone,
  //         'Request-status': '0', // 0 يعني طلب جديد بانتظار العميل
  //       },
  //     );
  //
  //     var data = json.decode(response.body);
  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       Get.snackbar("نجاح", "تم إرسال طلب الإضافة للعميل بنجاح");
  //       fetchCustomer(); // تحديث القائمة لرؤية الطلب المعلق
  //     } else {
  //       Get.snackbar("تنبيه", data['message'] ?? "هذا الرقم غير مسجل في التطبيق");
  //     }
  //   } catch (e) {
  //     Get.snackbar("خطأ", "فشل الاتصال بالسيرفر");
  //   } finally {
  //     isLoading(false);
  //   }
  // }

  // /// 3. تغيير حالة العميل (إيقاف/تنشيط) من قبل التاجر
  // Future<void> toggleCustomerStatus(int requestId, bool isActive) async {
  //   try {
  //     var response = await http.post(
  //       Uri.parse(ApiConstants.respondRequest),
  //       body: {
  //         'request_id': requestId.toString(),
  //         'Request-status': isActive ? '1' : '2', // 1 نشط، 2 موقف
  //       },
  //     );
  //
  //     if (response.statusCode == 200) {
  //       fetchCustomer(); // إعادة جلب البيانات لتحديث القائمة
  //       Get.snackbar("تحديث", "تم تغيير حالة العميل بنجاح");
  //     }
  //   } catch (e) {
  //     Get.snackbar("خطأ", "تعذر تحديث الحالة");
  //   }
  // }

  String _mapFilter(String filterName) {
    switch (filterName) {
      case "نشط فقط": return "active";
      case "الموقفين فقط": return "blocked";
      case "الموثقين": return "local";
      case "الغير موثقين": return "localed";
      case "الأكثر ديناً": return "most_debt";
      case "ترتيب حسب الأبجدية": return "alphabetical";
      default: return "all";
    }
  }

  void updateSearch(String value) {
    searchedQuery.text = value;
    fetchCustomer();
  }

  // void updateFilter(String filter) {
  //   selectedFilter.value = filter;
  //   fetchCustomer();
  // }
}
