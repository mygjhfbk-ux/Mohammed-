import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/AdminDashboardController.dart';
import 'controllers/add_customer_controller.dart';
import 'controllers/ads_controller.dart';
import 'controllers/auth_controller.dart';
import 'controllers/customer_dashboard_controller.dart';
import 'controllers/merchant_controller.dart';
import 'controllers/merchant_customers_controller.dart';
import 'controllers/merchant_dashboard_controller.dart';
import 'controllers/notification_controller.dart';
import 'controllers/report_controller.dart';
import 'controllers/transactions_controller.dart';
import 'controllers/wallet_controller.dart';
import 'views/welcome_view.dart';

void main() {
  Get.put(AuthController());
  Get.put(MerchantController());
  Get.put(CustomerDashboardController());
  Get.put(WalletController());
  Get.put(MerchantDashboardController());
  Get.put(MerchantCustomersController());
  Get.put(AddCustomerController());
  Get.put(ReportController());
  Get.put(NotificationController());
  Get.put(TransactionsController());
  Get.put(AdminDashboardController());
  Get.put(AdsController());
  runApp(GetMaterialApp(
    title: 'ديوني',
    debugShowCheckedModeBanner: false,
    home: WelcomeView(),
    locale: const Locale('ar'),
  ));
}
