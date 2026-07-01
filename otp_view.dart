import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class OtpView extends StatelessWidget {
  final String phoneNumber;
  final AuthController authController = Get.find();

  // استخدام List من الـ FocusNodes للتحكم في التنقل بين المربعات
  final List<FocusNode> focusNodes = List.generate(6, (i) => FocusNode());
  final List<TextEditingController> controllers = List.generate(6, (i) => TextEditingController());
  final Color primaryColor = const Color(0xFF07477E);

  OtpView({super.key, required this.phoneNumber});

  @override
  Widget build(BuildContext context) {
    authController.startResendTimer();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(elevation: 0, backgroundColor: Colors.white, leading: BackButton(color: primaryColor)),
      body: Directionality(
        textDirection: TextDirection.rtl, // العنوان والوصف بالعربي
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            children: [
              const Icon(Icons.mark_chat_unread_outlined, size: 80, color: Colors.green),
              const SizedBox(height: 20),
              const Text("تحقق من رقمك", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text("تم إرسال رمز التأكيد إلى واتساب الرقم:", style: TextStyle(color: Colors.grey[600])),
              Text(phoneNumber, style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),

              const SizedBox(height: 40),

              // حقول إدخال الرمز (English direction for numbers)
              Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (index) => _buildOtpBox(context, index)),
                ),
              ),

              const SizedBox(height: 40),

              // زر التفعيل
              Obx(() => ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: authController.isLoading.value ? null : () => _verifyCode(),
                child: authController.isLoading.value
                    ? const SizedBox(height: 25, width: 25, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("تفعيل الحساب", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              )),

              const SizedBox(height: 20),

              // إعادة إرسال الكود
              Obx(() {
                return Column(
                  children: [
                    TextButton(
                      // لا يعمل الزر إلا إذا انتهى الوقت (resendSeconds == 0)
                      onPressed: authController.resendSeconds.value == 0 && !authController.isLoading.value
                          ? () {
                        authController.resendOtp(phoneNumber);
                        // تنظيف المربعات عند إعادة الإرسال
                        for (var controller in controllers) {
                          controller.clear();
                        }
                        focusNodes[0].requestFocus();
                      }
                          : null,
                      child: Text(
                        authController.resendSeconds.value == 0
                            ? "لم يصلك الرمز؟ إعادة إرسال"
                            : "إعادة الإرسال خلال ${authController.resendSeconds.value} ثانية",
                        style: TextStyle(
                          color: authController.resendSeconds.value == 0 ? primaryColor : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                );
              }),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpBox(BuildContext context, int index) {
    return SizedBox(
      width: 45,
      child: TextField(
        controller: controllers[index],
        focusNode: focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          counterText: "",
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.grey)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: primaryColor, width: 2)),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            focusNodes[index - 1].requestFocus();
          }
        },
      ),
    );
  }

  void _verifyCode() {
    String code = controllers.map((c) => c.text).join();
    if (code.length == 6) {
      authController.verifyOtp(phoneNumber, code);
    } else {
      Get.snackbar("تنبيه", "يرجى إدخال الرمز المكون من 6 أرقام", snackPosition: SnackPosition.BOTTOM);
    }
  }
}
