import 'dart:async';
import 'dart:convert';
import 'package:app_merchant_customer/views/welcome_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../core/api_constants.dart';
import '../views/admin/AdminDashboardView.dart';
import '../views/customers/customer_dashboard_view.dart';
import '../views/login_view.dart';
import '../views/merchant/merchant_dashboard_screen.dart';
import '../views/otp_view.dart';
import '../views/reset_password_view.dart';
import 'package:get_storage/get_storage.dart';

import 'admin_controller/AdminDashboardController.dart';


class AuthController extends GetxController {
  var isLoading = false.obs;
  var resendSeconds = 60.obs; // عداد الثواني
  Timer? _timer;
  final box = GetStorage();
  final TextEditingController phoneController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    String? savedPhone = box.read('saved_phone');
    if (savedPhone != null) {
      phoneController.text = savedPhone;
    }
    startResendTimer(); // ابدأ العداد فور فتح الواجهة
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  ///
  Future<void> verifyOtp(String phone, String otp) async {
    try {
      isLoading(true);
      var response = await http.post(
        Uri.parse(ApiConstants.verifyOtp),
        headers: ApiConstants.getHeaders(),
        body: {
          'User-phone': phone,
          'otp': otp,
        },
      );

      if (response.statusCode == 200) {
        Get.snackbar("نجاح", "تم تفعيل الحساب بنجاح، يمكنك تسجيل الدخول الآن",
            backgroundColor: Colors.green, colorText: Colors.white);

        Get.offAll(() => LoginView());
      } else {
        Get.snackbar("خطأ", "رمز التحقق غير صحيح، حاول مرة أخرى",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      print(e);
      Get.snackbar("خطأ", "تعذر الاتصال بالسيرفر");
    } finally {
      isLoading(false);
    }
  }

  int getSavedUserId() {
    return box.read('userId') ?? 0;
  }

  ///
  Future<void> forgotPassword(String phone) async {
    try {
      isLoading(true);
      var response = await http.post(
        Uri.parse(ApiConstants.forgotPassword),
        headers: ApiConstants.getHeaders(),
        body: {'User-phone': phone},
      );

      if (response.statusCode == 200) {
        Get.snackbar("نجاح", "تم إرسال رمز التحقق إلى واتساب الخاص بك",
            backgroundColor: Colors.green, colorText: Colors.white);
        Get.to(() => ResetPasswordView(phone: phone));
      } else {
        Get.snackbar("خطأ", "رقم الهاتف هذا غير مسجل لدينا",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("خطأ", "تعذر الاتصال بالسيرفر");
    } finally {
      isLoading(false);
    }
  }

  ///
  Future<void> resetPassword(String phone, String otp, String newPassword) async {
    try {
      isLoading(true);
      var response = await http.post(
        Uri.parse(ApiConstants.resetPassword),
        headers: ApiConstants.getHeaders(),
        body: {
          'User-phone': phone,
          'otp': otp,
          'New-Password': newPassword,
        },
      );

      if (response.statusCode == 200) {
        Get.snackbar("نجاح", "تم تغيير كلمة المرور بنجاح، يمكنك الدخول الآن",
            backgroundColor: Colors.green, colorText: Colors.white);
        Get.offAll(() => LoginView());
      } else {
        var data = json.decode(response.body);
        Get.snackbar("خطأ", data['message'] ?? "الرمز غير صحيح أو انتهت صلاحيته",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("خطأ", "حدث خطأ أثناء الاتصال بالسيرفر");
    } finally {
      isLoading(false);
    }
  }

  ///
  Future<void> requestResetOtp(String phone, String newPassword) async {
    var response = await http.post(
      Uri.parse(ApiConstants.forgotPassword),
      body: {'User-phone': phone},
    );
    try{
      if (response.statusCode == 200) {
        showOtpDialog(phone, newPassword);
      }
      else {
        showOtpDialog(phone, newPassword);

      }
    }
    catch(ex) {
      Get.snackbar("تنبيه", ex.toString());
    }
  }

  ///
  void showOtpDialog(String phone, String newPassword) {
    TextEditingController otpController = TextEditingController();
    Get.defaultDialog(
      title: "تأكيد الهوية",
      content: Column(
        children: [
          Text("أدخل الرمز المرسل إلى الوتساب الخاص بك"),
          TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15)),
              ),
          ),
        ],
      ),
      confirm: ElevatedButton(
        onPressed: () => resetPassword(phone, otpController.text, newPassword),
        child: Text("تغيير الآن"),
      ),
    );
  }

  ///
  Future<void> logout() async {
    final box = GetStorage();
    await box.erase();
    Get.offAll(WelcomeView());
  }


  /// إضافة دالة تسجيل التاجر أو العميل بشكل ديناميكي
  Future<void> register({
    required String name,
    required String phone,
    required String address,
    required String password,
    required String userType, // 'merchant' or 'customer'
    String? businessName,    // اختياري للتاجر
  }) async
  {
    try {
      isLoading(true);

      var response = await http.post(
        Uri.parse(ApiConstants.register),
        headers: ApiConstants.getHeaders(),
        body: {
          'User-Name': name,
          'User-phone': phone,
          'Customer-address': address, // سيرفرنا سيضعها في الحقل المناسب
          'Password': password,
          'User-type': userType,
          'Business-Name': businessName ?? name,
        },
      );

      var data = json.decode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        if(data['status'] == "error"){
          Get.snackbar("نجاح ", data['message'] ?? "تم التسجيل بنجاح");
        }
        else if(data['status'] == "success"){
          Get.snackbar("نجاح ", data['status'] ?? "تم التسجيل بنجاح");
          Get.off(() => OtpView(phoneNumber: phone));
        }

      } else {
        Get.snackbar("خطأ", data['message'] ?? "فشل التسجيل",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("خطأ", "تعذر الاتصال بالسيرفر: $e");
    } finally {
      isLoading(false);
    }
  }

  ///  دالة تسجيل الدخول
  Future<void> login(String phone, String password) async {
    try {
      var role =  box.read('User-type');
      isLoading(true);
      var response = await http.post(
        Uri.parse(ApiConstants.login),
        headers: ApiConstants.getHeaders(),
        body: {
          'User-phone': phone, // يفضل تمرير المتغير المباشر
          'Password': password,
          // 'role': role.toString(),
        },
      );

      var data = json.decode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        // تخزين البيانات بشكل منظم
        box.write('isLoggedIn', true);
        box.write('User-id', data['user_info']['User-id']);
        box.write('User-Name', data['user_info']['User-Name']);
        box.write('User-Type', data['user_type']);
        box.write('saved_phone', data['user_info']['User-phone']);

        // تخزين بيانات البروفايل (العميل أو التاجر)
        if (data['profile'] != null) {
          box.write('Profile-id', data['user_type'] == 'merchant'
              ? data['profile']['Merchant-id']
              : data['profile']['Customer-id']);
        }

        // التوجيه حسب النوع
        if (role  == data['user_type'] && data['user_type'] == 'merchant') {
          box.write('Name', data['profile']['Merchant-Name'] ?? " ");

            // حفظ تاريخ الانتهاء (expiryDateStr)
            box.write('sub_expiry', data['profile']['end_at']);

            // حفظ حالة الاشتراك (isTrial)
            box.write('sub_status', data['profile']['sub_status']);

            // حفظ حالة التفعيل البرمجية (للتحقق السريع)
            box.write('is_subscribed', data['profile']['sub_status']);
          Get.offAll(() => MerchantDashboardScreen());
        }
        else if (data['user_type'] == 'admin') {
          Get.offAll(() => AdminDashboardView());
        }
        else if (role  == data['user_type'] && data['user_type'] == 'customer'){
          Get.offAll(() => CustomerDashboardView());
        }
        else {
          Get.snackbar("خطأ", "بيانات الدخول خاطئة",
              backgroundColor: Colors.orange);
        }
      }
      else if (response.statusCode == 403) {
        Get.snackbar("تفعيل الحساب", data['message']);
        Get.to(() => OtpView(phoneNumber: phone));
      }
      else {
        Get.snackbar("خطأ", data['message'] ?? "بيانات الدخول خاطئة",
            backgroundColor: Colors.orange);
      }
    } catch (e) {
      // في حالة عدم وجود إنترنت (Offline Mode)
      if (box.read('isLoggedIn') == true) {
      }
      Get.snackbar("تنبيه", " $eتاكد من اتصال الانترنت ");
    } finally {
      isLoading(false);
    }
  }

  ///
  void startResendTimer() {
    resendSeconds.value = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendSeconds.value > 0) {
        resendSeconds.value--;
      } else {
        _timer?.cancel();
      }
    });
  }

  /// دالة إعادة إرسال الرمز
  Future<void> resendOtp(String phone) async {
    try {
      isLoading.value = true;

      // طلب ملف الـ PHP (تأكد من وضع رابط السيرفر الصحيح)
      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/auth/send_otp.php"), // أو IP جهازك
        body: {"phone": phone, "action": "resend"},
      );

      if (response.statusCode == 200) {
        Get.snackbar("نجاح", "تم إعادة إرسال الرمز عبر واتساب");
        startResendTimer(); // إعادة تشغيل العداد بعد النجاح
      } else {
        Get.snackbar("خطأ", "فشل الاتصال بالسيرفر");
      }
    } catch (e) {
      Get.snackbar("خطأ", "حدث خطأ غير متوقع: ");
    } finally {
      isLoading.value = false;
    }
  }

}



