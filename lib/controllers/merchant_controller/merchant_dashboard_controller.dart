import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/app_constants.dart';
import '../../core/supabase_service.dart';

class MerchantDashboardController extends GetxController {
  var isLoading = false.obs;
  final box = GetStorage();

  var merchantName  = "جاري التحميل...".obs;
  var phoneNumber   = "".obs;
  var businessType  = "".obs;
  var totalCustomers = 0.obs;
  var totalDebts     = 0.0.obs;
  var todayDebts     = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    phoneNumber.value = box.read('saved_phone')?.toString() ?? "";
  }

  Future<void> fetchDashboardData(String merchantId) async {
    try {
      isLoading(true);

      final merchant = await SupabaseService.client
          .from(AppTables.merchants)
          .select()
          .eq('id', merchantId)
          .single();

      merchantName.value = merchant['merchant_name'] ?? "بدون اسم";
      businessType.value = merchant['business_name'] ?? "تجاري";
      phoneNumber.value  = box.read('saved_phone') ?? "";

      final stats = await SupabaseService.client
          .rpc(AppRpc.getMerchantDashboard, params: {'p_merchant_id': merchantId});

      totalCustomers.value = int.tryParse(stats['total_customers'].toString()) ?? 0;
      totalDebts.value     = double.tryParse(stats['total_debts'].toString()) ?? 0.0;
      todayDebts.value     = double.tryParse(stats['today_debts'].toString()) ?? 0.0;

      box.write("merchant_id", merchantId);
      box.write("Profile-id", merchantId);
    } catch (e) {
      print("خطأ في الاتصال بالداشبورد: $e");
    } finally {
      isLoading(false);
    }
  }
}
