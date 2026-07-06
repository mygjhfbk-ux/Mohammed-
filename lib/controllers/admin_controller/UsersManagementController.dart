import 'package:get/get.dart';
import '../../core/app_constants.dart';
import '../../core/supabase_service.dart';

class UsersManagementController extends GetxController {
  var isLoading     = false.obs;
  var usersList     = [].obs;
  var merchantsList = <dynamic>[].obs;
  var customersList = <dynamic>[].obs;

  @override
  void onInit() {
    fetchAllUsers();
    super.onInit();
  }

  Future<void> fetchAllUsers() async {
    try {
      isLoading(true);

      final merchants = await SupabaseService.client
          .from(AppTables.merchants)
          .select('*, user_profiles(full_name, phone, is_active)')
          .order('created_at', ascending: false);

      final customers = await SupabaseService.client
          .from(AppTables.customers)
          .select('*, user_profiles(full_name, phone, is_active)')
          .order('created_at', ascending: false);

      merchantsList.value = merchants;
      customersList.value = customers;
      usersList.value     = [...merchants, ...customers];
    } catch (e) {
      Get.snackbar("خطأ", "فشل جلب المستخدمين");
    } finally {
      isLoading(false);
    }
  }

  Future<void> toggleUserStatus(String userId) async {
    try {
      final user = await SupabaseService.client
          .from(AppTables.userProfiles)
          .select('is_active')
          .eq('id', userId)
          .single();

      final current = user['is_active'] == true;
      await SupabaseService.client
          .from(AppTables.userProfiles)
          .update({'is_active': !current})
          .eq('id', userId);

      await fetchAllUsers();
      Get.snackbar("تم التحديث", current ? "تم إيقاف المستخدم" : "تم تفعيل المستخدم");
    } catch (e) {
      Get.snackbar("خطأ", "فشل تحديث الحالة");
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await SupabaseService.client
          .from(AppTables.userProfiles)
          .delete()
          .eq('id', userId);
      await fetchAllUsers();
      Get.snackbar("تم", "تم حذف المستخدم",
          backgroundColor: const Color(0xFFFF5722));
    } catch (e) {
      Get.snackbar("خطأ", "فشل الحذف");
    }
  }
}
