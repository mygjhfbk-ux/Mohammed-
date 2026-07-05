import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MerchantsController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;
  var merchants = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMerchants();
  }

  Future<void> fetchMerchants() async {
    try {
      isLoading(true);
      final res = await supabase.from('merchants').select('*, profile:profiles(*)').order('created_at', ascending: false);
      merchants.assignAll(List<Map<String, dynamic>>.from(res as List<dynamic>));
    } catch (e) {
      print('fetchMerchants error: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<bool> createMerchant({required String phone, required String name, required String businessName}) async {
    try {
      isLoading(true);
      // create profile first
      final profileRes = await supabase.from('profiles').insert({
        'phone': phone,
        'name': name,
        'user_type': 'merchant',
        'business_name': businessName,
      }).select().single();

      final profileId = profileRes['id'];

      final merchantRes = await supabase.from('merchants').insert({
        'profile_id': profileId,
        'merchant_name': businessName,
      }).select().single();

      await fetchMerchants();
      return true;
    } catch (e) {
      print('createMerchant error: $e');
      return false;
    } finally {
      isLoading(false);
    }
  }

  Future<bool> updateMerchant(String id, Map<String, dynamic> changes) async {
    try {
      isLoading(true);
      await supabase.from('merchants').update(changes).eq('id', id);
      await fetchMerchants();
      return true;
    } catch (e) {
      print('updateMerchant error: $e');
      return false;
    } finally {
      isLoading(false);
    }
  }

  Future<bool> deleteMerchant(String id) async {
    try {
      isLoading(true);
      await supabase.from('merchants').delete().eq('id', id);
      await fetchMerchants();
      return true;
    } catch (e) {
      print('deleteMerchant error: $e');
      return false;
    } finally {
      isLoading(false);
    }
  }
}
