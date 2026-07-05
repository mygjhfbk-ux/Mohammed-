import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final SupabaseClient supabase = Supabase.instance.client;
  final String bucket;

  StorageService({this.bucket = 'public'});

  /// Uploads an image file (from ImagePicker) to Storage and returns the public URL or null on error
  Future<String?> uploadImage(XFile imageFile, {String? pathPrefix}) async {
    try {
      final file = File(imageFile.path);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}-${imageFile.name}';
      final path = (pathPrefix != null) ? '$pathPrefix/$fileName' : 'uploads/$fileName';

      // Upload
      final res = await supabase.storage.from(bucket).upload(path, file);

      // get public url
      final publicUrl = supabase.storage.from(bucket).getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      print('StorageService.uploadImage error: $e');
      return null;
    }
  }
}
