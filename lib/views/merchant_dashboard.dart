import 'package:flutter/material.dart';

class MerchantDashboard extends StatelessWidget {
  const MerchantDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('لوحة التاجر')),
      body: const Center(child: Text('مرحباً، هذا مجرد شاشة تجريبية للتاجر')),
    );
  }
}
