import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../widgets/rounded_input.dart';
import '../widgets/primary_button.dart';

class LoginView extends StatelessWidget {
  LoginView({super.key});
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();
  final AuthController auth = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تسجيل الدخول')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            RoundedInput(controller: phoneCtrl, label: 'الهاتف', keyboard: TextInputType.phone),
            const SizedBox(height: 12),
            RoundedInput(controller: passCtrl, label: 'كلمة المرور', obscure: true),
            const SizedBox(height: 16),
            Obx(() => PrimaryButton(label: 'دخول', loading: auth.isLoading.value, onPressed: () => auth.signIn(phone: phoneCtrl.text.trim(), password: passCtrl.text.trim()))),
          ],
        ),
      ),
    );
  }
}
