import 'package:app_merchant_customer/core/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';


class AdsManagementController extends GetxController {
  var allAds = [].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    fetchAllAds();
    super.onInit();
  }

  // جلب الإعلانات للمدير
  Future<void> fetchAllAds() async {
    isLoading(true);
    var response = await http.get(Uri.parse(ApiConstants.getAdsStatus));
    if (response.statusCode == 200) {
      allAds.assignAll(json.decode(response.body)['data']);
    }
    isLoading(false);
  }

  // إضافة إعلان جديد (Multipart Request لرفع الصورة)
  Future<void> uploadAd(String title, String link, File imageFile) async {
    var request = http.MultipartRequest('POST', Uri.parse(ApiConstants.addAds));
    request.fields['title'] = title;
    request.fields['link'] = link;
    request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

    var response = await request.send();
    if (response.statusCode == 200) {
      Get.back(); // إغلاق واجهة الإضافة
      fetchAllAds(); // تحديث القائمة
      Get.snackbar("نجاح", "تم نشر الإعلان بنجاح");
    }
  }

var selectedImage = Rxn<File>(); // متغير لحفظ الصورة المختارة
  final picker = ImagePicker();

  // دالة اختيار الصورة من المعرض
  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      selectedImage.value = File(pickedFile.path);
    }
  }

  // حذف إعلان
  Future<void> deleteAd(int id) async {
     // كود حذف الإعلان من السيرفر...
     allAds.removeWhere((element) => element['ad_id'] == id);
  }

  Future<void> toggleAdStatus(dynamic adId, int status) async {
    try {
      // افترضنا أن لديك API لتحديث الحالة
      var response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/ads/update_ad_status.php"),
        body: {
          "ad_id": adId.toString(),
          "is_active": status.toString(),
        },
      );

      if (json.decode(response.body)['status'] == 'success') {
        // تحديث البيانات محلياً فوراً ليشعر المستخدم بالسرعة
        int index = allAds.indexWhere((element) => element['ad_id'] == adId);
        if (index != -1) {
          allAds[index]['is_active'] = status;
          allAds.refresh(); // مهم لتحديث الـ UI في GetX
        }
        Get.snackbar("تم", "تم تحديث حالة الإعلان بنجاح",
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("خطأ", "فشل في تحديث الحالة");
    }
  }

}
