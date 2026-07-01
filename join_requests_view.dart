import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../controllers/customer_controller/merchant_controller.dart';

/// واجهة عرض طلبات الربط والموافقه خاصة بالعميل
class JoinRequestsView extends StatefulWidget {
  const JoinRequestsView({super.key});

  @override
  State<JoinRequestsView> createState() => _JoinRequestsViewState();
}

class _JoinRequestsViewState extends State<JoinRequestsView> {
  final controller = Get.put(MerchantController());
  final box = GetStorage();
  final Color primaryColor = const Color(0xFF104A81);
  int? userId;

  @override
  void initState() {
    super.initState();
    userId = box.read('User-id') ?? 0;
    if (userId != 0) {
      controller.fetchPendingRequests(userId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text("طلبات الربط", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Get.back(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => controller.fetchPendingRequests(userId!),
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
                    return _buildEmptyState();
                  }
                  return ListView.builder(
                    itemCount: controller.pendingRequests.length,
                    itemBuilder: (context, index) {
                      var req = controller.pendingRequests[index];
                      return _buildRequestCard(req);
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequestCard(dynamic req) {
    return Container(
      margin: const EdgeInsets.only(bottom : 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))
        ],
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
                    Text(req['Merchant-Name'] ?? "متجر غير معروف",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text("بتاريخ: ${req['request_date']}",
                        style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 25),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              controller.acceptRequest(req['Request-id'].toString(), userId!);
            },
            child: const Text("قبول ", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.mark_email_read_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 15),
          const Text("لا توجد طلبات انضمام حالياً", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
