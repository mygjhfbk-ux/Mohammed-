import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/app_constants.dart';
import '../../core/supabase_service.dart';
import 'customer_dashboard_controller.dart';

class MerchantController extends GetxController {
  var isLoading       = false.obs;
  var pendingRequests = [].obs;
  var merchantDetails = {}.obs;
  var allTransactions = <dynamic>[].obs;
  var merchantWallets = <dynamic>[].obs;
  var paymentReports  = <dynamic>[].obs;
  var customerInfo    = {}.obs;
  final box           = GetStorage();

  var startDate = Rxn<DateTime>();
  var endDate   = Rxn<DateTime>();

  List get filteredTransactions {
    if (startDate.value == null || endDate.value == null) return allTransactions;
    return allTransactions.where((tx) {
      try {
        final txDate = DateTime.parse(tx['date'].toString());
        return txDate.isAfter(startDate.value!.subtract(const Duration(days: 1))) &&
            txDate.isBefore(endDate.value!.add(const Duration(days: 1)));
      } catch (_) {
        return true;
      }
    }).toList();
  }

  Future<void> acceptRequest(String requestId, String userId) async {
    try {
      isLoading(true);
      final customer = await SupabaseService.client
          .from(AppTables.customers)
          .select('id')
          .eq('user_id', userId)
          .single();

      await SupabaseService.client
          .from(AppTables.requests)
          .update({'status': RequestStatus.accepted})
          .eq('id', requestId)
          .eq('customer_id', customer['id']);

      Get.snackbar("نجاح", "تم قبول التعامل مع البقالة");
      fetchPendingRequests(userId);
      try { Get.find<CustomerDashboardController>().fetchMerchants(userId); } catch (_) {}
    } catch (e) {
      Get.snackbar("خطأ", "فشل تنفيذ العملية");
    } finally {
      isLoading(false);
    }
  }

  Future<void> rejectRequest(String requestId) async {
    try {
      await SupabaseService.client
          .from(AppTables.requests)
          .update({'status': RequestStatus.blocked})
          .eq('id', requestId);
      Get.snackbar("تم", "تم رفض الطلب");
    } catch (e) {
      Get.snackbar("خطأ", "فشل تنفيذ العملية");
    }
  }

  void fetchPendingRequests(String userId) async {
    try {
      isLoading(true);
      final customer = await SupabaseService.client
          .from(AppTables.customers)
          .select('id')
          .eq('user_id', userId)
          .single();

      final data = await SupabaseService.client
          .from(AppTables.requests)
          .select('*, merchants(id, merchant_name, phone, business_name)')
          .eq('customer_id', customer['id'])
          .eq('status', RequestStatus.pending);

      pendingRequests.value = data;
    } catch (e) {
      print("fetchPendingRequests: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchDetails(String merchantId, String userId) async {
    try {
      isLoading(true);
      final customerId = box.read("customerId") ?? "";

      final request = await SupabaseService.client
          .from(AppTables.requests)
          .select('*, merchants(merchant_name, phone, business_name), customers(customer_name)')
          .eq('merchant_id', merchantId)
          .eq('customer_id', customerId)
          .single();

      merchantDetails.value = request;
    } catch (e) {
      Get.snackbar("خطأ", "فشل جلب بيانات المتجر");
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchGeneralReports(String merchantId, String requestId) async {
    try {
      isLoading(true);

      final request = await SupabaseService.client
          .from(AppTables.requests)
          .select('*, customers(customer_name, address), merchants(merchant_name)')
          .eq('id', requestId)
          .single();

      final txData = await SupabaseService.client
          .from(AppTables.transactions)
          .select('*, ${AppTables.transactionItems}(*)')
          .eq('request_id', requestId)
          .order('date', ascending: false);

      allTransactions.value = txData;
      customerInfo.value    = request['customers'] ?? {};
    } catch (e) {
      print("fetchGeneralReports: $e");
      Get.snackbar("خطأ", "فشل الاتصال");
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchMerchantWallets(String merchantId) async {
    try {
      isLoading(true);
      final data = await SupabaseService.client
          .from(AppTables.wallets)
          .select()
          .eq('merchant_id', merchantId)
          .order('created_at', ascending: false);
      merchantWallets.value = data;
    } catch (e) {
      print("fetchMerchantWallets: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> deleteTransaction(String transactionId, String requestId) async {
    try {
      isLoading(true);
      final merchantId = box.read('Profile-id')?.toString() ?? "";
      await SupabaseService.client
          .from(AppTables.transactions)
          .delete()
          .eq('id', transactionId)
          .eq('merchant_id', merchantId);

      await fetchGeneralReports(merchantId, requestId);
      Get.snackbar("نجاح", "تم حذف العملية",
          backgroundColor: const Color(0xFF4CAF50), colorText: const Color(0xFFFFFFFF));
    } catch (e) {
      Get.snackbar("خطأ", "مشكلة في الاتصال");
    } finally {
      isLoading(false);
    }
  }
}
