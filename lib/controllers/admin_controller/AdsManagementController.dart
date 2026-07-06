import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/app_constants.dart';
import '../../core/supabase_service.dart';

class AdsManagementController extends GetxController {
  var isLoading  = false.obs;
  var adsList    = [].obs;
  var pickedFile = Rxn<XFile>();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController linkController  = TextEditingController();

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
          .order('created_at', ascending: false);
      adsList.value = data;
    } catch (e) {
      print("AdsManagementController.fetchAds: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> pickImage() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file != null) pickedFile.value = file;
  }

  Future<void> addAd(String title) async {
    try {
      isLoading(true);
      String? imageUrl;

      if (pickedFile.value != null) {
        final bytes    = await pickedFile.value!.readAsBytes();
        final fileName = 'ad_${DateTime.now().millisecondsSinceEpoch}.jpg';
        await SupabaseService.client.storage.from('ads').uploadBinary(fileName, bytes);
        imageUrl = SupabaseService.client.storage.from('ads').getPublicUrl(fileName);
      }

      await SupabaseService.client.from(AppTables.ads).insert({
        'title':     title,
        'link':      linkController.text,
        'image_url': imageUrl,
        'is_active': true,
      });

      await fetchAds();
      titleController.clear();
      linkController.clear();
      pickedFile.value = null;
      Get.snackbar("نجاح", "تمت إضافة الإعلان",
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("خطأ", "فشل رفع الإعلان: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> toggleAdStatus(String adId, bool current) async {
    try {
      await SupabaseService.client
          .from(AppTables.ads)
          .update({'is_active': !current})
          .eq('id', adId);
      await fetchAds();
    } catch (e) {
      Get.snackbar("خطأ", "فشل تحديث حالة الإعلان");
    }
  }

  Future<void> deleteAd(String adId) async {
    try {
      await SupabaseService.client.from(AppTables.ads).delete().eq('id', adId);
      adsList.removeWhere((a) => a['id'].toString() == adId);
      Get.snackbar("تم", "تم حذف الإعلان",
          backgroundColor: Colors.orange, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("خطأ", "فشل الحذف");
    }
  }
}
