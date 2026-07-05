import 'dart:io';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../services/storage_service.dart';

class AdsController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;
  final StorageService storageService = StorageService();

  var ads = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  Future<void> fetchAds({String? merchantId}) async {
    try {
      isLoading(true);
      var query = supabase.from('ads').select().order('created_at', ascending: false);
      if (merchantId != null) query = query.eq('merchant_id', merchantId);
      final res = await query;
      ads.assignAll(List<Map<String, dynamic>>.from(res as List<dynamic>));
    } catch (e) {
      print('fetchAds error: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<bool> createAd({String? merchantId, required String title, XFile? imageFile, String? url}) async {
    try {
      isLoading(true);
      String? imagePath;
      if (imageFile != null) {
        imagePath = await storageService.uploadImage(imageFile, pathPrefix: 'ads');
      }

      await supabase.from('ads').insert({
        'merchant_id': merchantId,
        'title': title,
        'image_path': imagePath,
        'url': url,
      });
      await fetchAds(merchantId: merchantId);
      return true;
    } catch (e) {
      print('createAd error: $e');
      return false;
    } finally {
      isLoading(false);
    }
  }

  Future<bool> updateAd(String id, Map<String, dynamic> changes, {String? merchantId}) async {
    try {
      isLoading(true);
      await supabase.from('ads').update(changes).eq('id', id);
      if (merchantId != null) await fetchAds(merchantId: merchantId);
      return true;
    } catch (e) {
      print('updateAd error: $e');
      return false;
    } finally {
      isLoading(false);
    }
  }

  Future<bool> deleteAd(String id, {String? merchantId}) async {
    try {
      isLoading(true);
      await supabase.from('ads').delete().eq('id', id);
      if (merchantId != null) await fetchAds(merchantId: merchantId);
      return true;
    } catch (e) {
      print('deleteAd error: $e');
      return false;
    } finally {
      isLoading(false);
    }
  }
}
