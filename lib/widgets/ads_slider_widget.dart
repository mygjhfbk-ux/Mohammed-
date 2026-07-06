import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/ads_controller.dart';

class AdsSliderWidget extends GetView<AdsController> {
  const AdsSliderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const SizedBox(height: 140, child: Center(child: CircularProgressIndicator()));
      }
      if (controller.adsList.isEmpty) return const SizedBox.shrink();

      final pageController = PageController(viewportFraction: 0.88);

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: SizedBox(
          height: 140,
          child: PageView.builder(
            controller: pageController,
            itemCount: controller.adsList.length,
            itemBuilder: (context, index) {
              final ad = controller.adsList[index];
              return GestureDetector(
                onTap: () => controller.recordClick(ad.id),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ad.imageUrl != null
                            ? CachedNetworkImage(imageUrl: ad.imageUrl!, fit: BoxFit.cover,
                                placeholder: (_, __) => Container(color: Colors.grey[200]),
                                errorWidget: (_, __, ___) => Container(color: const Color(0xFF1565C0),
                                    child: const Icon(Icons.image, color: Colors.white, size: 40)))
                            : Container(color: const Color(0xFF1565C0),
                                child: const Icon(Icons.campaign, color: Colors.white, size: 40)),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter, end: Alignment.topCenter,
                              colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                            ),
                          ),
                        ),
                        if (ad.title != null)
                          Positioned(
                            bottom: 12, right: 12,
                            child: Text(ad.title!,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    });
  }
}
