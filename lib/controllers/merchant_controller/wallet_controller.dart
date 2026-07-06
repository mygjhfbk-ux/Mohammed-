import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/app_constants.dart';
import '../../core/supabase_service.dart';

class WalletController extends GetxController {
  var isLoading = false.obs;
  var wallets   = [].obs;
  final box     = GetStorage();
  String? merchantId;

  @override
  void onInit() {
    merchantId = box.read("Profile-id");
    if (merchantId != null) fetchWallets(merchantId!);
    super.onInit();
  }

  Future<void> fetchWallets(String id) async {
    merchantId = id;
    try {
      isLoading(true);
      final data = await SupabaseService.client
          .from(AppTables.wallets)
          .select()
          .eq('merchant_id', id)
          .order('created_at', ascending: false);
      wallets.assignAll(data);
    } catch (ex) {
      print("WalletController.fetchWallets: $ex");
    } finally {
      isLoading(false);
    }
  }

  Future<void> addWallet({required String type, required String number, String note = ""}) async {
    try {
      isLoading(true);
      merchantId ??= box.read("Profile-id");

      await SupabaseService.client.from(AppTables.wallets).insert({
        'merchant_id':   merchantId,
        'wallet_type':   type,
        'wallet_number': number,
        'notes':         note,
      });

      await fetchWallets(merchantId!);
      Get.snackbar("نجاح", "تمت إضافة وسيلة الدفع بنجاح",
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (ex) {
      Get.snackbar("خطأ", "تعذر الاتصال بالسيرفر");
    } finally {
      isLoading(false);
    }
  }

  Future<void> deleteWallet(String id) async {
    try {
      await SupabaseService.client
          .from(AppTables.wallets)
          .delete()
          .eq('id', id);
      wallets.removeWhere((w) => w['id'].toString() == id);
      Get.snackbar("تم", "تم حذف وسيلة الدفع",
          backgroundColor: Colors.orange, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("خطأ", "تعذر الحذف حالياً");
    }
  }
}
