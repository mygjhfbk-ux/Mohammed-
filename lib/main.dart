import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'controllers/auth_controller.dart';
import 'views/welcome_view.dart';

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
    home: WelcomeView(),
    locale: const Locale('ar'),
  ));
}
