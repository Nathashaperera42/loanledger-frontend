import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/colors.dart';
import '../providers/providers.dart';
import 'dashboard_screen.dart';
import 'lent_screen.dart';
import 'borrowed_screen.dart';
import 'due_screen.dart';
import 'profit_screen.dart';

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});
  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int index = 0;
  final screens = const [DashboardScreen(), LentScreen(), BorrowedScreen(), DueScreen(), ProfitScreen()];

  @override
  Widget build(BuildContext context) {
    final due = ref.watch(dueProvider);
    int dueBadge = 0;
    due.whenData((d) {
      final collect = (d['collect'] as List?) ?? [];
      final pay = (d['pay'] as List?) ?? [];
      bool urgent(e) {
        final dd = e['interest_due_date']?.toString() ?? '';
        return dd.isNotEmpty && DateTime.tryParse(dd) != null &&
            !DateTime.parse(dd).isAfter(DateTime.now());
      }
      dueBadge = collect.where(urgent).length + pay.where(urgent).length;
    });

    return Scaffold(
      body: IndexedStack(index: index, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: [
          const NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Dashboard'),
          const NavigationDestination(icon: Icon(Icons.south_west), selectedIcon: Icon(Icons.south_west), label: 'Lent'),
          const NavigationDestination(icon: Icon(Icons.north_east), selectedIcon: Icon(Icons.north_east), label: 'Borrowed'),
          NavigationDestination(
            icon: Badge(isLabelVisible: dueBadge > 0, label: Text('$dueBadge'), backgroundColor: AppColors.over, child: const Icon(Icons.access_time)),
            label: 'Due'),
          const NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: 'Profit'),
        ],
      ),
    );
  }
}
