import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../core/api_constants.dart';

class AdminDashboardController extends GetxController {
  var isLoading = false.obs;

  // المتغيرات المطلوبة
  var merchantsCount = 0.obs;
  var customersCount = 0.obs;
  var totalDebt = "0.00".obs;
  var pendingReq = 0.obs;
  var activeAds = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // refreshDashboard();
  }

  Future<void> refreshDashboard() async {
    try {
      isLoading(true);
      var response = await http.get(Uri.parse(ApiConstants.getDataAdminDach));
      
      if (response.statusCode == 200) {
        var result = json.decode(response.body);
        if (result['status'] == 'success') {
          var data = result['data'];
          merchantsCount.value = data['merchants_count'];
          customersCount.value = data['customers_count'];
          totalDebt.value      = data['total_debt'];
          pendingReq.value     = data['pending_req'];
          activeAds.value      = data['active_ads'];
        }
      }
    } catch (e) {
      Get.snackbar("خطأ اتصال", "تعذر جلب بيانات لوحة التحكم");
    } finally {
      isLoading(false);
    }
  }

}
