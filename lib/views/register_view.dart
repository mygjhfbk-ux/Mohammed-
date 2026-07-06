import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../controllers/auth_controller.dart';
import '../widgets/build_text_field.dart';

class RegisterView extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();
  final nameController     = TextEditingController();
  final phoneController    = TextEditingController();
  final addressController  = TextEditingController();
  final passwordController = TextEditingController();
  final shopController     = TextEditingController();
  final isAgreed           = false.obs;
  final isCustomer         = false.obs;
  final box                = GetStorage();
  final RxBool isPasswordVisible = false.obs;
  final Color primaryColor = const Color(0xFF0D47A1);

  RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    isCustomer.value = box.read('User-type') == "merchant" ? false : true;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text("فتح حساب جديد",
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 18)),
        leading: BackButton(color: primaryColor),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.person_add_alt_1_rounded, size: 50, color: primaryColor),
              ),
              const SizedBox(height: 20),
              const Text("انضم إلى نظام ديوني",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const Text("سجل بياناتك لتبدأ في إدارة حساباتك",
                  style: TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 35),
              BuildTextField(
                  hint: "الاسم الرباعي",
                  icon: Icons.person_outline_rounded,
                  controller: nameController),
              const SizedBox(height: 15),
              Obx(() => isCustomer.value
                  ? const Divider()
                  : BuildTextField(
                      hint: "الاسم التجاري",
                      icon: Icons.shop_two,
                      controller: shopController,
                    )),
              const SizedBox(height: 15),
              BuildTextField(
                  hint: "رقم الهاتف",
                  icon: Icons.phone_android_rounded,
                  controller: phoneController,
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 15),
              BuildTextField(
                  hint: "العنوان / السكن",
                  icon: Icons.location_on_outlined,
                  controller: addressController),
              const SizedBox(height: 15),
              Obx(() => BuildTextField(
                    hint: "كلمة المرور",
                    icon: Icons.lock_outline_rounded,
                    controller: passwordController,
                    isPassword: true,
                    isVisible: isPasswordVisible.value,
                    onIconPressed: () => isPasswordVisible.toggle(),
                  )),
              const SizedBox(height: 20),
              Obx(() => CheckboxListTile(
                    value: isAgreed.value,
                    onChanged: (val) => isAgreed.value = val!,
                    title: const Text("أوافق على سياسة الخصوصية وشروط الاستخدام",
                        style: TextStyle(fontSize: 13)),
                    activeColor: primaryColor,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                  )),
              const SizedBox(height: 30),
              Obx(() => authController.isLoading.value
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () => _handleRegister(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Text("إنشاء الحساب",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    )),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _handleRegister() {
    if (!isAgreed.value) {
      Get.snackbar("تنبيه", "يرجى الموافقة على الشروط والأحكام أولاً",
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }
    String name     = nameController.text.trim();
    String phone    = phoneController.text.trim();
    String address  = addressController.text.trim();
    String password = passwordController.text.trim();

    if (name.isNotEmpty && phone.isNotEmpty && address.isNotEmpty && password.isNotEmpty) {
      if (password.length < 6) {
        Get.snackbar("كلمة المرور ضعيفة", "يجب أن تكون كلمة المرور 6 خانات على الأقل");
        return;
      }
      authController.register(
        name: name,
        phone: phone,
        address: address,
        password: password,
        userType: box.read('User-type') ?? 'customer',
        businessName: shopController.text,
      );
    } else {
      Get.snackbar("حقول ناقصة", "يرجى تعبئة كافة البيانات المطلوبة",
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }
}
