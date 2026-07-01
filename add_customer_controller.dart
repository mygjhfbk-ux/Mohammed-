import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../../core/api_constants.dart';

class AddCustomerController extends GetxController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController limitController = TextEditingController();

  // هل العميل مسجل مسبقاً في التطبيق أم لا
  final hasAccount = true.obs;
  var isLoading = false.obs;
  var isActive = 0.obs; // 1: نشط، 0: موقف

  final box = GetStorage();
  int? merchantId;

  @override
  void onInit() {
    // جلب معرف التاجر من الـ Profile-id الذي خزناه عند تسجيل الدخول
    merchantId = box.read("Profile-id");
    super.onInit();
    clearFields();
  }

  Future<void> sendAddRequest() async {
    // التحقق من صحة المدخلات قبل الإرسال
    if (phoneController.text.length < 9 && hasAccount.value) {
      Get.snackbar("تنبيه", "رقم الهاتف غير مكتمل، يرجى التأكد",
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    if (limitController.text.isEmpty) {
      Get.snackbar("تنبيه", "يرجى تحديد سقف الدين لهذا العميل",
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    try {
      isLoading(true);

      // التأكد من معرف التاجر قبل البدء
      merchantId ??= box.read("Profile-id");

      final response = await http.post(
        Uri.parse(ApiConstants.sendAddRequest),
        headers: ApiConstants.getHeaders(),
        body: jsonEncode({
          "merchantId": merchantId,
          "customerPhone": phoneController.text,
          "debtLimit": limitController.text, // سقف الدين
          "customerName": nameController.text,
          "address": addressController.text,
          "hasAccount": hasAccount.value ? '1' : '0', // 1: بحث عن حساب، 0: تسجيل جديد
        }),
      );

      final result = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.back(); // العودة للخلف بعد النجاح
        Get.snackbar("تم بنجاح", result['message'] ?? "تم إرسال طلب الربط للعميل",
            backgroundColor: Colors.green, colorText: Colors.white);

        // تصفير الحقول بعد الإرسال الناجح
        clearFields();
      } else {
        Get.snackbar("فشل العملية", result['message'] ?? "تعذر إرسال الطلب حالياً",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      print("Error: $e");
      Get.snackbar("خطأ تقني", "حدثت مشكلة في الاتصال بالسيرفر، تأكد من الإنترنت",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading(false);
    }
  }

  /// دالة إرسال طلب التعديل
  Future<void> updateCustomerRequest(int requestId) async {
    try {
      merchantId ??= box.read("Profile-id");
      isLoading(true);
      final response = await http.post(
        Uri.parse(ApiConstants.updateFullCustomerRequest),
        headers: ApiConstants.getHeaders(),
        body: jsonEncode({
          "Request-id": requestId,
          "merchantId": merchantId,
          "Customer-Name": nameController.text,
          "Customer-Address": addressController.text,
          "Account-Limit": limitController.text,
          "Customer-Phone": phoneController.text,
          "User-Id": box.read("User-id"),
          "isActive": isActive.value,
        }),
      );

      final result = json.decode(response.body);

      if (response.statusCode == 200 && result['status'] == 'success') {
        Get.back(result: true); // العودة مع إشارة للنجاح لتحديث القائمة
        Get.snackbar("تم التحديث", "تم حفظ بيانات العميل بنجاح",
            backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        Get.snackbar("فشل التحديث", result['message'] ?? "حدث خطأ ما",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      print(e);
      Get.snackbar("خطأ تقني", "مشكلة في الاتصال بالسيرفر$e",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading(false);
    }
  }

  void clearFields() {
    nameController.clear();
    phoneController.clear();
    addressController.clear();
    limitController.clear();
    isActive.value = 0;
  }
}
