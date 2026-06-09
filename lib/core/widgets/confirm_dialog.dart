import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// Dialog xác nhận dùng chung: 2 nút Huỷ/Đồng ý **nằm ngang, chia đôi**.
///
/// Trả về true nếu người dùng xác nhận.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  String? message,
  String confirmText = 'Xoá',
  String cancelText = 'Huỷ',
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (message != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: Text(message),
            ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(cancelText),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(confirmText),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
  return result ?? false;
}
