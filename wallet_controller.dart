import 'package:app_merchant_customer/core/api_constants.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';

class WalletController extends GetxController {
  var isLoading = false.obs;
  var wallets = [].obs; // قائمة المحافظ (طرق الدفع) المضافة
  final box = GetStorage();
  int? merchantId;

  @override
  void onInit() {
    merchantId = box.read("merchant_id") ?? box.read("Profile-id");
    if (merchantId != null) {
      fetchWallets(merchantId!);
    }
    super.onInit();
  }

  /// 1. جلب كافة المحافظ التابعة لهذا التاجر
  Future<void> fetchWallets(int merchantId) async {
    try {
      isLoading(true);

      if (merchantId == null) return;

      var response = await http.get(
        Uri.parse(ApiConstants.getWallets(merchantId)),
        headers: ApiConstants.getHeaders(),
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        // نتحقق إذا كان السيرفر يعيد مصفوفة مباشرة أو كائن يحتوي على status
        if (data is List) {
          wallets.assignAll(data);
        } else if (data['status'] == 'success') {
          wallets.assignAll(data['data']);
        }
      } else {
        print("Error fetching wallets: ${response.statusCode}");
      }
    } catch (ex) {
      print("Exception in fetchWallets: $ex");
    } finally {
      isLoading(false);
    }
  }

  /// 2. إضافة محفظة جديدة (مثلاً: الكريمي، رقم حساب معين)
  Future<void> addWallet(String type, String number, String note) async {
    try {
      isLoading(true);
      merchantId ??= box.read("merchant_id") ?? box.read("Profile-id");

      var response = await http.post(
        Uri.parse(ApiConstants.addWallet()),
        headers: ApiConstants.getHeaders(),
        body: jsonEncode({
          "merchant_id": merchantId,
          "type": type,    // نوع المحفظة (مثلاً: كريمي، إم فلوس)
          "number": number, // رقم الحساب أو المحفظة
          "notes": note    // ملاحظات إضافية (اختياري)
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchWallets(merchantId!); // تحديث القائمة فوراً
        Get.back(); // إغلاق نافذة الإضافة
        Get.snackbar("نجاح", "تمت إضافة وسيلة الدفع بنجاح",
            backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        var errorData = json.decode(response.body);
        Get.snackbar("فشل", errorData['message'] ?? "حدث خطأ أثناء الإضافة");
      }
    } catch (ex) {
      Get.snackbar("خطأ", "تعذر الاتصال بالسيرفر");
    } finally {
      isLoading(false);
    }
  }

  /// 3. حذف محفظة
  Future<void> deleteWallet(int id) async {
    try {
      var response = await http.delete(
        Uri.parse(ApiConstants.deleteWallet(id)),
        headers: ApiConstants.getHeaders(),
      );

      if (response.statusCode == 200) {
        wallets.removeWhere((w) => w['wallet_id'] == id);
        Get.snackbar("تنبيه", "تم حذف وسيلة الدفع",
            backgroundColor: Colors.orange, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("خطأ", "تعذر الحذف حالياً");
    }
  }
}
