import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'login_view.dart';

class OtpView extends StatelessWidget {
  final String phoneNumber;
  OtpView({super.key, required this.phoneNumber});

  final Color primaryColor = const Color(0xFF0D47A1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: primaryColor),
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline_rounded, size: 100, color: Colors.green),
            const SizedBox(height: 20),
            const Text("تم إنشاء حسابك بنجاح!",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("يمكنك الآن تسجيل الدخول برقم الهاتف: $phoneNumber",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 15)),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Get.offAll(() => LoginView()),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text("تسجيل الدخول",
                  style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
