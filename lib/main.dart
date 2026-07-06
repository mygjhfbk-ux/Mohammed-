import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'controllers/admin_controller/AdminDashboardController.dart';
import 'controllers/admin_controller/AdsManagementController.dart';
import 'controllers/admin_controller/UsersManagementController.dart';
import 'controllers/merchant_controller/add_customer_controller.dart';
import 'controllers/ads_controller.dart';
import 'controllers/auth_controller.dart';
import 'controllers/customer_controller/customer_dashboard_controller.dart';
import 'controllers/customer_controller/merchant_controller.dart';
import 'controllers/merchant_controller/merchant_customers_controller.dart';
import 'controllers/merchant_controller/merchant_dashboard_controller.dart';
import 'controllers/customer_controller/notification_controller.dart';
import 'controllers/merchant_controller/report_controller.dart';
import 'controllers/merchant_controller/transactions_controller.dart';
import 'controllers/merchant_controller/wallet_controller.dart';
import 'core/supabase_service.dart';
import 'views/welcome_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await SupabaseService.initialize();

  Get.put(AuthController(),              permanent: true);
  Get.put(MerchantController(),          permanent: true);
  Get.put(CustomerDashboardController(), permanent: true);
  Get.put(WalletController(),            permanent: true);
  Get.put(MerchantDashboardController(), permanent: true);
  Get.put(MerchantCustomersController(), permanent: true);
  Get.put(AddCustomerController(),       permanent: true);
  Get.put(ReportController(),            permanent: true);
  Get.put(NotificationController(),      permanent: true);
  Get.put(TransactionsController(),      permanent: true);
  Get.put(AdminDashboardController(),    permanent: true);
  Get.put(AdsManagementController(),     permanent: true);
  Get.put(UsersManagementController(),   permanent: true);
  Get.put(AdsController(),               permanent: true);

  runApp(GetMaterialApp(
    title: 'ديوني',
    debugShowCheckedModeBanner: false,
    locale: const Locale('ar'),
    supportedLocales: const [Locale('ar')],
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
      useMaterial3: true,
      textTheme: GoogleFonts.cairoTextTheme(),
    ),
    home: WelcomeView(),
  ));
}
