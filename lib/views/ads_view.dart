import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/ads_controller.dart';
import 'package:image_picker/image_picker.dart';

class AdsView extends StatefulWidget {
  AdsView({super.key});

  @override
  State<AdsView> createState() => _AdsViewState();
}

class _AdsViewState extends State<AdsView> {
  final AdsController ctrl = Get.put(AdsController());
  XFile? _picked;

  @override
  void initState() {
    super.initState();
    ctrl.fetchAds();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الإعلانات')),
      body: Obx(() {
        if (ctrl.isLoading.value) return const Center(child: CircularProgressIndicator());
        if (ctrl.ads.isEmpty) return const Center(child: Text('لا توجد إعلانات'));
        return ListView.builder(
          itemCount: ctrl.ads.length,
          itemBuilder: (context, idx) {
            final a = ctrl.ads[idx];
            return ListTile(
              leading: a['image_path'] != null
                  ? CachedNetworkImage(imageUrl: a['image_path'], width: 64, height: 64, fit: BoxFit.cover, placeholder: (_, __) => const CircularProgressIndicator(), errorWidget: (_, __, ___) => const Icon(Icons.broken_image))
                  : const Icon(Icons.image),
              title: Text(a['title'] ?? 'إعلان'),
              subtitle: Text(a['url'] ?? ''),
              trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () => ctrl.deleteAd(a['id'])),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final titleCtrl = TextEditingController();
          final urlCtrl = TextEditingController();

          await Get.bottomSheet(
            StatefulBuilder(builder: (context, setState) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(12))),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'العنوان')),
                    TextField(controller: urlCtrl, decoration: const InputDecoration(labelText: 'الرابط')),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () async {
                            final ImagePicker picker = ImagePicker();
                            final XFile? picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                            if (picked != null) setState(() => _picked = picked);
                          },
                          icon: const Icon(Icons.photo),
                          label: const Text('اختر صورة'),
                        ),
                        const SizedBox(width: 12),
                        _picked != null ? const Text('تم اختيار صورة') : const Text('لم يتم اختيار صورة')
                      ],
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () async {
                        await ctrl.createAd(title: titleCtrl.text.trim(), imageFile: _picked, url: urlCtrl.text.trim());
                        setState(() => _picked = null);
                        Get.back();
                      },
                      child: const Text('حفظ'),
                    )
                  ],
                ),
              );
            }),
            isScrollControlled: true,
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
