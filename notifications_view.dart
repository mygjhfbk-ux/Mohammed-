import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../controllers/customer_controller/notification_controller.dart';

/// واجهة عرض الاشعارات
class NotificationsView extends GetView<NotificationController> {

  final Color primaryColor = const Color(0xFF1A4D7E);
  final box = GetStorage();


  NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    var a = box.read("User-id");
    controller.fetchNotifications(a);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FB),
        appBar: AppBar(
          title: const Text("الإشعارات",
              style: TextStyle(color: Color(0xFF1A4D7E), fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0.5,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1A4D7E), size: 20),
            onPressed: () => Get.back(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                controller.markAllAsRead();
              }, // استدعاء دالة قراءة الكل
              child: const Text("قراءة الكل", style: TextStyle(color: Colors.blue)),
            )
          ],
        ),
        body: Column(
          children: [
            // شريط الفلاتر المحدث بناءً على حالة القراءة
            _buildFilterBar(),

            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.filteredNotifications.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: controller.filteredNotifications.length,
                  itemBuilder: (context, index) {
                    var notif = controller.filteredNotifications[index];
                    return _buildNotificationCard(notif);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    // تم تغيير الفلاتر لتطابق منطق Not-isread
    final filters = ["الكل", "غير مقروء", "مقروء"];
    return Container(
      height: 65,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: filters.length,
        itemBuilder: (context, index) => _buildFilterChip(filters[index]),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    return Obx(() {
      bool isSelected = controller.selectedFilter.value == label;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        child: InkWell(
          onTap: () => controller.filterNotifications(label),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
              color: isSelected ? primaryColor : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: Text(label,
                style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black54,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
                )),
          ),
        ),
      );
    });
  }
  
  Widget _buildNotificationCard(Map not) {
    bool isUnread = not['is_read'].toString() == "0";

    return InkWell(
      onTap: () {
        controller.markAsRead(not['id']);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUnread ? Colors.blue.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isUnread ? Colors.blue.shade100 : Colors.grey.shade200),
          boxShadow: isUnread ? [BoxShadow(color: Colors.blue.withOpacity(0.05), blurRadius: 5)] : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: isUnread ? primaryColor.withOpacity(0.1) : Colors.grey.shade100,
              child: Icon(
                isUnread ? Icons.notifications_active_rounded : Icons.notifications_none_rounded,
                color: isUnread ? primaryColor : Colors.grey,
                size: 20,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("إشعار جديد",
                          style: TextStyle(
                              fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                              fontSize: 15,
                              color: isUnread ? Colors.black : Colors.black54
                          )),
                      if (isUnread) const Icon(Icons.circle, color: Colors.blue, size: 8),
                    ],
                  ),
                  const SizedBox(height: 5),
                  // استخدام الحقل الصحيح Not-content من جدولك
                  Row(
                    children: [
                      Expanded(
                        child: Text(not['content'] ?? "",
                            style: TextStyle(
                                color: isUnread ? Colors.black87 : Colors.grey[600],
                                fontSize: 13,
                                height: 1.4
                            )),
                      ),
                      Text(not['sender_name'] ?? "",
                          style: TextStyle(
                              color: isUnread ? Colors.black87 : primaryColor,
                              fontSize: 15,
                              height: 1.4
                          )),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // التنسيق التاريخ المتاح في قاعدة بياناتك
                  Text("${not['created_at'] ?? ''}",
                      style: TextStyle(color: Colors.grey[400], fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none_rounded, size: 80, color: Colors.grey[200]),
          const SizedBox(height: 10),
          const Text("صندوق الإشعارات فارغ", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
