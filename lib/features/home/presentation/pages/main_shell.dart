import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/app_empty_state.dart';
import '../../../baby/presentation/cubit/baby_cubit.dart';
import '../../../baby/presentation/pages/baby_list_page.dart';
import '../../../growth/presentation/pages/growth_page.dart';
import '../../../inventory/presentation/pages/inventory_page.dart';
import '../../../pumping/presentation/pages/pumping_page.dart';
import 'home_page.dart';

/// Khung chính của app với thanh điều hướng dưới cùng cho từng chức năng.
///
/// Dùng [IndexedStack] để giữ trạng thái các tab khi chuyển qua lại.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  void _goTo(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BabyCubit, BabyState>(
      builder: (context, state) {
        final baby = state.activeBaby;
        final babyId = baby?.id;

        void openProfile() => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const BabyListPage()),
            );

        final tabs = <Widget>[
          const HomePage(),
          babyId == null
              ? _RequireBaby(onAddBaby: openProfile)
              : PumpingPage(babyId: babyId),
          babyId == null
              ? _RequireBaby(onAddBaby: openProfile)
              : GrowthPage(babyId: babyId),
          babyId == null
              ? _RequireBaby(onAddBaby: openProfile)
              : const InventoryPage(),
        ];

        return Scaffold(
          body: IndexedStack(index: _index, children: tabs),
          bottomNavigationBar: _BottomNav(index: _index, onTap: _goTo),
        );
      },
    );
  }
}

/// Thanh điều hướng dưới tự dựng: icon màu thương hiệu, tab đang chọn nằm
/// trong vòng tròn đặc (icon trắng) — tròn chạy mượt theo tab được chọn.
class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.index, required this.onTap});

  final int index;
  final ValueChanged<int> onTap;

  static const _items = <({IconData icon, IconData active, String label})>[
    (icon: Icons.home_outlined, active: Icons.home_rounded, label: 'Trang chủ'),
    (
      icon: Icons.water_drop_outlined,
      active: Icons.water_drop_rounded,
      label: 'Hút sữa',
    ),
    (
      icon: Icons.monitor_weight_outlined,
      active: Icons.monitor_weight_rounded,
      label: 'Tăng trưởng',
    ),
    (
      icon: Icons.inventory_2_outlined,
      active: Icons.inventory_2_rounded,
      label: 'Kho',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).padding.bottom;
    const barHeight = 54.0;
    return SizedBox(
      height: barHeight + bottomInset,
      child: LayoutBuilder(
        builder: (context, c) {
          final itemWidth = c.maxWidth / _items.length;
          final notchX = (index + 0.5) * itemWidth;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              // Nền nav có "lõm" tròn ôm icon active (không viền trên).
              Positioned.fill(
                child: CustomPaint(
                  painter: _NavBarPainter(
                    centerX: notchX,
                    radius: 30,
                    color: theme.colorScheme.surface,
                  ),
                ),
              ),
              SizedBox(
                height: barHeight,
                child: Row(
                  children: [
                    for (var i = 0; i < _items.length; i++)
                      Expanded(
                        child: _NavItem(
                          icon: index == i ? _items[i].active : _items[i].icon,
                          label: _items[i].label,
                          selected: index == i,
                          color: theme.colorScheme.primary,
                          onTap: () => onTap(i),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Vẽ nền thanh nav với một "lõm" tròn mềm tại [centerX] để ôm icon đang chọn.
class _NavBarPainter extends CustomPainter {
  const _NavBarPainter({
    required this.centerX,
    required this.radius,
    required this.color,
  });

  final double centerX;
  final double radius;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const notch = CircularNotchedRectangle();
    final host = Offset.zero & size;
    final guest = Rect.fromCircle(center: Offset(centerX, 0), radius: radius);
    final path = notch.getOuterPath(host, guest);
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_NavBarPainter old) =>
      old.centerX != centerX || old.color != color || old.radius != radius;
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 40,
      containedInkWell: false,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          // Tab đang chọn nhô lên khỏi mép nav.
          transform: Matrix4.translationValues(0, selected ? -16 : 0, 0),
          transformAlignment: Alignment.center,
          padding: EdgeInsets.all(selected ? 14 : 10),
          decoration: BoxDecoration(
            color: selected ? color : Colors.transparent,
            shape: BoxShape.circle,
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.45),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : null,
          ),
          child: Icon(
            icon,
            size: 24,
            color: selected ? Colors.white : color,
            semanticLabel: label,
          ),
        ),
      ),
    );
  }
}

/// Hiển thị khi chưa có bé nào — nhắc người dùng sang tab Hồ sơ để thêm.
class _RequireBaby extends StatelessWidget {
  const _RequireBaby({required this.onAddBaby});
  final VoidCallback onAddBaby;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppEmptyState(
        icon: Icons.child_care_rounded,
        title: 'Chưa có hồ sơ bé',
        message: 'Thêm hồ sơ bé để dùng tính năng này nhé!',
        action: FilledButton.icon(
          onPressed: onAddBaby,
          icon: const Icon(Icons.person_add_alt),
          label: const Text('Tới Hồ sơ bé'),
        ),
      ),
    );
  }
}
