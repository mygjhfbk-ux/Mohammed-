import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/app_constants.dart';
import '../../core/supabase_service.dart';

class NotificationController extends GetxController {
  var isLoading             = false.obs;
  final box                 = GetStorage();
  var notifications         = <dynamic>[].obs;
  var selectedFilter        = "الكل".obs;
  var filteredNotifications = <dynamic>[].obs;

  Future<void> fetchNotifications(String userId) async {
    try {
      isLoading(true);
      final data = await SupabaseService.client
          .from(AppTables.notifications)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      notifications.value = data;
      filterNotifications(selectedFilter.value);
    } catch (e) {
      print("Error: $e");
    } finally {
      isLoading(false);
    }
  }

  void filterNotifications(String filter) {
    selectedFilter.value = filter;
    if (filter == "الكل") {
      filteredNotifications.assignAll(notifications);
    } else if (filter == "غير مقروء") {
      filteredNotifications.assignAll(
          notifications.where((n) => n['is_read'] == false).toList());
    } else if (filter == "مقروء") {
      filteredNotifications.assignAll(
          notifications.where((n) => n['is_read'] == true).toList());
    }
  }

  Future<void> markAllAsRead() async {
    final userId = box.read("User-id");
    try {
      await SupabaseService.client
          .from(AppTables.notifications)
          .update({'is_read': true})
          .eq('user_id', userId);

      await fetchNotifications(userId);
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> markAsRead(String notId) async {
    try {
      await SupabaseService.client
          .from(AppTables.notifications)
          .update({'is_read': true})
          .eq('id', notId);

      final userId = box.read("User-id");
      await fetchNotifications(userId);
    } catch (e) {
      print("Error: $e");
    }
  }
}
