import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationsController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;
  var notifications = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  Future<void> fetchNotifications(String profileId) async {
    try {
      isLoading(true);
      final res = await supabase.from('notifications').select().eq('profile_id', profileId).order('created_at', ascending: false);
      notifications.assignAll(List<Map<String, dynamic>>.from(res as List<dynamic>));
    } catch (e) {
      print('fetchNotifications error: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<bool> markRead(String id, {String? profileId}) async {
    try {
      isLoading(true);
      await supabase.from('notifications').update({'is_read': true}).eq('id', id);
      if (profileId != null) await fetchNotifications(profileId);
      return true;
    } catch (e) {
      print('markRead error: $e');
      return false;
    } finally {
      isLoading(false);
    }
  }

  Future<bool> createNotification({required String profileId, required String title, required String body}) async {
    try {
      isLoading(true);
      await supabase.from('notifications').insert({
        'profile_id': profileId,
        'title': title,
        'body': body,
      });
      await fetchNotifications(profileId);
      return true;
    } catch (e) {
      print('createNotification error: $e');
      return false;
    } finally {
      isLoading(false);
    }
  }
}
