import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/app_constants.dart';
import '../../core/supabase_service.dart';

class MerchantCustomersController extends GetxController {
  var isLoading     = true.obs;
  var customerList  = [].obs;
  var searchedQuery = TextEditingController();
  var activeFilter  = "all".obs;
  final box         = GetStorage();
  String? merchantId;

  @override
  void onInit() {
    merchantId = box.read("Profile-id");
    super.onInit();
  }

  void fetchCustomer() async {
    merchantId = box.read("Profile-id");
    if (merchantId == null) {
      Get.snackbar("خطأ", "لم يتم العثور على بيانات التاجر");
      return;
    }
    try {
      isLoading(true);

      var query = SupabaseService.client
          .from(AppTables.requests)
          .select('''
            id, status, account_limit, total_debt, is_active, created_at,
            customers(id, customer_name, user_profiles(phone))
          ''')
          .eq('merchant_id', merchantId!);

      if (activeFilter.value == 'active') {
        query = query.eq('status', RequestStatus.accepted);
      } else if (activeFilter.value == 'inactive') {
        query = query.eq('status', RequestStatus.blocked);
      }

      final data = await query.order('created_at', ascending: false);

      final q = searchedQuery.text.toLowerCase();
      var results = (data as List).where((item) {
        final name  = item['customers']?['customer_name']?.toString().toLowerCase() ?? '';
        final phone = item['customers']?['user_profiles']?['phone']?.toString() ?? '';
        return q.isEmpty || name.contains(q) || phone.contains(q);
      }).toList();

      customerList.assignAll(results);
    } catch (ex) {
      print("MerchantCustomersController.fetchCustomer: $ex");
    } finally {
      isLoading(false);
    }
  }

  void updateSearch(String value) {
    searchedQuery.text = value;
    fetchCustomer();
  }

  void applyFilter() => fetchCustomer();

  Future<void> updateCustomer({
    required String requestId,
    required String name,
    required double limit,
    required String address,
    required bool isActive,
  }) async {
    try {
      isLoading(true);

      await SupabaseService.client
          .from(AppTables.requests)
          .update({'account_limit': limit, 'is_active': isActive})
          .eq('id', requestId);

      final req = await SupabaseService.client
          .from(AppTables.requests)
          .select('customer_id')
          .eq('id', requestId)
          .single();

      await SupabaseService.client
          .from(AppTables.customers)
          .update({'customer_name': name, 'address': address})
          .eq('id', req['customer_id']);

      Get.back(result: true);
      Get.snackbar("نجاح", "تم تحديث بيانات العميل",
          backgroundColor: const Color(0xFF4CAF50), colorText: const Color(0xFFFFFFFF));
    } catch (e) {
      Get.snackbar("خطأ", "فشل التحديث: $e");
    } finally {
      isLoading(false);
    }
  }
}
