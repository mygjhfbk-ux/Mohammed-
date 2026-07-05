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
      appBar: AppBar(title: Text('تعديل عميل')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (profile['image_path'] != null)
              Image.network(profile['image_path'], width: 120, height: 120, fit: BoxFit.cover),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: Icon(Icons.photo),
              label: Text('تغيير الصورة'),
              onPressed: () async {
                final ImagePicker picker = ImagePicker();
                final XFile? picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                if (picked != null) {
                  final publicUrl = await storage.uploadImage(picked, pathPrefix: 'profiles');
                  if (publicUrl != null) {
                    // update profile image_path
                    await ctrl.updateCustomer(customer['id'], {'profile': {'image_path': publicUrl}});
                    // crude refresh
                    await ctrl.fetchCustomers();
                  }
                }
              },
            ),
            const SizedBox(height: 12),
            TextField(controller: nameCtrl, decoration: InputDecoration(labelText: 'الاسم')),
            TextField(controller: phoneCtrl, decoration: InputDecoration(labelText: 'الهاتف')),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                // For now we only update the accepted flag as example
                await ctrl.updateCustomer(customer['id'], {'accepted': true});
                Get.back();
              },
              child: Text('حفظ'),
            )
          ],
        ),
      ),
    );
  }
}
