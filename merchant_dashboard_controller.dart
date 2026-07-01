import 'package:app_merchant_customer/core/api_constants.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MerchantDashboardController extends GetxController {
  var isLoading = false.obs;
  final box = GetStorage();

  // بيانات التاجر الأساسية
  var merchantName = "جاري التحميل...".obs;
  var phoneNumber = "".obs;
  var businessType = "".obs;

  var totalCustomers = 0.obs;    // عدد الزبائن المشتركين
  var totalDebts = 0.0.obs;     // إجمالي المديونية الخارجية
  var todayDebts = 0.0.obs;     // ديون تم تسجيلها اليوم فقط

  @override
  void onInit() {
    super.onInit();
    /// جلب رقم الهاتف المخزن مسبقاً لعرضه في البروفايل
    phoneNumber.value = box.read('saved_phone')?.toString() ?? "";
  }

  Future<void> fetchDashboardData(int userId) async {
    try {
      isLoading(true);

      var response = await http.get(
        Uri.parse(ApiConstants.getDashboardStats(userId)),
        headers: ApiConstants.getHeaders(),
      );

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);

        if (jsonData['status'] == 'success') {
          var data = jsonData['data'];
          var merchant = jsonData['merchant'];

          // تحديث الإحصائيات مع التأكد من تحويل الأنواع بشكل آمن
          totalCustomers.value = int.tryParse(data['total_customers'].toString()) ?? 0;
          totalDebts.value = double.tryParse(data['total_debts'].toString()) ?? 0.0;
          todayDebts.value = double.tryParse(data['today_debts'].toString()) ?? 0.0;

          // تحديث بيانات التاجر
          merchantName.value = merchant['Merchant-Name'] ?? "بدون اسم";
          businessType.value = merchant['Merchant-BusinessName'] ?? "تجاري";
          phoneNumber.value = box.read('saved_phone')?.toString() ?? "";

          // تخزين Merchant-id لاستخدامه في عمليات البيع وإضافة الكروت
          box.write("merchant_id", merchant['Merchant-id']);
          box.write("Profile-id", merchant['Merchant-id']); // للتوحيد مع بقية الـ Controllers
        }
      } else {
        Get.snackbar("تنبيه", "فشل تحديث البيانات من السيرفر");
      }
    } catch (e) {
      print("خطأ في الاتصال بالداشبورد: $e");
      // في حالة الخطأ، نحاول قراءة البيانات المخزنة محلياً إذا وجدت
    } finally {
      isLoading(false);
    }
  }

  // // دالة مساعدة لتحديث البيانات يدوياً (مثلاً عند السحب للأسفل Refresh)
  // Future<void> refreshData() async {
  //   int? userId = box.read('User-id');
  //   if (userId != null) {
  //     await fetchDashboardData(userId);
  //   }
  // }
}
