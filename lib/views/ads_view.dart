import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/ads_controller.dart';

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
      appBar: AppBar(title: Text('الإعلانات')),
      body: Obx(() {
        if (ctrl.isLoading.value) return Center(child: CircularProgressIndicator());
        if (ctrl.ads.isEmpty) return Center(child: Text('لا توجد إ��لانات'));
        return ListView.builder(
          itemCount: ctrl.ads.length,
          itemBuilder: (context, idx) {
            final a = ctrl.ads[idx];
            return ListTile(
              leading: a['image_path'] != null
                  ? Image.network(a['image_path'], width: 56, height: 56, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(Icons.image))
                  : Icon(Icons.image),
              title: Text(a['title'] ?? 'إعلان'),
              subtitle: Text(a['url'] ?? ''),
              trailing: IconButton(icon: Icon(Icons.delete), onPressed: () => ctrl.deleteAd(a['id'])),
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
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: titleCtrl, decoration: InputDecoration(labelText: 'العنوان')),
                    TextField(controller: urlCtrl, decoration: InputDecoration(labelText: 'الرابط')),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () async {
                            final ImagePicker picker = ImagePicker();
                            final XFile? picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                            if (picked != null) setState(() => _picked = picked);
                          },
                          icon: Icon(Icons.photo),
                          label: Text('اختر صورة'),
                        ),
                        const SizedBox(width: 12),
                        _picked != null ? Text('تم اختيار صورة') : Text('لم يتم اختيار صورة')
                      ],
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () async {
                        await ctrl.createAd(title: titleCtrl.text.trim(), imageFile: _picked, url: urlCtrl.text.trim());
                        _picked = null;
                        Get.back();
                      },
                      child: Text('حفظ'),
                    )
                  ],
                ),
              );
            }),
            isScrollControlled: true,
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
