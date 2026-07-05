import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/notifications_controller.dart';

class NotificationsView extends StatelessWidget {
  NotificationsView({super.key, required this.profileId});
  final String profileId;
  final NotificationsController ctrl = Get.put(NotificationsController());

  @override
  Widget build(BuildContext context) {
    ctrl.fetchNotifications(profileId);
    return Scaffold(
      appBar: AppBar(title: Text('الإشعارات')),
      body: Obx(() {
        if (ctrl.isLoading.value) return Center(child: CircularProgressIndicator());
        if (ctrl.notifications.isEmpty) return Center(child: Text('لا توجد إشعارات'));
        return ListView.builder(
          itemCount: ctrl.notifications.length,
          itemBuilder: (context, idx) {
            final n = ctrl.notifications[idx];
            return ListTile(
              title: Text(n['title'] ?? ''),
              subtitle: Text(n['body'] ?? ''),
              trailing: n['is_read'] == true ? null : IconButton(icon: Icon(Icons.mark_email_read), onPressed: () => ctrl.markRead(n['id'], profileId: profileId)),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final titleCtrl = TextEditingController();
          final bodyCtrl = TextEditingController();
          await Get.defaultDialog(
            title: 'إرسال إشعار',
            content: Column(
              children: [
                TextField(controller: titleCtrl, decoration: InputDecoration(labelText: 'العنوان')),
                TextField(controller: bodyCtrl, decoration: InputDecoration(labelText: 'المحتوى')),
              ],
            ),
            confirm: ElevatedButton(
              onPressed: () async {
                await ctrl.createNotification(profileId: profileId, title: titleCtrl.text.trim(), body: bodyCtrl.text.trim());
                Get.back();
              },
              child: Text('إرسال'),
            ),
            onCancel: () {},
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
