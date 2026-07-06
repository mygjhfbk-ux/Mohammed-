import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/merchant_controller/merchant_customers_controller.dart';
import '../../widgets/build_text_field.dart';

class EditCustomerView extends StatefulWidget {
  EditCustomerView({super.key});

  @override
  State<EditCustomerView> createState() => _EditCustomerViewState();
}

class _EditCustomerViewState extends State<EditCustomerView> {
  final controller = Get.find<MerchantCustomersController>();
  final Color primaryColor = const Color(0xFF07477E);
  final nameCtrl    = TextEditingController();
  final limitCtrl   = TextEditingController();
  final addressCtrl = TextEditingController();
  final isActive    = true.obs;

  @override
  void initState() {
    super.initState();
    final data = Get.arguments ?? {};
    nameCtrl.text    = data['customer_name'] ?? "";
    limitCtrl.text   = data['account_limit']?.toString() ?? "";
    addressCtrl.text = data['address'] ?? "";
    isActive.value   = data['is_active'] ?? true;
  }

  @override
  Widget build(BuildContext context) {
    final data = Get.arguments ?? {};
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text("تعديل بيانات العميل",
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
        leading: BackButton(color: primaryColor),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              BuildTextField(
                  hint: "اسم العميل", icon: Icons.person_outline, controller: nameCtrl),
              const SizedBox(height: 15),
              BuildTextField(
                  hint: "سقف الدين",
                  icon: Icons.monetization_on_outlined,
                  controller: limitCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true)),
              const SizedBox(height: 15),
              BuildTextField(
                  hint: "العنوان", icon: Icons.location_on_outlined, controller: addressCtrl),
              const SizedBox(height: 20),
              Obx(() => SwitchListTile(
                    title: const Text("تفعيل الحساب"),
                    value: isActive.value,
                    activeColor: primaryColor,
                    onChanged: (v) => isActive.value = v,
                  )),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  controller.updateCustomer(
                    requestId:    data['id']?.toString() ?? "",
                    name:         nameCtrl.text,
                    limit:        double.tryParse(limitCtrl.text) ?? 0,
                    address:      addressCtrl.text,
                    isActive:     isActive.value,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text("حفظ التعديلات",
                    style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
