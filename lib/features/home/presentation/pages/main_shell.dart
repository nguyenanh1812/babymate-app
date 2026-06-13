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
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: _goTo,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Trang chủ',
              ),
              NavigationDestination(
                icon: Icon(Icons.water_drop_outlined),
                selectedIcon: Icon(Icons.water_drop_rounded),
                label: 'Hút sữa',
              ),
              NavigationDestination(
                icon: Icon(Icons.monitor_weight_outlined),
                selectedIcon: Icon(Icons.monitor_weight_rounded),
                label: 'Tăng trưởng',
              ),
              NavigationDestination(
                icon: Icon(Icons.inventory_2_outlined),
                selectedIcon: Icon(Icons.inventory_2_rounded),
                label: 'Kho',
              ),
            ],
          ),
        );
      },
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
