import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_controller/AdminRegisterController.dart';

/// واجهة اضافة مستخدم كمدير
class AdminRegisterView extends StatelessWidget {
  final controller = Get.put(AdminRegisterController());

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final keyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("تسجيل مدير نظام جديد"),
        backgroundColor: Color(0xFF07477E),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(25),
        child: Column(
          children: [
            Icon(Icons.admin_panel_settings, size: 80, color: Color(0xFF07477E)),
            SizedBox(height: 10),
            Text("إنشاء صلاحية وصول للإدارة", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 30),

            _buildTextField(nameController, "الاسم الكامل", Icons.person),
            SizedBox(height: 15),
            _buildTextField(phoneController, "رقم الهاتف", Icons.phone, isNumber: true),
            SizedBox(height: 15),
            _buildTextField(passwordController, "كلمة المرور", Icons.lock, isPass: true),
            SizedBox(height: 15),

            // حقل رمز الأمان الحساس
            TextField(
              controller: keyController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "رمز أمان الإدارة (Secret Key)",
                prefixIcon: Icon(Icons.vpn_key, color: Colors.red),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.red.withOpacity(0.05),
              ),
            ),

            SizedBox(height: 30),

            Obx(() => SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF07477E),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: controller.isLoading.value ? null : () {
                  controller.registerAdmin(
                    name: nameController.text,
                    phone: phoneController.text,
                    password: passwordController.text,
                    adminKey: keyController.text,
                  );
                },
                child: controller.isLoading.value
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("إنشاء حساب المدير", style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isPass = false, bool isNumber = false}) {
    return TextField(
      controller: controller,
      obscureText: isPass,
      keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Color(0xFF07477E)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
