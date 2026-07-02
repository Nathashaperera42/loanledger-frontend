2import 'package:flutter/material.dart';
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
              alignment: Alignment.center, child: const Text('A', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14))),
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
                alignment: Alignment.center, child: const Text('A', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20))),
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
          AppCard(padding: EdgeInsets.zero, child: Column(children: [
            ListTile(
              leading: const Icon(Icons.lock_outline),
              title: const Text('Change password'),
              onTap: () { Navigator.pop(context); _showChangePassword(context, r); },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.over),
              title: const Text('Sign out', style: TextStyle(color: AppColors.over)),
              onTap: () async {
                await r.read(authRepoProvider).logout();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
                }
              },
            ),
          ])),
        ]),
      );
    }),
  );
}

void _showChangePassword(BuildContext context, WidgetRef ref) {
  final authRepo = ref.read(authRepoProvider); // capture before sheet opens
  final currentCtl = TextEditingController();
  final newCtl = TextEditingController();
  final confirmCtl = TextEditingController();
  bool loading = false;
  String? error;
  bool success = false;
  bool showCurrent = false;
  bool showNew = false;
  bool showConfirm = false;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
    builder: (ctx) => StatefulBuilder(builder: (ctx, setState) {
      return Padding(
        padding: EdgeInsets.fromLTRB(20, 14, 20, MediaQuery.of(ctx).viewInsets.bottom + 30),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 38, height: 4, margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(color: Colors.grey.withValues(alpha: .4), borderRadius: BorderRadius.circular(4)))),
          const Text('Change password', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          TextField(
            controller: currentCtl,
            obscureText: !showCurrent,
            onChanged: (_) => setState(() { error = null; success = false; }),
            decoration: InputDecoration(
              labelText: 'Current password',
              suffixIcon: IconButton(
                icon: Icon(showCurrent ? Icons.visibility : Icons.visibility_off, size: 20),
                onPressed: () => setState(() => showCurrent = !showCurrent),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: newCtl,
            obscureText: !showNew,
            onChanged: (_) => setState(() { error = null; success = false; }),
            decoration: InputDecoration(
              labelText: 'New password',
              suffixIcon: IconButton(
                icon: Icon(showNew ? Icons.visibility : Icons.visibility_off, size: 20),
                onPressed: () => setState(() => showNew = !showNew),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: confirmCtl,
            obscureText: !showConfirm,
            onChanged: (_) => setState(() { error = null; success = false; }),
            decoration: InputDecoration(
              labelText: 'Confirm new password',
              suffixIcon: IconButton(
                icon: Icon(showConfirm ? Icons.visibility : Icons.visibility_off, size: 20),
                onPressed: () => setState(() => showConfirm = !showConfirm),
              ),
            ),
          ),
          if (error != null) ...[
            const SizedBox(height: 10),
            Row(children: [
              const Icon(Icons.error_outline, color: AppColors.over, size: 16),
              const SizedBox(width: 6),
              Expanded(child: Text(error!, style: const TextStyle(color: AppColors.over, fontSize: 13, fontWeight: FontWeight.w600))),
            ]),
          ],
          if (success) ...[
            const SizedBox(height: 10),
            const Row(children: [
              Icon(Icons.check_circle_outline, color: AppColors.paid, size: 16),
              SizedBox(width: 6),
              Text('Password changed successfully!', style: TextStyle(color: AppColors.paid, fontSize: 13, fontWeight: FontWeight.w600)),
            ]),
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: loading ? null : () async {
              final current = currentCtl.text.trim();
              final next = newCtl.text;
              final confirm = confirmCtl.text;
              if (current.isEmpty || next.isEmpty || confirm.isEmpty) {
                setState(() => error = 'All fields are required');
                return;
              }
              if (next.length < 6) {
                setState(() => error = 'New password must be at least 6 characters');
                return;
              }
              if (next != confirm) {
                setState(() => error = 'New passwords do not match');
                return;
              }
              setState(() { loading = true; error = null; success = false; });
              try {
                await authRepo.changePassword(current, next);
                if (ctx.mounted) setState(() { loading = false; success = true; });
                await Future.delayed(const Duration(seconds: 1));
                if (ctx.mounted) Navigator.pop(ctx);
              } catch (e) {
                String msg;
                try {
                  final data = (e as dynamic).response?.data;
                  if (data != null && data['error'] != null) {
                    msg = data['error'].toString();
                  } else {
                    msg = '${e.runtimeType}: $e';
                  }
                } catch (_) {
                  msg = '${e.runtimeType}: $e';
                }
                if (ctx.mounted) setState(() { loading = false; error = msg; });
              }
            },
            child: loading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Save new password'),
          ),
        ]),
      );
    }),
  );
}
