import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

/// Chọn ảnh từ thư viện/máy ảnh và lưu vào thư mục app, trả về đường dẫn.
///
/// Ảnh từ picker là file tạm nên cần copy vào thư mục tài liệu để giữ lâu dài.
abstract final class ImageStorage {
  ImageStorage._();

  static final ImagePicker _picker = ImagePicker();

  static Future<String?> pick({
    required ImageSource source,
    String folder = 'avatars',
    int maxWidth = 800,
    int quality = 80,
  }) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: maxWidth.toDouble(),
      imageQuality: quality,
    );
    if (picked == null) return null;

    final dir = await getApplicationDocumentsDirectory();
    final dest = Directory('${dir.path}/$folder');
    await dest.create(recursive: true);
    final ext = picked.path.split('.').last;
    final path = '${dest.path}/${DateTime.now().microsecondsSinceEpoch}.$ext';
    await File(picked.path).copy(path);
    return path;
  }
}
