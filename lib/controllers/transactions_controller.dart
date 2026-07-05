import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TransactionsController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;
  var transactions = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  Future<void> fetchTransactions({String? merchantId, String? customerId}) async {
    try {
      isLoading(true);
      var query = supabase.from('transactions').select('*, customer:customers(*), wallet:wallets(*)').order('created_at', ascending: false);
      if (merchantId != null) query = query.eq('merchant_id', merchantId);
      if (customerId != null) query = query.eq('customer_id', customerId);
      final res = await query;
      transactions.assignAll(List<Map<String, dynamic>>.from(res as List<dynamic>));
    } catch (e) {
      print('fetchTransactions error: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<bool> addTransaction({required String merchantId, required String customerId, required String walletId, required double amount, required String type, String? notes}) async {
    try {
      isLoading(true);

      // Use RPC to ensure atomic update of transaction + wallet balance
      final rpcRes = await supabase.rpc('add_transaction_and_update_wallet', params: {
        'p_merchant_id': merchantId,
        'p_customer_id': customerId,
        'p_wallet_id': walletId,
        'p_amount': amount,
        'p_type': type,
        'p_notes': notes,
      });

      // Refresh list
      await fetchTransactions(merchantId: merchantId);
      return true;
    } catch (e) {
      print('addTransaction error (rpc): $e');
      // fallback: try simple insert
      try {
        await supabase.from('transactions').insert({
          'merchant_id': merchantId,
          'customer_id': customerId,
          'wallet_id': walletId,
          'amount': amount,
          'type': type,
          'notes': notes,
        });
        await fetchTransactions(merchantId: merchantId);
        return true;
      } catch (ex) {
        print('addTransaction fallback error: $ex');
        return false;
      }
    } finally {
      isLoading(false);
    }
  }

  Future<bool> updateTransaction(String id, Map<String, dynamic> changes, {String? merchantId}) async {
    try {
      isLoading(true);
      await supabase.from('transactions').update(changes).eq('id', id);
      if (merchantId != null) await fetchTransactions(merchantId: merchantId);
      return true;
    } catch (e) {
      print('updateTransaction error: $e');
      return false;
    } finally {
      isLoading(false);
    }
  }

  Future<bool> deleteTransaction(String id, {String? merchantId}) async {
    try {
      isLoading(true);
      await supabase.from('transactions').delete().eq('id', id);
      if (merchantId != null) await fetchTransactions(merchantId: merchantId);
      return true;
    } catch (e) {
      print('deleteTransaction error: $e');
      return false;
    } finally {
      isLoading(false);
    }
  }
}
