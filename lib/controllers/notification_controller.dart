import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../core/api_constants.dart';

class NotificationController extends GetxController {
  var notifications = <dynamic>[].obs;
  var isLoading = false.obs;

  Future<void> fetchNotifications() async {
    try {
      isLoading(true);
      final userId = GetStorage().read('User-id');
      final response = await http.get(Uri.parse(ApiConstants.getNotifications(userId ?? 0)));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          notifications.assignAll(data['data'] ?? []);
        }
      }
    } catch (e) {
      // لا نريد رمي الاستثناء للواجهة مباشرة
    } finally {
      isLoading(false);
    }
  }
}
