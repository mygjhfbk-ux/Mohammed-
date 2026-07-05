import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CustomersController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;
  var customers = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  Future<void> fetchCustomers({String? merchantId}) async {
    try {
      isLoading(true);
      var query = supabase.from('customers').select('*, profile:profiles(*)').order('created_at', ascending: false);
      if (merchantId != null) {
        query = query.eq('linked_merchant_id', merchantId);
      }
      final res = await query;
      customers.assignAll(List<Map<String, dynamic>>.from(res as List<dynamic>));
    } catch (e) {
      print('fetchCustomers error: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<bool> createCustomer({required String phone, required String name, String? linkedMerchantId}) async {
    try {
      isLoading(true);
      final profileRes = await supabase.from('profiles').insert({
        'phone': phone,
        'name': name,
        'user_type': 'customer',
      }).select().single();

      final profileId = profileRes['id'];

      await supabase.from('customers').insert({
        'profile_id': profileId,
        'linked_merchant_id': linkedMerchantId,
        'accepted': linkedMerchantId == null ? false : true,
      });

      await fetchCustomers(merchantId: linkedMerchantId);
      return true;
    } catch (e) {
      print('createCustomer error: $e');
      return false;
    } finally {
      isLoading(false);
    }
  }

  Future<bool> updateCustomer(String id, Map<String, dynamic> changes) async {
    try {
      isLoading(true);
      await supabase.from('customers').update(changes).eq('id', id);
      await fetchCustomers();
      return true;
    } catch (e) {
      print('updateCustomer error: $e');
      return false;
    } finally {
      isLoading(false);
    }
  }

  Future<bool> deleteCustomer(String id) async {
    try {
      isLoading(true);
      await supabase.from('customers').delete().eq('id', id);
      await fetchCustomers();
      return true;
    } catch (e) {
      print('deleteCustomer error: $e');
      return false;
    } finally {
      isLoading(false);
    }
  }
}
