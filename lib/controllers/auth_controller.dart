import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get_storage/get_storage.dart';

class AuthController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;
  final box = GetStorage();
  var isLoading = false.obs;

  String phoneToEmail(String phone) {
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
        final profileRes = await supabase.from('profiles').insert({
          'user_id': res.user!.id,
          'phone': phone,
          'name': name ?? '',
          'user_type': userType,
        }).select().single();

        // Save to local storage
        box.write('isLoggedIn', true);
        box.write('supabase_user_id', res.user!.id);
        box.write('profile', profileRes);
        box.write('profile_id', profileRes['id']);

        Get.snackbar('نجاح', 'تم إنشاء الحساب');

        // redirect
        if (userType == 'merchant') Get.offAllNamed('/merchant');
        else if (userType == 'admin') Get.offAllNamed('/admin');
        else Get.offAllNamed('/customer');
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
        // fetch profile
        final profile = await supabase.from('profiles').select().eq('user_id', user!.id).maybeSingle();
        if (profile != null) {
          box.write('isLoggedIn', true);
          box.write('supabase_user_id', user.id);
          box.write('profile', profile);
          box.write('profile_id', profile['id']);

          final type = profile['user_type'] ?? 'customer';
          if (type == 'merchant') Get.offAllNamed('/merchant');
          else if (type == 'admin') Get.offAllNamed('/admin');
          else Get.offAllNamed('/customer');
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

  String? currentProfileId() {
    return box.read('profile_id');
  }
}
