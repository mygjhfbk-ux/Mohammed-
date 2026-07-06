import 'package:get/get.dart';
import '../core/app_constants.dart';
import '../core/supabase_service.dart';
import '../models/ad_model.dart';

class AdsController extends GetxController {
  var adsList = <AdModel>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    fetchAds();
    super.onInit();
  }

  Future<void> fetchAds() async {
    try {
      isLoading(true);
      final data = await SupabaseService.client
          .from(AppTables.ads)
          .select()
          .eq('is_active', true)
          .order('created_at', ascending: false);

      adsList.assignAll((data as List).map((e) => AdModel.fromJson(e)).toList());
    } catch (e) {
      print('Error fetching ads: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> recordClick(String adId) async {
    try {
      await SupabaseService.client.rpc('increment_ad_clicks', params: {'ad_id': adId});
    } catch (_) {}
  }
}
