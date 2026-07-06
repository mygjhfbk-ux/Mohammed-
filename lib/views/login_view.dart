import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../widgets/build_text_field.dart';
import 'register_view.dart';
import 'reset_password_view.dart';

class LoginView extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();
  final passwordController = TextEditingController();
  final RxBool isPasswordVisible = false.obs;
  final Color primaryColor = const Color(0xFF0D47A1);

  LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 80),
            Hero(
              tag: 'auth_icon',
              child: Icon(Icons.account_balance_wallet_rounded, size: 100, color: primaryColor),
            ),
            const SizedBox(height: 10),
            Text("مرحباً بك مجدداً",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryColor)),
            const Text("سجل دخولك للمتابعة", style: TextStyle(color: Colors.grey)),
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                children: [
                  BuildTextField(
                      hint: "رقم الهاتف",
                      icon: Icons.phone_android_rounded,
                      controller: authController.phoneController,
                      keyboardType: TextInputType.phone),
                  const SizedBox(height: 15),
                  Obx(() => BuildTextField(
                        hint: "كلمة المرور",
                        icon: Icons.lock_outline_rounded,
                        controller: passwordController,
                        isPassword: true,
                        isVisible: isPasswordVisible.value,
                        onIconPressed: () => isPasswordVisible.toggle(),
                      )),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                        onPressed: () {
                          String phone = authController.phoneController.text;
                          if (phone.isEmpty) {
                            Get.snackbar("تنبيه", "يرجى إدخال رقم الهاتف أولاً",
                                backgroundColor: Colors.orange.withOpacity(0.8),
                                colorText: Colors.white);
                          } else {
                            Get.to(() => ResetPasswordView(phone: phone));
                          }
                        },
                        child: const Text("نسيت كلمة المرور؟",
                            style: TextStyle(fontWeight: FontWeight.bold))),
                  ),
                  const SizedBox(height: 20),
                  Obx(() => ElevatedButton(
                        onPressed:
                            authController.isLoading.value ? null : () => _handleLogin(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          minimumSize: const Size(double.infinity, 55),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                        ),
                        child: authController.isLoading.value
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text("دخول",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                      )),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () => Get.to(() => RegisterView()),
                        child: Text("أنشئ حساباً الآن",
                            style: TextStyle(
                                color: primaryColor, fontWeight: FontWeight.bold)),
                      ),
                      const Text("ليس لديك حساب؟"),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogin() {
    String phone = authController.phoneController.text.trim();
    String password = passwordController.text.trim();
    if (phone.isNotEmpty && password.isNotEmpty) {
      authController.login(phone, password);
    } else {
      Get.snackbar("خطأ", "يرجى إدخال رقم الهاتف وكلمة المرور",
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }
}
