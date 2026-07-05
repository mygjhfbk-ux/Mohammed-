import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/transactions_controller.dart';
import '../controllers/merchants_controller.dart';

class JoinRequestsView extends StatelessWidget {
  JoinRequestsView({super.key});
  final TransactionsController txCtrl = Get.find();
  final MerchantsController merchantsCtrl = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('طلبات الانضمام')),
      body: Center(child: Text('قائمة طلبات الانضمام ستكون هنا (قابلة للتوسيع)')),
    );
  }
}
