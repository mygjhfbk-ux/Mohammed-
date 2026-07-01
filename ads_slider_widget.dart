import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../controllers/ads_controller.dart';
import '../core/api_constants.dart';

class AdsSliderWidget extends GetView<AdsController> {

   const AdsSliderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const SizedBox(
          height: 140,
          child: Center(child: CircularProgressIndicator()),
        );
      }

      if (controller.adsList.isEmpty) {
        return const SizedBox.shrink();
      }

      // تحديد ما إذا كان يجب تفعيل الدوران اللانهائي
      // إذا كان هناك إعلان واحد فقط، نوقف الدوران التلقائي واللانهائي لمنع التكرار
      bool shouldScroll = controller.adsList.length > 1;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: CarouselSlider(
          options: CarouselOptions(
            height: 140.0,
            // تفعيل الحركة التلقائية فقط إذا كان هناك أكثر من إعلان
            autoPlay: shouldScroll,
            enlargeCenterPage: true,
            autoPlayCurve: Curves.fastOutSlowIn,
            // هذا هو السطر الحاسم: نلغي اللانهائية إذا كان العدد قليلاً لمنع التكرار الوهمي
            enableInfiniteScroll: shouldScroll,
            viewportFraction: 0.85,
            // التوقف عن العمل عند الانتهاء من القائمة إذا لم يكن لانهائياً
            onPageChanged: (index, reason) {
              // منطق إضافي اختياري
            },
          ),
          items: controller.adsList.map((ad) {
            return GestureDetector(
              key: ValueKey(ad.id), // إضافة Key فريد لكل بطاقة لضمان عدم تداخل العناصر
              onTap: () {
                controller.recordClick(ad.id);
              },
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  image: DecorationImage(
                    // تأكد من أن الرابط لا يحتوي على تكرار لـ "uploads/ads" إذا كانت موجودة في الـ baseUrl
                    image: NetworkImage("${ApiConstants.baseUrl}${ad.image}"),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(12),
                  alignment: Alignment.bottomRight,
                  child: Text(
                    ad.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
    });
  }

}
