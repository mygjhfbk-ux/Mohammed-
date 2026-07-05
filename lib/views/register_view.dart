import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class RegisterView extends StatelessWidget {
  RegisterView({super.key});
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();
  final TextEditingController nameCtrl = TextEditingController();
  final AuthController auth = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('إنشاء حساب')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: nameCtrl, decoration: InputDecoration(labelText: 'الاسم')),
            TextField(controller: phoneCtrl, decoration: InputDecoration(labelText: 'الهاتف')),
            TextField(controller: passCtrl, decoration: InputDecoration(labelText: 'كلمة المرور'), obscureText: true),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => auth.signUp(phone: phoneCtrl.text.trim(), password: passCtrl.text.trim(), name: nameCtrl.text.trim(), userType: 'merchant'),
              child: Text('تسجيل'),
            )
          ],
        ),
      ),
    );
  }
}
