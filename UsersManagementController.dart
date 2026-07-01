import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:app_merchant_customer/core/api_constants.dart';

class UsersManagementController extends GetxController {
  var isLoading = false.obs;
  var allUsers = [].obs; // القائمة الكاملة القادمة من السيرفر
  var filteredUsers = [].obs; // القائمة التي تظهر بعد البحث أو الفلترة
  final box = GetStorage();
  @override
  void onInit() {
    fetchUsers();
    super.onInit();
  }

  Future<void> fetchUsers() async {
    try {
      isLoading(true);
      var response = await http.get(Uri.parse(ApiConstants.getUserToAdmin));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['status'] == 'success') {
          // استخدام assignAll يضمن تحديث الواجهات المراقبة بـ Obx
          allUsers.assignAll(data['data']);
          filteredUsers.assignAll(data['data']);
        }
      }
    } catch (e) {
      print("Error fetching users: $e");
    } finally {
      isLoading(false);
    }
  }


  // دالة البحث بالاسم أو الرقم
  void searchUser(String query) {
    if (query.isEmpty) {
      filteredUsers.assignAll(allUsers);
    } else {
      filteredUsers.assignAll(allUsers.where((u) =>
      u['User-Name'].toString().toLowerCase().contains(query.toLowerCase()) ||
          u['User-phone'].toString().contains(query)).toList());
    }
  }

  // تغيير حالة المستخدم (حظر/تفعيل)

  Future<void> toggleUserStatus(String userId, String newStatus) async {
    // 1. التحقق من أن المستخدم لا يحاول حظر نفسه
    // نقارن المعرف المخزن في GetStorage مع المعرف المرسل للدالة
    if (box.read('User-id').toString() == userId.toString()) {
      Get.snackbar(
        "تنبيه أمني",
        "لا يمكنك تعديل حالة حسابك النشط حالياً من هنا",
        backgroundColor: Colors.orange[800],
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return; // التوقف عن التنفيذ فوراً
    }

    // 2. التحديث المتفائل للواجهة (Optimistic Update)
    int userIndex = filteredUsers.indexWhere((u) => u['User-id'].toString() == userId);
    String oldStatus = "";

    if (userIndex != -1) {
      oldStatus = filteredUsers[userIndex]['is_active'].toString();
      filteredUsers[userIndex]['is_active'] = newStatus;
      filteredUsers.refresh(); // تحديث الواجهة فوراً
    }

    try {
      // 3. إرسال الطلب للسيرفر
      var body = {
        'User-Id': userId,
        'isActive': newStatus,
      };

      var response = await http.post(
          Uri.parse(ApiConstants.userActive),
          headers: ApiConstants.getHeaders(),
          body: body
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['status'] == 'success') {
          Get.rawSnackbar(
            message: data['message'],
            backgroundColor: Colors.green.withOpacity(0.8),
            duration: const Duration(seconds: 1),
          );
        } else {
          _revertStatus(userIndex, oldStatus);
          Get.snackbar("خطأ", data['message']);
        }
      } else {
        _revertStatus(userIndex, oldStatus);
        Get.snackbar("خطأ اتصال", "السيرفر غير مستجيب");
      }
    } catch (e) {
      _revertStatus(userIndex, oldStatus);
      Get.snackbar("خطأ نظام", "حدث خطأ أثناء الاتصال");
    }
  }

  Future<void> toggleUserStatus1(String userId, String newStatus) async {
    // 1. التحديث الفوري للواجهة (قبل إرسال الطلب للسيرفر)
    // نبحث عن المستخدم في القائمة المحلية ونغير حالته فوراً
    int userIndex = allUsers.indexWhere((u) => u['User-id'].toString() == userId);
    String oldStatus = ""; // لحفظ الحالة القديمة في حال الفشل
    if (userIndex != -1) {
      oldStatus = allUsers[userIndex]['is_active'].toString();
      allUsers[userIndex]['is_active'] = newStatus;
      allUsers.refresh(); // تنبيه Obx لتحديث الواجهة فوراً
    }


    try {
      if(box.read('User-id') == userId){
        Get.snackbar("خطأ",  "لا يمكن ايقاف المستخدم الحالي");
      }
      else {
        // 2. إرسال الطلب للسيرفر
        var body = {
          'User-Id': userId,
          'isActive': newStatus,
        };

        var response = await http.post(
            Uri.parse(ApiConstants.userActive),
            headers: ApiConstants.getHeaders(),
            body: body
        );

        if (response.statusCode == 200) {
          var data = json.decode(response.body);
          if (data['status'] == 'success') {
            // نجاح: نظهر رسالة بسيطة أو لا نظهر شيئاً لأن الواجهة تحدثت بالفعل
            Get.rawSnackbar(
              message: data['message'],
              backgroundColor: Colors.green.withOpacity(0.8),
              snackPosition: SnackPosition.BOTTOM,
              duration: const Duration(seconds: 1),
            );
            fetchUsers();
          }

          else {
            // فشل من السيرفر: نعيد الحالة القديمة
            _revertStatus(userIndex, oldStatus);
            Get.snackbar("خطأ", data['message'] ?? "فشل تحديث الحالة");
          }
        }
        else {
          // فشل اتصال: نعيد الحالة القديمة
          _revertStatus(userIndex, oldStatus);
          Get.snackbar("خطأ اتصال", "السيرفر غير مستجيب");
        }
      }
    } catch (e) {
      // خطأ برمجية: نعيد الحالة القديمة
      _revertStatus(userIndex, oldStatus);
      Get.snackbar("خطأ نظام", "حدث خطأ غير متوقع");
    }
  }

// دالة مساعدة لإعادة الحالة في حال الفشل
  void _revertStatus(int index, String oldStatus) {
    if (index != -1) {
      filteredUsers[index]['is_active'] = oldStatus;
      filteredUsers.refresh();
    }
  }

  // دالة تفعيل أو تجديد اشتراك التاجر
  Future<void> activateMerchantSubscription({
    required String userId,
    required String period,
    required String amount,
  }) async {
    try {
      isLoading(true);

      // تجهيز البيانات المرسلة للسيرفر
      var body = {
        'target_user_id': userId,
        'period': period,
        'amount': amount,
      };

      // استدعاء الـ API (تأكد من مطابقة المسار لملف PHP الذي أنشأناه سابقاً)
      var response = await http.post(
        Uri.parse(ApiConstants.manageSubscription), // أضف هذا الرابط في ApiConstants
        headers: ApiConstants.getHeaders(),
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        if (data['status'] == 'success') {
          Get.snackbar(
            "تم التفعيل",
            data['message'],
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );

          // تحديث القائمة فوراً لجلب تواريخ الانتهاء الجديدة
          await fetchUsers();
        } else {
          Get.snackbar("فشل العملية", data['message'], backgroundColor: Colors.red, colorText: Colors.white);
        }
      } else {
        Get.snackbar("خطأ اتصال", "السيرفر غير مستجيب: ${response.request}");
      }
    } catch (e) {
      Get.snackbar("خطأ نظام", "حدث خطأ غير متوقع: $e");
    } finally {
      isLoading(false);
    }
  }

}
