import 'package:flutter/material.dart';

class CustomerDashboard extends StatelessWidget {
  const CustomerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('لوحة العميل')),
      body: const Center(child: Text('مرحباً، هذا مجرد شاشة تجريبية للعميل')),
    );
  }
}
