import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../theme/app_spacing.dart';
import '../utils/image_storage.dart';

/// Avatar tròn cho phép chọn/đổi/xoá ảnh (thư viện hoặc máy ảnh).
///
/// [path] là đường dẫn ảnh hiện tại (null nếu chưa có); [onChanged] trả về
/// đường dẫn mới (hoặc null khi xoá).
class AvatarPicker extends StatelessWidget {
  const AvatarPicker({
    required this.path,
    required this.onChanged,
    this.radius = 44,
    this.accent,
    this.fallback,
    super.key,
  });

  final String? path;
  final ValueChanged<String?> onChanged;
  final double radius;
  final Color? accent;

  /// Widget hiển thị khi chưa có ảnh (vd icon). Mặc định icon máy ảnh.
  final Widget? fallback;

  Future<void> _showOptions(BuildContext context) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Chọn từ thư viện'),
              onTap: () => Navigator.pop(ctx, 'gallery'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Chụp ảnh'),
              onTap: () => Navigator.pop(ctx, 'camera'),
            ),
            if (path != null)
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Xoá ảnh'),
                onTap: () => Navigator.pop(ctx, 'remove'),
              ),
          ],
        ),
      ),
    );
    if (action == null) return;
    if (action == 'remove') {
      onChanged(null);
      return;
    }
    final source =
        action == 'camera' ? ImageSource.camera : ImageSource.gallery;
    final saved = await ImageStorage.pick(source: source);
    if (saved != null) onChanged(saved);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = accent ?? theme.colorScheme.primary;
    final hasImage = path != null && File(path!).existsSync();

    return GestureDetector(
      onTap: () => _showOptions(context),
      child: Stack(
        children: [
          CircleAvatar(
            radius: radius,
            backgroundColor: color.withOpacity(0.15),
            backgroundImage: hasImage ? FileImage(File(path!)) : null,
            child: hasImage
                ? null
                : (fallback ?? Icon(Icons.add_a_photo_outlined, color: color)),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.xs),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: theme.colorScheme.surface, width: 2),
              ),
              child: const Icon(Icons.edit, size: 14, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
