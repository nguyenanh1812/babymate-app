import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/image_storage.dart';
import '../cubit/moment_cubit.dart';

/// Tạo một khoảnh khắc mới: chọn/chụp ảnh rồi viết mô tả (kiểu Locket).
class AddMomentPage extends StatefulWidget {
  const AddMomentPage({required this.babyId, super.key});

  final String babyId;

  @override
  State<AddMomentPage> createState() => _AddMomentPageState();
}

class _AddMomentPageState extends State<AddMomentPage> {
  final _captionController = TextEditingController();
  String? _imagePath;
  bool _saving = false;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    final path = await ImageStorage.pick(
      source: source,
      folder: 'moments',
      maxWidth: 1280,
      quality: 85,
    );
    if (path != null) setState(() => _imagePath = path);
  }

  void _chooseSource() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Chụp ảnh'),
              onTap: () {
                Navigator.pop(sheetContext);
                _pick(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Chọn từ thư viện'),
              onTap: () {
                Navigator.pop(sheetContext);
                _pick(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (_imagePath == null || _saving) return;
    setState(() => _saving = true);
    final caption = _captionController.text.trim();
    context.read<MomentCubit>().add(
          babyId: widget.babyId,
          imagePath: _imagePath!,
          time: DateTime.now(),
          caption: caption.isEmpty ? null : caption,
        );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Khoảnh khắc mới')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: GestureDetector(
              onTap: _chooseSource,
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest
                      .withOpacity(0.4),
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: _imagePath == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo_outlined,
                            size: 40,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Chạm để chụp hoặc chọn ảnh',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      )
                    : Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.file(File(_imagePath!), fit: BoxFit.cover),
                          Positioned(
                            right: AppSpacing.sm,
                            bottom: AppSpacing.sm,
                            child: Material(
                              color: Colors.black.withOpacity(0.45),
                              shape: const CircleBorder(),
                              child: InkWell(
                                onTap: _chooseSource,
                                customBorder: const CircleBorder(),
                                child: const Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Icon(
                                    Icons.edit_outlined,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _captionController,
            maxLines: 4,
            minLines: 2,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Mô tả khoảnh khắc',
              hintText: 'Hôm nay bé làm gì đáng yêu nào?',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton.icon(
            onPressed: _imagePath == null ? null : _save,
            icon: const Icon(Icons.check_rounded),
            label: const Text('Lưu khoảnh khắc'),
          ),
        ],
      ),
    );
  }
}
