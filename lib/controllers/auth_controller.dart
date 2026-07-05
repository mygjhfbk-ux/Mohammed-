import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get_storage/get_storage.dart';

class AuthController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;
  final box = GetStorage();
  var isLoading = false.obs;

  String phoneToEmail(String phone) {
    // normalize phone then build pseudo-email
    final normalized = phone.replaceAll(' ', '');
    return '$normalized@diuni.local';
  }

  Future<void> signUp({required String phone, required String password, String? name, String userType = 'merchant'}) async {
    try {
      isLoading(true);
      final email = phoneToEmail(phone);
      final res = await supabase.auth.signUp(email: email, password: password);
      if (res.user != null) {
        // insert profile
        await supabase.from('profiles').insert({
          'user_id': res.user!.id,
          'phone': phone,
          'name': name ?? '',
          'user_type': userType,
        });
        Get.snackbar('نجاح', 'تم إنشاء الحساب');
      } else {
        Get.snackbar('خطأ', 'فشل التسجيل');
      }
    } catch (e) {
      Get.snackbar('خطأ', e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<void> signIn({required String phone, required String password}) async {
    try {
      isLoading(true);
      final email = phoneToEmail(phone);
      final res = await supabase.auth.signInWithPassword(email: email, password: password);
      if (res.session != null) {
        final user = res.user;
        box.write('isLoggedIn', true);
        box.write('supabase_user_id', user!.id);
        // fetch profile
        final profile = await supabase.from('profiles').select().eq('user_id', user.id).maybeSingle();
        if (profile != null) {
          box.write('profile', profile);
          final type = profile['user_type'] ?? 'customer';
          if (type == 'merchant') {
            Get.offAllNamed('/merchant');
          } else if (type == 'admin') {
            Get.offAllNamed('/admin');
          } else {
            Get.offAllNamed('/customer');
          }
        } else {
          Get.snackbar('تنبيه', 'الملف الشخصي غير موجود');
        }
      } else {
        Get.snackbar('خطأ', 'فشل تسجيل الدخول');
      }
    } catch (e) {
      Get.snackbar('خطأ', e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
    await box.erase();
    Get.offAllNamed('/');
  }
}
