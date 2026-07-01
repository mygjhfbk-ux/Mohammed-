import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../core/api_constants.dart';
import '../models/ad_model.dart';

class AdsController extends GetxController {
  var adsList = <AdModel>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    fetchAds();
    super.onInit();
  }

  // جلب الإعلانات
  Future<void> fetchAds() async {
    try {
      isLoading(true);
      var response = await http.get(Uri.parse(ApiConstants.getAds));

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        if (jsonData['status'] == 'success') {
          var ads = jsonData['data'] as List;
          adsList.assignAll(ads.map((e) => AdModel.fromJson(e)).toList());
        }
      }
    } finally {
      isLoading(false);
    }
  }

  /// تحديث عدد النقرات عند الضغط على الإعلان
  Future<void> recordClick(String adId) async {
    await http.post(
      Uri.parse(ApiConstants.updateAdClicks),
      body: {"ad_id": adId},
    );
  }
}
