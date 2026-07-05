import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'login_view.dart';
import 'register_view.dart';

class WelcomeView extends StatelessWidget {
  WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('مرحباً بك في تطبيق ديوني', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Get.to(() => LoginView());
                  },
                  child: Text('تسجيل الدخول'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () {
                    Get.to(() => RegisterView());
                  },
                  child: Text('إنشاء حساب جديد'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
