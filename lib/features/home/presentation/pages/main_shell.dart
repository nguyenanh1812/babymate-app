import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/app_empty_state.dart';
import '../../../baby/presentation/cubit/baby_cubit.dart';
import '../../../baby/presentation/pages/baby_list_page.dart';
import '../../../growth/presentation/pages/growth_page.dart';
import '../../../inventory/presentation/pages/inventory_page.dart';
import '../../../moment/presentation/pages/moments_page.dart';
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

  /// Tăng mỗi khi quay lại tab Home từ tab khác → ép Home dựng lại (reset bộ
  /// lọc ngày về hôm nay).
  int _homeEpoch = 0;

  void _goTo(int index) => setState(() {
        if (index == 0 && _index != 0) _homeEpoch++;
        _index = index;
      });

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
          HomePage(key: ValueKey('home_$_homeEpoch')),
          babyId == null
              ? _RequireBaby(onAddBaby: openProfile)
              : PumpingPage(babyId: babyId),
          babyId == null
              ? _RequireBaby(onAddBaby: openProfile)
              : MomentsPage(babyId: babyId),
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
      icon: Icons.add_a_photo_outlined,
      active: Icons.add_a_photo_rounded,
      label: 'Khoảnh khắc',
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
    final color = theme.colorScheme.primary;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    const barHeight = 54.0;

    Widget navItem(int i) => Expanded(
          child: _NavItem(
            icon: index == i ? _items[i].active : _items[i].icon,
            label: _items[i].label,
            selected: index == i,
            color: color,
            onTap: () => onTap(i),
          ),
        );

    return SizedBox(
      height: barHeight + bottomInset,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Nền phẳng + bóng mềm phía trên (không viền).
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
            ),
          ),
          // 5 tab chia đều: Home · Hút sữa · Khoảnh khắc · Tăng trưởng · Kho.
          SizedBox(
            height: barHeight,
            child: Row(
              children: [for (var i = 0; i < _items.length; i++) navItem(i)],
            ),
          ),
        ],
      ),
    );
  }
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
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          // Tab đang chọn: vòng tròn đặc nằm gọn trong nav (không nhô lên).
          padding: EdgeInsets.all(selected ? 11 : 10),
          decoration: BoxDecoration(
            color: selected ? color : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 23,
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
