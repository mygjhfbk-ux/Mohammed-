import 'package:get_storage/get_storage.dart';
import '/widgets/build_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/merchant_controller/add_customer_controller.dart';

/// واجهة تعديل وربط العملاء لدى التاجر
class EditCustomerView extends StatefulWidget {
  const EditCustomerView({super.key});

  @override
  State<EditCustomerView> createState() => _EditCustomerViewState();
}

class _EditCustomerViewState extends State<EditCustomerView> {
  final  controller = Get.find<AddCustomerController>();
  late int requestId;
  final box = GetStorage();


  @override
  void initState() {
    super.initState();
    // استقبال البيانات القادمة من شاشة "إدارة العملاء"
    var data = Get.arguments;
    requestId = data['Request-id'];
    controller.nameController.text = data['name'] ?? "";
    controller.addressController.text = data['address'] ?? "";
    controller.limitController.text = data['account_limit'].toString();
    controller.isActive.value = data['is_active'] ?? 0;
    controller.phoneController.text = data['phone'] ?? "0";

  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("بيانات العميل", style: TextStyle(color: Color(0xFF1A4D7E), fontWeight: FontWeight.bold)),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
          leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Get.back()),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              BuildTextField(
                icon: Icons.person,
                hint: "الاسم",
                controller: controller.nameController,
              ),
              const SizedBox(height: 20),
              if (controller.phoneController.text == "0" && box.read("isLocal") == true)
              BuildTextField(
                icon: Icons.phone_android,
                hint: "رقم الهاتف",
                controller: controller.phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 9,
              ) ,
              const SizedBox(height: 20),
              BuildTextField(
                  icon: Icons.location_on,
                  hint: "العنوان",
                controller: controller.addressController,
              ),
              const SizedBox(height: 20),
              BuildTextField(
                icon: Icons.account_balance_wallet,
                hint: "سقف الحساب",
                controller: controller.limitController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              _buildStatusDropdown(),
              const SizedBox(height: 40),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return Obx(() => DropdownButtonFormField<int>(
      value: controller.isActive.value,
      decoration: InputDecoration(labelText: "حالة الحساب", border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
      items: const [
        DropdownMenuItem(value: 1, child: Text("نشط")),
        DropdownMenuItem(value: 0, child: Text("موقف")),
      ],
      onChanged: (v) => controller.isActive.value = v!,
    ));
  }

  Widget _buildSubmitButton() {
    return Obx(() => SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00467F), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        onPressed: controller.isLoading.value ? null : ()
        {
          controller.updateCustomerRequest(requestId);
        },
        child: controller.isLoading.value
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text("تعديل بيانات عميل", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    ));
  }
}
