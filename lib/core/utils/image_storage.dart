import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

/// Chọn ảnh từ thư viện/máy ảnh và lưu vào thư mục app, trả về đường dẫn.
///
/// Ảnh từ picker là file tạm nên cần copy vào thư mục tài liệu để giữ lâu dài.
abstract final class ImageStorage {
  ImageStorage._();

  static final ImagePicker _picker = ImagePicker();

  static Future<String?> pick({required ImageSource source}) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 800,
      imageQuality: 80,
    );
    if (picked == null) return null;

    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory('${dir.path}/avatars');
    await folder.create(recursive: true);
    final ext = picked.path.split('.').last;
    final dest = '${folder.path}/${DateTime.now().microsecondsSinceEpoch}.$ext';
    await File(picked.path).copy(dest);
    return dest;
  }
}
