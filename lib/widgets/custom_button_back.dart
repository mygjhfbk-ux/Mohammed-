import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomButtonBack extends StatelessWidget {
  const CustomButtonBack({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => Get.back(),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF1A4D7E)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: const Text("إغلاق",
            style: TextStyle(color: Color(0xFF1A4D7E), fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}
