import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_time_picker.dart';
import '../../../../core/utils/date_x.dart';

/// Kết quả nhập/điều chỉnh/sửa kho.
class StockEntryResult {
  const StockEntryResult({
    required this.category,
    required this.amount,
    this.note,
    this.time,
  });

  final String category;

  /// Số lượng có dấu (âm nếu giảm).
  final int amount;
  final String? note;

  /// Chỉ trả về khi dialog cho sửa thời gian.
  final DateTime? time;
}

/// Dialog dùng chung cho nhập kho / điều chỉnh / sửa giao dịch.
Future<StockEntryResult?> showStockEntryDialog(
  BuildContext context, {
  required String title,
  required String unit,
  required List<String> categories,
  bool allowNegative = false,
  bool showTime = false,
  String? initialCategory,
  int? initialAmount,
  String? initialNote,
  DateTime? initialTime,
}) {
  const newOption = '+ Loại mới';
  final newCatController = TextEditingController();
  final noteController = TextEditingController(text: initialNote ?? '');
  var selected =
      initialCategory ?? (categories.isNotEmpty ? categories.first : newOption);
  var increase = (initialAmount ?? 1) >= 0;
  var qty = initialAmount == null ? 1 : initialAmount.abs().clamp(1, 1 << 30);
  var time = initialTime ?? DateTime.now();

  return showDialog<StockEntryResult>(
    context: context,
    builder: (context) {
      final theme = Theme.of(context);
      return StatefulBuilder(
        builder: (context, setState) {
          final isNew = selected == newOption;
          final accent =
              increase ? const Color(0xFF7FC8A0) : const Color(0xFFE5736F);

          Widget label(String t) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Text(t, style: theme.textTheme.labelLarge),
              );

          return AlertDialog(
            titlePadding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.xl,
              AppSpacing.xl,
              0,
            ),
            title: Row(
              children: [
                Icon(
                  Icons.inventory_2_rounded,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: Text(title)),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (allowNegative) ...[
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<bool>(
                        showSelectedIcon: false,
                        segments: const [
                          ButtonSegment(
                            value: true,
                            label: Text('Tăng'),
                            icon: Icon(Icons.arrow_upward_rounded),
                          ),
                          ButtonSegment(
                            value: false,
                            label: Text('Giảm'),
                            icon: Icon(Icons.arrow_downward_rounded),
                          ),
                        ],
                        selected: {increase},
                        onSelectionChanged: (s) =>
                            setState(() => increase = s.first),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  label('Số lượng'),
                  _QtyStepper(
                    value: qty,
                    unit: unit,
                    accent: accent,
                    onChanged: (v) => setState(() => qty = v),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  label('Loại'),
                  DropdownButtonFormField<String>(
                    value: selected,
                    isExpanded: true,
                    decoration: const InputDecoration(isDense: true),
                    items: [
                      for (final c in categories)
                        DropdownMenuItem(value: c, child: Text(c)),
                      const DropdownMenuItem(
                        value: newOption,
                        child: Text(newOption),
                      ),
                    ],
                    onChanged: (v) => setState(() => selected = v ?? selected),
                  ),
                  if (isNew) ...[
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: newCatController,
                      decoration: const InputDecoration(
                        labelText: 'Tên loại mới',
                        isDense: true,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  TextField(
                    controller: noteController,
                    decoration: const InputDecoration(
                      labelText: 'Ghi chú (không bắt buộc)',
                      isDense: true,
                    ),
                  ),
                  if (showTime) ...[
                    const SizedBox(height: AppSpacing.sm),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.schedule),
                      title: const Text('Thời gian'),
                      subtitle: Text('${time.ddMMyyyy} ${time.hhmm}'),
                      trailing: TextButton(
                        onPressed: () async {
                          final picked =
                              await pickDateTime(context, initial: time);
                          if (picked != null) setState(() => time = picked);
                        },
                        child: const Text('Chọn'),
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Huỷ'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            final category =
                                isNew ? newCatController.text.trim() : selected;
                            if (qty <= 0 || category.isEmpty) {
                              Navigator.pop(context);
                              return;
                            }
                            final amount =
                                allowNegative && !increase ? -qty : qty;
                            final note = noteController.text.trim();
                            Navigator.pop(
                              context,
                              StockEntryResult(
                                category: category,
                                amount: amount,
                                note: note.isEmpty ? null : note,
                                time: showTime ? time : null,
                              ),
                            );
                          },
                          child: const Text('Lưu'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

/// Bộ đếm số lượng: nút −, số ở giữa (nhập tay được), nút +.
class _QtyStepper extends StatefulWidget {
  const _QtyStepper({
    required this.value,
    required this.unit,
    required this.accent,
    required this.onChanged,
  });

  final int value;
  final String unit;
  final Color accent;
  final ValueChanged<int> onChanged;

  @override
  State<_QtyStepper> createState() => _QtyStepperState();
}

class _QtyStepperState extends State<_QtyStepper> {
  late final TextEditingController _controller =
      TextEditingController(text: '${widget.value}');

  @override
  void didUpdateWidget(_QtyStepper old) {
    super.didUpdateWidget(old);
    if (widget.value != int.tryParse(_controller.text)) {
      _controller.text = '${widget.value}';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _bump(int by) {
    final v = (int.tryParse(_controller.text) ?? 0) + by;
    if (v < 1) return;
    widget.onChanged(v);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: widget.accent.withOpacity(0.10),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          _RoundBtn(
            icon: Icons.remove_rounded,
            color: widget.accent,
            onTap: () => _bump(-1),
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                suffixText: widget.unit,
              ),
              onChanged: (t) {
                final v = int.tryParse(t.trim());
                if (v != null && v > 0) widget.onChanged(v);
              },
            ),
          ),
          _RoundBtn(
            icon: Icons.add_rounded,
            color: widget.accent,
            onTap: () => _bump(1),
          ),
        ],
      ),
    );
  }
}

class _RoundBtn extends StatelessWidget {
  const _RoundBtn({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}
