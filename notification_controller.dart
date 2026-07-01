import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/api_constants.dart';
import 'package:get_storage/get_storage.dart';

class NotificationController extends GetxController {
  var isLoading = false.obs;
  final box = GetStorage();
  var notifications = <dynamic>[].obs;
  var selectedFilter = "الكل".obs;
  var filteredNotifications = <dynamic>[].obs;


  /// 8. إدارة الإشعارات
  Future<void> fetchNotifications(int userId) async {
    try {
      isLoading(true);
      var response = await http.get(
        Uri.parse(ApiConstants.getNotifications(userId)),
        headers: ApiConstants.getHeaders(),
      );

      var result = json.decode(response.body);
      if (response.statusCode == 200) {
        notifications.value = result['data'];
        filterNotifications(selectedFilter.value);
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      isLoading(false);
    }
  }

  /// فلترت الاشعارات
  void filterNotifications(String filter) {
    selectedFilter.value = filter;
    if (filter == "الكل") {
      filteredNotifications.assignAll(notifications);
    } else if (filter == "غير مقروء") {
      // التمييز بناءً على الحقل Not-isread في جدولك
      filteredNotifications.assignAll(notifications.where((n) => n['is_read'] == 0 || n['is_read'] == "0").toList());
    } else if (filter == "مقروء") {
      filteredNotifications.assignAll(notifications.where((n) => n['is_read'] == 1 || n['is_read'] == "1").toList());
    }
  }

  /// دالة تحويل الكل إلى مقروء
  Future<void> markAllAsRead() async {
    int userId = box.read("User-id"); // معرف المستخدم المخزن

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.readAllNotification),
        headers: ApiConstants.getHeaders(),
        body: jsonEncode({"user_id": userId}),
      );

      if (response.statusCode == 200) {
        notifications.refresh();
        fetchNotifications(userId);
        print("تم تحديث الإشعارات بنجاح");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  /// تغيير الاشعار الؤ مقروء
  Future<void> markAsRead(int notId) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.readSingleNotification),
        headers: ApiConstants.getHeaders(),
        body: jsonEncode({"not_id": notId}),
      );

      if (response.statusCode == 200) {
        var result = json.decode(response.body);
        if (result['status'] == 'success') {
          notifications.refresh();
          fetchNotifications(box.read("User-id"));
          print("تم قراءة الإشعار: $notId");
        }
      }
    } catch (e) {
      print("Error: $e");
    }
  }

}


