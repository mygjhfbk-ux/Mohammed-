import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/ads_controller.dart';

class AdsView extends StatelessWidget {
  AdsView({super.key});
  final AdsController ctrl = Get.put(AdsController());

  @override
  Widget build(BuildContext context) {
    ctrl.fetchAds();
    return Scaffold(
      appBar: AppBar(title: Text('الإعلانات')),
      body: Obx(() {
        if (ctrl.isLoading.value) return Center(child: CircularProgressIndicator());
        if (ctrl.ads.isEmpty) return Center(child: Text('لا توجد إعلانات'));
        return ListView.builder(
          itemCount: ctrl.ads.length,
          itemBuilder: (context, idx) {
            final a = ctrl.ads[idx];
            return ListTile(
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
          await Get.defaultDialog(
            title: 'إضافة إعلان',
            content: Column(
              children: [
                TextField(controller: titleCtrl, decoration: InputDecoration(labelText: 'العنوان')),
                TextField(controller: urlCtrl, decoration: InputDecoration(labelText: 'الرابط')),
              ],
            ),
            confirm: ElevatedButton(
              onPressed: () async {
                await ctrl.createAd(title: titleCtrl.text.trim(), url: urlCtrl.text.trim());
                Get.back();
              },
              child: Text('حفظ'),
            ),
            onCancel: () {},
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
