import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'controllers/auth_controller.dart';
import 'views/welcome_view.dart';
import 'views/login_view.dart';
import 'views/register_view.dart';
import 'views/merchant_dashboard.dart';
import 'views/customer_dashboard.dart';
import 'views/admin_users_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  // Put controllers
  Get.put(AuthController());

  runApp(GetMaterialApp(
    title: 'ديوني (Supabase)',
    debugShowCheckedModeBanner: false,
    initialRoute: '/',
    getPages: [
      GetPage(name: '/', page: () => WelcomeView()),
      GetPage(name: '/login', page: () => LoginView()),
      GetPage(name: '/register', page: () => RegisterView()),
      GetPage(name: '/merchant', page: () => MerchantDashboard()),
      GetPage(name: '/customer', page: () => CustomerDashboard()),
      GetPage(name: '/admin', page: () => AdminUsersView()),
    ],
    locale: const Locale('ar'),
  ));
}
