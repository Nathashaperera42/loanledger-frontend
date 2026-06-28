import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/colors.dart';
import '../providers/providers.dart';
import '../widgets/common.dart';
import 'login_screen.dart';

class AppHeader extends ConsumerWidget {
  final String title; final String? subtitle; final bool showBrand;
  const AppHeader({required this.title, this.subtitle, this.showBrand = false, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = ref.watch(themeModeProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 8, 2, 14),
      child: Row(children: [
        if (showBrand) ...[
          Container(width: 38, height: 38,
              decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.primary, AppColors.borrow]), borderRadius: BorderRadius.circular(11)),
              alignment: Alignment.center, child: const Text('L', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17))),
          const SizedBox(width: 10),
        ],
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(fontSize: showBrand ? 18 : 24, fontWeight: FontWeight.w800, letterSpacing: -.5)),
          if (subtitle != null) Text(subtitle!, style: TextStyle(fontSize: 11, color: mutedColor(context), fontWeight: FontWeight.w600)),
        ])),
        IconButton(
          onPressed: () => ref.read(themeModeProvider.notifier).state = !dark,
          icon: Icon(dark ? Icons.light_mode : Icons.dark_mode, size: 20),
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: () => _showSettings(context, ref),
          child: Container(width: 40, height: 40,
              decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFEF4444)]), borderRadius: BorderRadius.circular(12)),
              alignment: Alignment.center, child: const Text('JS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14))),
        ),
      ]),
    );
  }
}

void _showSettings(BuildContext context, WidgetRef ref) {
  showModalBottomSheet(context: context, isScrollControlled: true,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
    builder: (_) => Consumer(builder: (context, r, _) {
      final dark = r.watch(themeModeProvider);
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 38, height: 4, margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(color: Colors.grey.withValues(alpha: .4), borderRadius: BorderRadius.circular(4)))),
          const Text('Settings', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          AppCard(child: Row(children: [
            Container(width: 56, height: 56,
                decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFEF4444)]), borderRadius: BorderRadius.circular(16)),
                alignment: Alignment.center, child: const Text('JS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20))),
            const SizedBox(width: 14),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Administrator', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              Text('admin@loanledger.lk', style: TextStyle(color: mutedColor(context), fontSize: 12.5)),
            ]),
          ])),
          const SizedBox(height: 14),
          AppCard(padding: EdgeInsets.zero, child: Column(children: [
            SwitchListTile(
              value: dark, onChanged: (v) => r.read(themeModeProvider.notifier).state = v,
              title: const Text('Dark mode'), secondary: const Icon(Icons.dark_mode),
            ),
            const Divider(height: 1),
            const ListTile(leading: Icon(Icons.notifications_active), title: Text('Reminders'), subtitle: Text('1 day before & on due date'), trailing: Text('On')),
            const Divider(height: 1),
            const ListTile(leading: Icon(Icons.attach_money), title: Text('Currency'), subtitle: Text('Sri Lankan Rupee (LKR)')),
          ])),
          const SizedBox(height: 14),
          AppCard(padding: EdgeInsets.zero, child: ListTile(
            leading: const Icon(Icons.logout, color: AppColors.over),
            title: const Text('Sign out', style: TextStyle(color: AppColors.over)),
            onTap: () async {
              await r.read(authRepoProvider).logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
              }
            },
          )),
        ]),
      );
    }),
  );
}
