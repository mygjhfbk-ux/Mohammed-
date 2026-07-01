import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/api_constants.dart';

class CustomerDashboardController extends GetxController {
  var isLoading = true.obs;
  final box = GetStorage();

  /// ملخص البيانات (الاسم، إجمالي الدين، مديونية اليوم)
  var summary = {}.obs;
  /// آخر العمليات المسجلة
  var recentTransactions = <dynamic>[].obs;
  /// البقالات التي وافق العميل عليها
  var acceptedMerchants = [].obs;

  /// جلب بيانات لوحة التحكم
  Future<void> fetchDashboardData(int userId) async {
    try {
      isLoading(true);
      var response = await http.get(
        Uri.parse(ApiConstants.getDashboardUrl(userId)),
        headers: ApiConstants.getHeaders(),
      );

      if (response.statusCode == 200) {
        var result = json.decode(response.body);
        /// تحديث ملخص الحساب
        summary.value = result['summary'] ?? {
          'name': 'غير معروف',
          'total_debt': 0.0,
          'today_debt': 0.0,
          'currency': 'YR'
        };
        var a = result['summary'];
        box.write("customerId", a["customerId"]);

        // جلب آخر عمليات تم تنفيذها (ديون أو سداد)
        recentTransactions.assignAll(result['recent_transactions'] ?? []);
        fetchMerchants(userId);

      } else {
        _handleError(response.statusCode);
      }
    } catch (e) {
      print("Dashboard Error: $e");
      Get.snackbar("تنبيه", " يرجى التحقق من الإنترنت");
    } finally {
      isLoading(false);
    }
  }

  /// التعامل مع الأخطاء القادمة من السيرفر
  void _handleError(int statusCode) {
    Get.snackbar(
        "مشكلة في البيانات",
        "تعذر تحديث البيانات من السيرفر (كود: $statusCode)",
        snackPosition: SnackPosition.BOTTOM
    );
  }

  /// Getters للوصول السهل للبيانات من الواجهة (UI)
  String get customerName => summary['name']?.toString() ?? "لا توجد بيانات";

  /// تنسيق المبالغ المالية
  String get totalDebt => _formatCurrency(summary['total_debt']);
  String get todayDebt => _formatCurrency(summary['today_debt']);

  String _formatCurrency(dynamic amount) {
    double val = double.tryParse(amount?.toString() ?? "0.0") ?? 0.0;
    return val.toStringAsFixed(2);
  }

  /// 3. جلب المتاجر المقبولة للعميل
  void fetchMerchants(int userId) async {
    try {
      isLoading(true);
      var response = await http.get(
          Uri.parse(ApiConstants.getAcceptedMerchantsUrl(userId)));

      var result = json.decode(response.body);
      if (response.statusCode == 200 && result['status'] == 'success') {
        acceptedMerchants.value = result['data'];
      }
    } catch (e) {
      print("Error fetching merchants: $e");
    } finally {
      isLoading(false);
    }
  }

}
