import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../widgets/build_text_field.dart';

class ResetPasswordView extends StatefulWidget {
  final String? phone;
  const ResetPasswordView({super.key, this.phone});

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final AuthController authController = Get.find();

  final RxBool isPasswordVisible = false.obs;
  final RxBool isConfirmVisible = false.obs;
  final Color primaryColor = const Color(0xFF104A81);

  @override
  void initState() {
    super.initState();
    // تعبئة رقم الهاتف تلقائياً إذا تم تمريره من واجهة الدخول
    if (widget.phone != null) {
      phoneController.text = widget.phone!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("استعادة كلمة المرور",
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: primaryColor, size: 20),
            onPressed: () => Get.back()),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            children: [
              const Icon(Icons.lock_reset_rounded, size: 80, color: Colors.orange),
              const SizedBox(height: 15),
              const Text("تعيين كلمة سر جديدة",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Text("يرجى إدخال الرقم وكلمة المرور الجديدة لتلقي رمز التحقق",
                  style: TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 35),

              // حقل رقم الهاتف (يتم تعطيله إذا كان قادماً من الواجهة السابقة لضمان الدقة)
              BuildTextField(
                hint: "رقم الهاتف",
                icon: Icons.phone_android_rounded,
                controller: phoneController,
                keyboardType: TextInputType.phone,
                //enabled: widget.phone == null, // متاح للتعديل فقط إذا لم يتم تمريره
              ),
              const SizedBox(height: 20),

              // كلمة المرور الجديدة
              Obx(() => BuildTextField(
                hint: "كلمة المرور الجديدة",
                icon: Icons.lock_outline_rounded,
                controller: passwordController,
                isPassword: true,
                isVisible: isPasswordVisible.value,
                onIconPressed: () => isPasswordVisible.toggle(),
              )),
              const SizedBox(height: 20),

              // تأكيد كلمة المرور
              Obx(() => BuildTextField(
                hint: "تأكيد كلمة المرور",
                icon: Icons.lock_reset_rounded,
                controller: confirmPasswordController,
                isPassword: true,
                isVisible: isConfirmVisible.value,
                onIconPressed: () => isConfirmVisible.toggle(),
              )),

              const SizedBox(height: 40),

              // زر التأكيد مع مراقبة حالة التحميل
              Obx(() => SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 0,
                  ),
                  onPressed: authController.isLoading.value ? null : () => _handleReset(),
                  child: authController.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("إرسال رمز التحقق",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
  void _handleReset() {
    String phone = phoneController.text.trim();
    String pass = passwordController.text.trim();
    String confirmPass = confirmPasswordController.text.trim();

    if (phone.isEmpty || pass.isEmpty) {
      Get.snackbar("تنبيه", "يرجى ملء جميع الحقول",
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    if (pass != confirmPass) {
      Get.snackbar("خطأ", "كلمات المرور غير متطابقة",
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    if (pass.length < 6) {
      Get.snackbar("كلمة مرور ضعيفة", "يجب أن تكون كلمة المرور 6 خانات على الأقل");
      return;
    }

    // إرسال الطلب للسيرفر لإرسال OTP للواتساب
    authController.requestResetOtp(phone, pass);
  }
}
