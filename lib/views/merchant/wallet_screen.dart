import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../controllers/merchant_controller/wallet_controller.dart';
import 'add_wallet_dialog.dart';

class WalletScreen extends StatelessWidget {
  final controller = Get.find<WalletController>();
  final Color primaryColor = const Color(0xFF07477E);
  final box = GetStorage();

  WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    controller.fetchWallets(box.read("Profile-id") ?? "");

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: Text("وسائل السداد المتاحة",
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 18)),
        leading: BackButton(color: primaryColor),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.blue.withOpacity(0.05),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                        "هذه الحسابات تظهر للعملاء ليتمكنوا من تحويل مبالغ السداد إليها.",
                        style: TextStyle(fontSize: 12, color: Colors.blueGrey)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: () => showAddWalletDialog(),
                icon: const Icon(Icons.add_rounded, color: Colors.white),
                label: const Text("إضافة حساب / محفظة",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.wallets.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.wallets.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.account_balance_wallet_outlined,
                            size: 80, color: Colors.grey[300]),
                        const Text("لم تقم بإضافة أي محافظ بعد",
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: controller.wallets.length,
                  itemBuilder: (context, index) =>
                      _buildWalletCard(controller.wallets[index]),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletCard(dynamic wallet) {
    final type   = wallet['wallet_type'] ?? "أخرى";
    final number = wallet['wallet_number'] ?? "000000";

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: Colors.grey.shade200)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: primaryColor.withOpacity(0.1),
          child: Icon(_iconForType(type), color: primaryColor),
        ),
        title: Text(type, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(number,
            style: TextStyle(color: Colors.grey[700], fontSize: 16, letterSpacing: 1.2)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.copy_rounded, size: 20, color: Colors.blueGrey),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: number));
                Get.snackbar("تم النسخ", "تم نسخ الرقم إلى الحافظة");
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Colors.redAccent),
              onPressed: () => _confirmDelete(wallet['id']),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconForType(String type) {
    if (type.contains("كريمي")) return Icons.account_balance;
    if (type.contains("كاش"))   return Icons.send_to_mobile;
    return Icons.wallet_rounded;
  }

  void _confirmDelete(dynamic id) {
    Get.defaultDialog(
      title: "تأكيد الحذف",
      middleText: "هل أنت متأكد من حذف هذه الوسيلة؟",
      textConfirm: "حذف",
      textCancel: "إلغاء",
      confirmTextColor: Colors.white,
      buttonColor: Colors.redAccent,
      onConfirm: () {
        controller.deleteWallet(id.toString());
        Get.back();
      },
    );
  }
}
