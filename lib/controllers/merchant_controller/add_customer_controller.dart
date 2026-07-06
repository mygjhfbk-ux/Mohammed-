import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/app_constants.dart';
import '../../core/supabase_service.dart';

class AddCustomerController extends GetxController {
  final TextEditingController nameController    = TextEditingController();
  final TextEditingController phoneController   = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController limitController   = TextEditingController();

  final hasAccount = true.obs;
  var isLoading    = false.obs;
  var isActive     = 0.obs;

  final box = GetStorage();
  String? merchantId;

  @override
  void onInit() {
    merchantId = box.read("Profile-id");
    super.onInit();
    clearFields();
  }

  Future<void> sendAddRequest() async {
    if (phoneController.text.length < 9 && hasAccount.value) {
      Get.snackbar("تنبيه", "رقم الهاتف غير مكتمل",
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }
    if (limitController.text.isEmpty) {
      Get.snackbar("تنبيه", "يرجى تحديد سقف الدين",
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    try {
      isLoading(true);
      merchantId ??= box.read("Profile-id");
      final debtLimit = double.tryParse(limitController.text) ?? 0.0;

      if (hasAccount.value) {
        // البحث عن عميل مسجل برقم الهاتف
        final customers = await SupabaseService.client
            .from(AppTables.customers)
            .select()
            .eq('phone', phoneController.text);

        if ((customers as List).isEmpty) {
          Get.snackbar("تنبيه", "هذا الرقم غير مسجل في التطبيق",
              backgroundColor: Colors.orange, colorText: Colors.white);
          return;
        }

        final customer = customers.first;

        // التحقق من عدم وجود طلب سابق
        final existing = await SupabaseService.client
            .from(AppTables.requests)
            .select()
            .eq('merchant_id', merchantId!)
            .eq('customer_id', customer['id']);

        if ((existing as List).isNotEmpty) {
          Get.snackbar("تنبيه", "تم إرسال طلب مسبقاً لهذا العميل",
              backgroundColor: Colors.orange, colorText: Colors.white);
          return;
        }

        await SupabaseService.client.from(AppTables.requests).insert({
          'merchant_id':   merchantId,
          'customer_id':   customer['id'],
          'status':        RequestStatus.pending,
          'account_limit': debtLimit,
        });

        // إشعار للعميل
        await SupabaseService.client.from(AppTables.notifications).insert({
          'user_id': customer['user_id'],
          'message': 'طلب ربط جديد من التاجر ${box.read('Name') ?? ''}',
        });

        Get.back();
        Get.snackbar("تم بنجاح", "تم إرسال طلب الربط للعميل",
            backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        // إضافة عميل محلي (بدون حساب)
        final newCustomer = await SupabaseService.client
            .from(AppTables.customers)
            .insert({
              'customer_name': nameController.text,
              'phone':         phoneController.text,
              'address':       addressController.text,
            })
            .select()
            .single();

        await SupabaseService.client.from(AppTables.requests).insert({
          'merchant_id':   merchantId,
          'customer_id':   newCustomer['id'],
          'status':        RequestStatus.accepted,
          'account_limit': debtLimit,
        });

        Get.back();
        Get.snackbar("تم بنجاح", "تمت إضافة العميل بنجاح",
            backgroundColor: Colors.green, colorText: Colors.white);
      }
      clearFields();
    } catch (e) {
      Get.snackbar("خطأ تقني", "حدثت مشكلة في الاتصال: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading(false);
    }
  }

  Future<void> updateCustomerRequest(String requestId) async {
    try {
      isLoading(true);
      await SupabaseService.client
          .from(AppTables.requests)
          .update({
            'account_limit': double.tryParse(limitController.text) ?? 0.0,
            'status':        isActive.value == 1 ? RequestStatus.accepted : RequestStatus.blocked,
          })
          .eq('id', requestId);

      if (nameController.text.isNotEmpty) {
        final request = await SupabaseService.client
            .from(AppTables.requests)
            .select('customer_id')
            .eq('id', requestId)
            .single();

        await SupabaseService.client
            .from(AppTables.customers)
            .update({
              'customer_name': nameController.text,
              'address':       addressController.text,
              'phone':         phoneController.text,
            })
            .eq('id', request['customer_id']);
      }

      Get.back(result: true);
      Get.snackbar("تم التحديث", "تم حفظ بيانات العميل بنجاح",
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("خطأ تقني", "مشكلة في الاتصال: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading(false);
    }
  }

  void clearFields() {
    nameController.clear();
    phoneController.clear();
    addressController.clear();
    limitController.clear();
    isActive.value = 0;
  }
}
