import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../controllers/customer_controller/merchant_controller.dart';

class JoinRequestsView extends StatefulWidget {
  const JoinRequestsView({super.key});

  @override
  State<JoinRequestsView> createState() => _JoinRequestsViewState();
}

class _JoinRequestsViewState extends State<JoinRequestsView> {
  final controller = Get.find<MerchantController>();
  final box = GetStorage();
  final Color primaryColor = const Color(0xFF104A81);

  @override
  void initState() {
    super.initState();
    final userId = box.read('User-id');
    if (userId != null) controller.fetchPendingRequests(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text("طلبات الربط",
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: primaryColor),
            onPressed: () => Get.back()),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: RefreshIndicator(
          onRefresh: () async => controller.fetchPendingRequests(box.read('User-id') ?? ''),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text("طلبات الانضمام الواردة",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const Text("يمكنك قبول الطلب للبدء في تسجيل الديون أو رفضه",
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 20),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (controller.pendingRequests.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.mark_email_read_outlined, size: 80, color: Colors.grey[300]),
                            const SizedBox(height: 15),
                            const Text("لا توجد طلبات انضمام حالياً",
                                style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: controller.pendingRequests.length,
                      itemBuilder: (context, index) {
                        final req = controller.pendingRequests[index];
                        final merchant = req['merchants'] ?? {};
                        return _buildRequestCard(req, merchant);
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequestCard(dynamic req, dynamic merchant) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: primaryColor.withOpacity(0.1),
                child: Icon(Icons.storefront, color: primaryColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(merchant['merchant_name'] ?? "متجر غير معروف",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text("بتاريخ: ${req['created_at']?.toString().substring(0, 10) ?? ''}",
                        style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 25),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => controller.acceptRequest(req['id'].toString(), box.read('User-id') ?? ''),
                  child: const Text("قبول", style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => controller.rejectRequest(req['id'].toString()),
                  child: const Text("رفض", style: TextStyle(color: Colors.red)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
