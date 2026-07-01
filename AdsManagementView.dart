import 'package:app_merchant_customer/core/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_controller/AdsManagementController.dart';


/// واجهة ادارة الاعلانات
class AdsManagementView extends GetView<AdsManagementController> {

  const AdsManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFF5F7F9), // خلفية هادئة
        appBar: AppBar(
          title: const Text("إدارة الإعلانات", style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFF07477E),
          centerTitle: true,
          elevation: 0,
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddAdDialog(context),
          backgroundColor: Colors.orange,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text("إعلان جديد", style: TextStyle(color: Colors.white)),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.allAds.isEmpty) {
            return const Center(child: Text("لا توجد إعلانات حالياً"));
          }

          return ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: controller.allAds.length,
              itemBuilder: (context, index) {
                var ad = controller.allAds[index];
                // تحويل القيمة القادمة من السيرفر إلى Boolean
                bool isActive = ad['is_active'].toString() == "1";

                return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                        child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                "${ApiConstants.baseUrl}/uploads/ads/${ad['ad_image']}",
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(width: 70, color: Colors.grey[300], child: const Icon(Icons.broken_image)),
                              ),
                            ),
                          title: Text(
                            ad['ad_title'],
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // const SizedBox(height: 4),
                              Row(
                                children: [
                                  Expanded(child: Icon(Icons.ads_click, size: 14, color: Colors.grey[600])),
                                  const SizedBox(width: 4),
                                  Text("النقرات: ${ad['click_count']}"),
                                ],
                              ),
                              const SizedBox(height: 4),
                              // مؤشر حالة الإعلان نصياً
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  isActive ? "نشط حالياً" : "متوقف",
                                  style: TextStyle(color: isActive ? Colors.green : Colors.red, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          trailing: Row(

                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // زر التفعيل والإيقاف
                              Switch(
                                value: isActive,
                                activeColor: Colors.green,
                                  onChanged: (val) {
                                    Get.defaultDialog(
                                      title: "تغيير حالة الإعلان",
                                      middleText: val ? "هل تريد تفعيل هذا الإعلان؟" : "هل تريد إيقاف هذا الإعلان؟",
                                      onConfirm: () {
                                        controller.toggleAdStatus(ad['ad_id'], val ? 1 : 0);
                                        Get.back();
                                      },
                                      textConfirm: "نعم",
                                      textCancel: "إلغاء",
                                    );
                                  }
                              ),
                              const VerticalDivider(),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                onPressed: () => _confirmDelete(ad['ad_id']),
                              ),
                            ],
                          ),
                        ),
                    ),
                );
              },
          );
        }),
    );
  }


  // نافذة تأكيد الحذف
  void _confirmDelete(var adId) {
    Get.defaultDialog(
      title: "تأكيد الحذف",
      middleText: "هل أنت متأكد من حذف هذا الإعلان نهائياً؟",
      textConfirm: "نعم، حذف",
      textCancel: "إلغاء",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        controller.deleteAd(adId);
        Get.back();
      },
    );
  }
// نافذة إضافة إعلان (Dialog)
  void _showAddAdDialog(BuildContext context) {
    final titleController = TextEditingController();
    final linkController = TextEditingController();

    // إعادة تعيين الصورة عند فتح النافذة
    controller.selectedImage.value = null;

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("إضافة إعلان جديد", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF07477E))),
              SizedBox(height: 20),

              // منطقة اختيار الصورة
              GestureDetector(
                onTap: () => controller.pickImage(),
                child: Obx(() => Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: controller.selectedImage.value == null
                      ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                      Text("اضغط لاختيار صورة الإعلان"),
                    ],
                  )
                      : ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.file(controller.selectedImage.value!, fit: BoxFit.cover),
                  ),
                )),
              ),

              SizedBox(height: 15),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: "عنوان الإعلان",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  prefixIcon: Icon(Icons.title),
                ),
              ),

              SizedBox(height: 10),
              TextField(
                controller: linkController,
                decoration: InputDecoration(
                  labelText: "الرابط أو المعرف (اختياري)",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  prefixIcon: Icon(Icons.link),
                ),
              ),

              SizedBox(height: 20),
              Obx(() => SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: controller.isLoading.value
                      ? null
                      : () {
                    if (titleController.text.isEmpty || controller.selectedImage.value == null) {
                      Get.snackbar("تنبيه", "يرجى كتابة العنوان واختيار صورة", snackPosition: SnackPosition.BOTTOM);
                      return;
                    }
                    controller.uploadAd(
                        titleController.text,
                        linkController.text,
                        controller.selectedImage.value!
                    );
                  },
                  child: controller.isLoading.value
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text("نشر الإعلان الآن", style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              )),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}





