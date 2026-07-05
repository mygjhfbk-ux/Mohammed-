import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WalletsController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;
  var wallets = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  Future<void> fetchWallets(String merchantId) async {
    try {
      isLoading(true);
      final res = await supabase.from('wallets').select().eq('merchant_id', merchantId).order('created_at', ascending: false);
      wallets.assignAll(List<Map<String, dynamic>>.from(res as List<dynamic>));
    } catch (e) {
      print('fetchWallets error: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<bool> createWallet({required String merchantId, required String name, double initialBalance = 0}) async {
    try {
      isLoading(true);
      await supabase.from('wallets').insert({
        'merchant_id': merchantId,
        'name': name,
        'balance': initialBalance,
      });
      await fetchWallets(merchantId);
      return true;
    } catch (e) {
      print('createWallet error: $e');
      return false;
    } finally {
      isLoading(false);
    }
  }

  Future<bool> updateWallet(String id, Map<String, dynamic> changes, {String? merchantId}) async {
    try {
      isLoading(true);
      await supabase.from('wallets').update(changes).eq('id', id);
      if (merchantId != null) await fetchWallets(merchantId);
      return true;
    } catch (e) {
      print('updateWallet error: $e');
      return false;
    } finally {
      isLoading(false);
    }
  }

  Future<bool> deleteWallet(String id, {String? merchantId}) async {
    try {
      isLoading(true);
      await supabase.from('wallets').delete().eq('id', id);
      if (merchantId != null) await fetchWallets(merchantId);
      return true;
    } catch (e) {
      print('deleteWallet error: $e');
      return false;
    } finally {
      isLoading(false);
    }
  }
}
