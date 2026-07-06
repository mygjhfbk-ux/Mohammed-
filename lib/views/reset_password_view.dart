import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../widgets/build_text_field.dart';

class ResetPasswordView extends StatelessWidget {
  final String? phone;
  ResetPasswordView({super.key, this.phone});

  final AuthController authController  = Get.find<AuthController>();
  final TextEditingController _phone   = TextEditingController();
  final Color primaryColor             = const Color(0xFF0D47A1);

  @override
  Widget build(BuildContext context) {
    if (phone != null) _phone.text = phone!;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("استعادة كلمة المرور",
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: primaryColor),
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            Center(child: Icon(Icons.lock_reset_rounded, size: 80, color: primaryColor)),
            const SizedBox(height: 20),
            const Center(
              child: Text("أدخل رقم هاتفك وسنرسل لك رابط\nإعادة تعيين كلمة المرور",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 15, height: 1.6)),
            ),
            const SizedBox(height: 40),
            BuildTextField(
                hint: "رقم الهاتف",
                icon: Icons.phone_android_rounded,
                controller: _phone,
                keyboardType: TextInputType.phone),
            const SizedBox(height: 30),
            Obx(() => ElevatedButton(
                  onPressed: authController.isLoading.value
                      ? null
                      : () {
                          if (_phone.text.isNotEmpty) {
                            authController.forgotPassword(_phone.text.trim());
                          } else {
                            Get.snackbar("تنبيه", "يرجى إدخال رقم الهاتف");
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: authController.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("إرسال رابط الاستعادة",
                          style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                )),
          ],
        ),
      ),
    );
  }
}
