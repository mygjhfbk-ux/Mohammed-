import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/customers_controller.dart';
import '../services/storage_service.dart';

class EditCustomerView extends StatelessWidget {
  EditCustomerView({super.key, required this.customer});
  final Map<String, dynamic> customer;
  final CustomersController ctrl = Get.find();
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final StorageService storage = StorageService();

  @override
  Widget build(BuildContext context) {
    final profile = customer['profile'] ?? {};
    nameCtrl.text = profile['name'] ?? '';
    phoneCtrl.text = profile['phone'] ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('تعديل عميل')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (profile['image_path'] != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(profile['image_path'], width: 120, height: 120, fit: BoxFit.cover),
              ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.photo),
              label: const Text('تغيير الصورة'),
              onPressed: () async {
                final ImagePicker picker = ImagePicker();
                final XFile? picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                if (picked != null) {
                  final publicUrl = await storage.uploadImage(picked, pathPrefix: 'profiles');
                  if (publicUrl != null) {
                    // update profile image_path via profiles table - note: controller expects customers table, so update directly
                    await storage.supabase.from('profiles').update({'image_path': publicUrl}).eq('id', customer['profile']['id']);
                    // crude refresh
                    await ctrl.fetchCustomers(merchantId: customer['linked_merchant_id']);
                  }
                }
              },
            ),
            const SizedBox(height: 12),
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'الاسم')),
            TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'الهاتف')),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                // For now we only update the accepted flag as example
                await ctrl.updateCustomer(customer['id'], {'accepted': true});
                Get.back();
              },
              child: const Text('حفظ'),
            )
          ],
        ),
      ),
    );
  }
}
