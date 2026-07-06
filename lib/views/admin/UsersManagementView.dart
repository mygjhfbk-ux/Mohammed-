import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_controller/UsersManagementController.dart';

class UsersManagementView extends GetView<UsersManagementController> {
  const UsersManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("إدارة المستخدمين",
              style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          elevation: 0,
          bottom: const TabBar(
            tabs: [
              Tab(text: "التجار"),
              Tab(text: "العملاء"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildUserList(controller.merchantsList),
            _buildUserList(controller.customersList),
          ],
        ),
      ),
    );
  }

  Widget _buildUserList(RxList users) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (users.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people_outline, size: 80, color: Colors.grey[300]),
              const Text("لا يوجد مستخدمون", style: TextStyle(color: Colors.grey)),
            ],
          ),
        );
      }
      return Directionality(
        textDirection: TextDirection.rtl,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            final profile = user['user_profiles'] ?? user;
            return Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF07477E).withOpacity(0.1),
                  child: Text(
                    (profile['full_name'] ?? "?")[0],
                    style: const TextStyle(color: Color(0xFF07477E), fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(profile['full_name'] ?? "مستخدم",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(profile['phone'] ?? ""),
                trailing: PopupMenuButton(
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'block', child: Text("تعليق")),
                    const PopupMenuItem(value: 'delete', child: Text("حذف", style: TextStyle(color: Colors.red))),
                  ],
                  onSelected: (v) {
                    if (v == 'block') {
                      controller.toggleUserStatus(profile['id'].toString());
                    } else if (v == 'delete') {
                      controller.deleteUser(profile['id'].toString());
                    }
                  },
                ),
              ),
            );
          },
        ),
      );
    });
  }
}
