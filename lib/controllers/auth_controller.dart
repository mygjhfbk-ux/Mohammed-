import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/app_constants.dart';
import '../core/supabase_service.dart';
import '../views/welcome_view.dart';
import '../views/admin/AdminDashboardView.dart';
import '../views/customers/customer_dashboard_view.dart';
import '../views/login_view.dart';
import '../views/merchant/merchant_dashboard_screen.dart';

class AuthController extends GetxController {
  var isLoading = false.obs;
  final box = GetStorage();
  final TextEditingController phoneController = TextEditingController();

  SupabaseClient get _db => SupabaseService.client;

  @override
  void onInit() {
    super.onInit();
    String? savedPhone = box.read('saved_phone');
    if (savedPhone != null) phoneController.text = savedPhone;
  }

  @override
  void onClose() {
    phoneController.dispose();
    super.onClose();
  }

  Future<void> register({
    required String name,
    required String phone,
    required String address,
    required String password,
    required String userType,
    String? businessName,
  }) async {
    try {
      isLoading(true);
      final email = SupabaseService.phoneToEmail(phone);

      final res = await _db.auth.signUp(
        email: email,
        password: password,
        data: {'user_type': userType, 'name': name},
      );

      if (res.user == null) {
        Get.snackbar("خطأ", "فشل إنشاء الحساب",
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      final uid = res.user!.id;

      await _db.from(AppTables.userProfiles).insert({
        'id': uid,
        'user_type': userType,
        'full_name': name,
        'phone': phone,
      });

      if (userType == UserType.merchant) {
        await _db.from(AppTables.merchants).insert({
          'user_id': uid,
          'merchant_name': name,
          'business_name': businessName ?? name,
          'phone': phone,
        });
      } else if (userType == UserType.customer) {
        await _db.from(AppTables.customers).insert({
          'user_id': uid,
          'customer_name': name,
          'phone': phone,
          'address': address,
        });
      }

      await _db.auth.signOut();
      Get.snackbar("تم بنجاح", "تم إنشاء الحساب، يمكنك تسجيل الدخول الآن",
          backgroundColor: Colors.green, colorText: Colors.white);
      Get.offAll(() => LoginView());
    } on AuthException catch (e) {
      if (e.message.contains('already registered')) {
        Get.snackbar("تنبيه", "رقم الهاتف مسجل مسبقاً",
            backgroundColor: Colors.orange, colorText: Colors.white);
      } else {
        Get.snackbar("خطأ", e.message,
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("خطأ", "تعذر الاتصال: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> login(String phone, String password) async {
    try {
      isLoading(true);
      final email = SupabaseService.phoneToEmail(phone);

      final res = await _db.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (res.user == null) {
        Get.snackbar("خطأ", "بيانات الدخول خاطئة",
            backgroundColor: Colors.orange, colorText: Colors.white);
        return;
      }

      final uid = res.user!.id;
      final profile = await _db
          .from(AppTables.userProfiles)
          .select()
          .eq('id', uid)
          .single();

      final userType = profile['user_type'];

      box.write('isLoggedIn', true);
      box.write('User-id', uid);
      box.write('User-Name', profile['full_name']);
      box.write('User-Type', userType);
      box.write('saved_phone', phone);

      if (userType == UserType.merchant) {
        final merchant = await _db
            .from(AppTables.merchants)
            .select()
            .eq('user_id', uid)
            .single();

        box.write('Profile-id', merchant['id']);
        box.write('merchant_id', merchant['id']);
        box.write('Name', merchant['merchant_name']);
        box.write('sub_status', merchant['sub_status']);
        box.write('is_subscribed', merchant['sub_status']);
        Get.offAll(() => MerchantDashboardScreen());
      } else if (userType == UserType.customer) {
        final customer = await _db
            .from(AppTables.customers)
            .select()
            .eq('user_id', uid)
            .single();

        box.write('Profile-id', customer['id']);
        box.write('customerId', customer['id']);
        box.write('Name', customer['customer_name']);
        Get.offAll(() => CustomerDashboardView());
      } else if (userType == UserType.admin) {
        Get.offAll(() => AdminDashboardView());
      } else {
        Get.snackbar("خطأ", "نوع المستخدم غير معروف",
            backgroundColor: Colors.orange);
      }
    } on AuthException catch (e) {
      Get.snackbar("خطأ", "بيانات الدخول خاطئة أو الحساب غير موجود",
          backgroundColor: Colors.orange, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("تنبيه", "تأكد من اتصال الإنترنت");
    } finally {
      isLoading(false);
    }
  }

  Future<void> logout() async {
    await _db.auth.signOut();
    await box.erase();
    Get.offAll(() => WelcomeView());
  }

  Future<void> forgotPassword(String phone) async {
    try {
      isLoading(true);
      final email = SupabaseService.phoneToEmail(phone);
      await _db.auth.resetPasswordForEmail(email);
      Get.snackbar("تم", "تم إرسال رابط تغيير كلمة المرور إلى بريدك الإلكتروني",
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("تنبيه", "تأكد من رقم الهاتف المدخل");
    } finally {
      isLoading(false);
    }
  }

  int getSavedUserId() => 0;

  String getSavedUserUid() => box.read('User-id') ?? '';
}
