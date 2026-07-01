import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomButtonBack extends StatelessWidget {
  const CustomButtonBack({super.key});

  @override
  Widget build(BuildContext context) {
    return  SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => Get.back(),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A4D7E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: const Text(
          "إغلاق",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}
