import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/merchant_controller/wallet_controller.dart';

/// واجهة عرض حسابات الدفع الخا
class MerchantWalletsView extends StatefulWidget {
  const MerchantWalletsView({super.key});

  @override
  State<MerchantWalletsView> createState() => _MerchantWalletsViewState();
}

class _MerchantWalletsViewState extends State<MerchantWalletsView> {
  final  controller = Get.put(WalletController());
  final Color primaryColor = const Color(0xFF1A4D7E);
  int? merchantId;
@override
  void initState() {
    // TODO: implement initState
    super.initState();

      _initParams();

  }

  void _initParams() {

    final Map<String, dynamic>? args = Get.arguments;

    if (args != null) {
      merchantId = args['merchantId'];
    }

    // جلب البيانات بعد بناء الواجهة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (merchantId != null) {
        controller.fetchWallets(merchantId!);
      }
      else {

      }
    });

  }

  @override
  Widget build(BuildContext context) {
   return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FB),
        appBar: AppBar(
          title: const Text("المحافظ الإلكترونية للسداد",
              style: TextStyle(color: Color(0xFF1A4D7E), fontWeight: FontWeight.bold, fontSize: 18)),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0.5,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1A4D7E), size: 20),
            onPressed: () => Get.back(),
          ),
        ),
        body: Column(
          children: [
            _buildInfoNote(),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.wallets.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.wallets.isEmpty) {
                  return _buildEmptyState();
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  itemCount: controller.wallets.length,
                  itemBuilder: (context, index) {
                    return _buildWalletCard(controller.wallets[index]);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoNote() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade800, size: 20),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              "يمكنك نسخ رقم المحفظة لتسهيل عملية التحويل عبر تطبيقاتك البنكية.",
              style: TextStyle(fontSize: 12, color: Colors.blueGrey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletCard(dynamic wallet) {
    String walletName = wallet['wallet_type'] ?? "محفظة إلكترونية";
    String walletNumber = wallet['wallet_number'] ?? "0000000";

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(_getWalletIcon(walletName), color: primaryColor, size: 28),
        ),
        title: Text(
          walletName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            walletNumber,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
                letterSpacing: 1.5
            ),
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.copy_all_rounded, color: primaryColor.withOpacity(0.6)),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: walletNumber));
            Get.rawSnackbar(
              message: "تم نسخ الرقم: $walletNumber",
              backgroundColor: Colors.green.shade600,
              snackPosition: SnackPosition.BOTTOM,
              borderRadius: 10,
              margin: const EdgeInsets.all(15),
              icon: const Icon(Icons.check_circle, color: Colors.white),
            );
          },
        ),
      ),
    );
  }

  IconData _getWalletIcon(String name) {
    if (name.contains("كريمي") || name.contains("Kuraimi")) return Icons.account_balance_rounded;
    if (name.contains("جوالي") || name.contains("Jawaly")) return Icons.phone_android_rounded;
    if (name.contains("فلوسك") || name.contains("Floosak")) return Icons.account_balance_wallet_rounded;
    return Icons.payments_rounded;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_balance_wallet_outlined, size: 70, color: Colors.grey[300]),
          const SizedBox(height: 15),
          const Text("لا توجد محافظ مضافة حالياً", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
