import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:app_merchant_customer/core/api_constants.dart';

class AdminRegisterController extends GetxController {
  var isLoading = false.obs;

  Future<void> registerAdmin({
    required String name,
    required String phone,
    required String password,
    required String adminKey,
  }) async {
    if (name.isEmpty || phone.isEmpty || password.isEmpty || adminKey.isEmpty) {
      Get.snackbar("تنبيه", "يرجى ملء جميع الحقول");
      return;
    }

    try {
      isLoading(true);
      var response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/admin/admin_register.php"),
        body: {
          "name": name,
          "phone": phone,
          "password": password,
          "admin_key": adminKey,
        },
      );

      var data = json.decode(response.body);
      if (data['status'] == 'success') {
        Get.back(canPop: true); // التوجه لتسجيل الدخول
        Get.snackbar("نجاح", data['message'], backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        Get.snackbar("فشل", data['message'], backgroundColor: Colors.red, colorText: Colors.white);
      }
    } finally {
      isLoading(false);
    }
  }
}
