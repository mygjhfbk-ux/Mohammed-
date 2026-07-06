import 'package:get/get.dart';
import '../../core/app_constants.dart';
import '../../core/supabase_service.dart';

class AdminDashboardController extends GetxController {
  var isLoading      = false.obs;
  var merchantsCount = 0.obs;
  var customersCount = 0.obs;
  var totalDebt      = "0.00".obs;
  var pendingReq     = 0.obs;
  var activeAds      = 0.obs;

  @override
  void onInit() {
    super.onInit();
    refreshDashboard();
  }

  Future<void> refreshDashboard() async {
    try {
      isLoading(true);
      final result = await SupabaseService.client
          .rpc(AppRpc.getAdminDashboard);

      merchantsCount.value = int.tryParse(result['merchants_count'].toString()) ?? 0;
      customersCount.value = int.tryParse(result['customers_count'].toString()) ?? 0;
      totalDebt.value      = (result['total_debt'] ?? 0).toString();
      pendingReq.value     = int.tryParse(result['pending_req'].toString()) ?? 0;
      activeAds.value      = int.tryParse(result['active_ads'].toString()) ?? 0;
    } catch (e) {
      Get.snackbar("خطأ اتصال", "تعذر جلب بيانات لوحة التحكم");
    } finally {
      isLoading(false);
    }
  }
}
