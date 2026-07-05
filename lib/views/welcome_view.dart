import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/primary_button.dart';

class WelcomeView extends StatelessWidget {
  WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: Text('مرحباً بك في تطبيق ديوني', style: Theme.of(context).textTheme.headline6)),
              const SizedBox(height: 24),
              PrimaryButton(label: 'تسجيل الدخول', onPressed: () => Get.toNamed('/login')),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => Get.toNamed('/register'),
                child: const Text('إنشاء حساب جديد'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
