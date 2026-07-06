import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/app_constants.dart';
import '../../core/supabase_service.dart';

class CustomerDashboardController extends GetxController {
  var isLoading          = true.obs;
  final box              = GetStorage();
  var summary            = {}.obs;
  var recentTransactions = <dynamic>[].obs;
  var acceptedMerchants  = [].obs;

  Future<void> fetchDashboardData(String userId) async {
    try {
      isLoading(true);

      final customer = await SupabaseService.client
          .from(AppTables.customers)
          .select()
          .eq('user_id', userId)
          .single();

      final customerId = customer['id'];
      box.write("customerId", customerId);

      final requests = await SupabaseService.client
          .from(AppTables.requests)
          .select('total_debt')
          .eq('customer_id', customerId)
          .eq('status', RequestStatus.accepted);

      double totalDebt = 0;
      for (var r in requests) {
        totalDebt += (r['total_debt'] as num?)?.toDouble() ?? 0;
      }

      final today = DateTime.now().toString().split(' ')[0];
      final todayTx = await SupabaseService.client
          .from(AppTables.transactions)
          .select('amount')
          .eq('type', TransactionType.debt)
          .gte('date', today);

      double todayDebt = 0;
      for (var t in todayTx) {
        todayDebt += (t['amount'] as num?)?.toDouble() ?? 0;
      }

      summary.value = {
        'name':       customer['customer_name'],
        'total_debt': totalDebt,
        'today_debt': todayDebt,
        'currency':   'YR',
      };

      final recent = await SupabaseService.client
          .from(AppTables.transactions)
          .select('*, requests!inner(customer_id, merchants(merchant_name))')
          .eq('requests.customer_id', customerId)
          .order('date', ascending: false)
          .limit(10);

      recentTransactions.assignAll(recent);
      await fetchMerchants(userId);
    } catch (e) {
      print("Dashboard Error: $e");
      Get.snackbar("تنبيه", "يرجى التحقق من الإنترنت");
    } finally {
      isLoading(false);
    }
  }

  String get customerName => summary['name']?.toString() ?? "لا توجد بيانات";
  String get totalDebt    => _formatCurrency(summary['total_debt']);
  String get todayDebt    => _formatCurrency(summary['today_debt']);

  String _formatCurrency(dynamic amount) {
    double val = double.tryParse(amount?.toString() ?? "0.0") ?? 0.0;
    return val.toStringAsFixed(2);
  }

  void fetchMerchants(String userId) async {
    try {
      isLoading(true);
      final customerId = box.read("customerId");

      final data = await SupabaseService.client
          .from(AppTables.requests)
          .select('*, merchants(id, merchant_name, phone, business_name)')
          .eq('customer_id', customerId)
          .eq('status', RequestStatus.accepted);

      acceptedMerchants.value = data;
    } catch (e) {
      print("Error fetching merchants: $e");
    } finally {
      isLoading(false);
    }
  }
}
