import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_controller/UsersManagementController.dart';
import 'AdminRegisterView.dart';

/// واجهة ادارة المستخدمين
class UsersManagementView extends GetView<UsersManagementController> {

   const UsersManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // الكل، تجار، عملاء
      child: Scaffold(
        appBar: AppBar(
          title: const Text("إدارة المستخدمين"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "المدراء"),
              Tab(text: "التجار"),
              Tab(text: "العملاء"),
            ],
            indicatorColor: Colors.orange,

          ),
          actions: [
            IconButton(
              onPressed: () async {
                // ننتظر حتى يتم إغلاق صفحة التسجيل
                await Get.to(() => AdminRegisterView());
                // بمجرد العودة لهذه الصفحة، نقوم بتحديث القائمة
                controller.fetchUsers();
              },
              icon: const Icon(Icons.add_circle),
            )

          ],
        ),
        body: Column(
          children: [
            // شريط البحث
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextField(
                onChanged: (val) => controller.searchUser(val),
                decoration: InputDecoration(
                  hintText: "ابحث باسم المستخدم أو رقم الهاتف...",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),

            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
                return TabBarView(
                  children: [
                    _buildUserList(userType: 'admin'),    // تبويب الأدمن
                    _buildUserList(userType: 'merchant'), // تبويب التجار
                    _buildUserList(userType: 'customer'), // تبويب العملاء
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

   Widget _buildUserList({required String userType}) {
     return Obx(() {
       var list = controller.filteredUsers.where((u) => u['User-type'] == userType).toList();

       if (list.isEmpty) {
         return Center(child: Text("لا يوجد مستخدمين حالياً"));
       }

       return ListView.builder(
         itemCount: list.length,
         itemBuilder: (context, index) {
           var user = list[index];
           bool isActive = user['is_active'].toString() == "1";

           // جلب بيانات الاشتراك (نفترض أنها تأتي مع بيانات المستخدم من السيرفر)
           String? expiryDate = user['end_at'];
           bool isSubscribed = expiryDate != null && DateTime.parse(expiryDate).isAfter(DateTime.now());

           return Card(
             margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
             child: ListTile(
               leading: CircleAvatar(
                 backgroundColor: userType == 'merchant' ? Colors.blue[100] : Colors.green[100],
                 child: Icon(
                   userType == 'merchant' ? Icons.store : Icons.person,
                   color: userType == 'merchant' ? Colors.blue : Colors.green,
                 ),
               ),
               title: Text(user['User-Name'], style: const TextStyle(fontWeight: FontWeight.bold)),
               subtitle: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Text(user['User-phone']),
                   if (userType == 'merchant') // عرض حالة الاشتراك للتاجر فقط
                     Padding(
                       padding: const EdgeInsets.only(top: 4.0),
                       child: Text(
                         isSubscribed ? "ينتهي في: $expiryDate" : "الاشتراك: منتهٍ أو غير مفعل",
                         style: TextStyle(
                             fontSize: 11,
                             color: isSubscribed ? Colors.blue[800] : Colors.grey[600],
                             fontWeight: isSubscribed ? FontWeight.bold : FontWeight.normal
                         ),
                       ),
                     ),
                 ],
               ),
               trailing: Row( // استخدمنا Row هنا لإضافة زر الاشتراك بجانب الـ Switch
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   if (userType == 'merchant') // زر إدارة الاشتراك يظهر للتجار فقط
                     IconButton(
                       icon: const Icon(Icons.card_membership, color: Colors.amber),
                       onPressed: () => _showSubscriptionDialog(user),
                       tooltip: "إدارة الاشتراك",
                     ),
                   const VerticalDivider(), // فاصل بسيط
                   Column(
                     mainAxisSize: MainAxisSize.min,
                     children: [
                       SizedBox(
                         height: 30,
                         child: Switch(
                           value: isActive,
                           activeColor: Colors.green,
                           inactiveThumbColor: Colors.red,
                           onChanged: (val) {
                             controller.toggleUserStatus(user['User-id'].toString(), val ? "1" : "0");
                           },
                         ),
                       ),
                       Text(isActive ? "نشط" : "محظور", style: TextStyle(fontSize: 10, color: isActive ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
                     ],
                   ),
                 ],
               ),
             ),
           );
         },
       );
     });
   }

   void _showSubscriptionDialog(Map user) {
     String selectedPeriod = 'monthly';
     final TextEditingController amountController = TextEditingController();

     Get.dialog(
       AlertDialog(
         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
         title: Text("اشتراك: ${user['User-Name']}"),
         content: Column(
           mainAxisSize: MainAxisSize.min,
           children: [
             const Text("اختر مدة التجديد للتاجر:"),
             const SizedBox(height: 15),
             DropdownButtonFormField<String>(
               value: selectedPeriod,
               items: const [
                 DropdownMenuItem(value: 'monthly', child: Text("شهر واحد")),
                 DropdownMenuItem(value: 'annual', child: Text("سنة كاملة")),
               ],
               onChanged: (val) => selectedPeriod = val!,
               decoration: const InputDecoration(border: OutlineInputBorder(), labelText: "المدة"),
             ),
             const SizedBox(height: 15),
             TextField(
               controller: amountController,
               keyboardType: TextInputType.number,
               decoration: const InputDecoration(
                 border: OutlineInputBorder(),
                 labelText: "المبلغ المدفوع (اختياري)",
                 prefixIcon: Icon(Icons.money),
               ),
             ),
           ],
         ),
         actions: [
           TextButton(onPressed: () => Get.back(), child: const Text("إلغاء")),
           ElevatedButton(
             style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[800]),
             onPressed: () {
               // استدعاء دالة التفعيل في الكنترولر
               controller.activateMerchantSubscription(
                 userId: user['User-id'].toString(),
                 period: selectedPeriod,
                 amount: amountController.text,
               );
               Get.back();
             },
             child: const Text("تفعيل الاشتراك", style: TextStyle(color: Colors.white)),
           ),
         ],
       ),
     );
   }

}
