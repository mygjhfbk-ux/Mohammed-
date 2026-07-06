import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/app_constants.dart';
import '../../core/supabase_service.dart';
import '../../views/admin/AdminDashboardView.dart';

class AdminRegisterController extends GetxController {
  var isLoading = false.obs;

  final TextEditingController nameController     = TextEditingController();
  final TextEditingController phoneController    = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<void> registerAdmin() async {
    if (nameController.text.isEmpty ||
        phoneController.text.isEmpty ||
        passwordController.text.isEmpty) {
      Get.snackbar("تنبيه", "يرجى ملء جميع الحقول",
          backgroundColor: Colors.orange);
      return;
    }
    try {
      isLoading(true);
      final email = SupabaseService.phoneToEmail(phoneController.text);

      final res = await SupabaseService.client.auth.signUp(
        email: email,
        password: passwordController.text,
        data: {'user_type': UserType.admin, 'name': nameController.text},
      );

      if (res.user == null) {
        Get.snackbar("خطأ", "فشل إنشاء حساب المدير",
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      await SupabaseService.client.from(AppTables.userProfiles).insert({
        'id':        res.user!.id,
        'user_type': UserType.admin,
        'full_name': nameController.text,
        'phone':     phoneController.text,
      });

      Get.offAll(() => AdminDashboardView());
      Get.snackbar("نجاح", "تم إنشاء حساب المدير",
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("خطأ", "حدث خطأ: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading(false);
    }
  }
}
