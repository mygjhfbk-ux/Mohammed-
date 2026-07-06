import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/customer_controller/merchant_controller.dart';

class MerchantWalletsView extends StatefulWidget {
  const MerchantWalletsView({super.key});

  @override
  State<MerchantWalletsView> createState() => _MerchantWalletsViewState();
}

class _MerchantWalletsViewState extends State<MerchantWalletsView> {
  final controller = Get.find<MerchantController>();
  final Color primaryColor = const Color(0xFF1A4D7E);

  @override
  void initState() {
    super.initState();
    final args = Get.arguments ?? {};
    final merchantId = args['merchantId']?.toString() ?? '';
    if (merchantId.isNotEmpty) controller.fetchMerchantWallets(merchantId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: Text("طرق السداد المتاحة",
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
        leading: const BackButton(),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.merchantWallets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.account_balance_wallet_outlined, size: 80, color: Colors.grey[300]),
                  const Text("لم يضف التاجر وسائل سداد بعد",
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.merchantWallets.length,
            itemBuilder: (context, index) {
              final wallet = controller.merchantWallets[index];
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
                    child: Icon(Icons.wallet_rounded, color: primaryColor),
                  ),
                  title: Text(wallet['wallet_type'] ?? "محفظة",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(wallet['wallet_number'] ?? "",
                      style: TextStyle(
                          color: Colors.grey[700], fontSize: 16, letterSpacing: 1.2)),
                  trailing: IconButton(
                    icon: const Icon(Icons.copy_rounded, size: 20, color: Colors.blueGrey),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: wallet['wallet_number'] ?? ""));
                      Get.snackbar("تم النسخ", "تم نسخ الرقم");
                    },
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
