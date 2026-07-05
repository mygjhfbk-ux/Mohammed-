import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class LoginView extends StatelessWidget {
  LoginView({super.key});
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();
  final AuthController auth = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('تسجيل الدخول')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: phoneCtrl, decoration: InputDecoration(labelText: 'الهاتف')),
            TextField(controller: passCtrl, decoration: InputDecoration(labelText: 'كلمة المرور'), obscureText: true),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => auth.signIn(phone: phoneCtrl.text.trim(), password: passCtrl.text.trim()),
              child: Text('دخول'),
            )
          ],
        ),
      ),
    );
  }
}
