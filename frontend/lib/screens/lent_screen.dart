import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/colors.dart';
import '../core/format.dart';
import '../providers/providers.dart';
import '../widgets/common.dart';
import '../widgets/cards.dart';
import '../widgets/sheets.dart';
import 'app_header.dart';

class LentScreen extends ConsumerStatefulWidget {
  const LentScreen({super.key});
  @override
  ConsumerState<LentScreen> createState() => _LentScreenState();
}

class _LentScreenState extends ConsumerState<LentScreen> {
  bool active = true;
  final searchCtl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: active
          ? FloatingActionButton(
              backgroundColor: AppColors.primary,
              onPressed: () => showAddClientSheet(context, ref),
              child: const Icon(Icons.add, color: Colors.white))
          : null,
      body: SafeArea(
        child: Column(children: [
          const Padding(padding: EdgeInsets.symmetric(horizontal: 18), child: AppHeader(title: 'Lent out')),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 18),
              child: _tabs(active, (v) => setState(() => active = v))),
          Expanded(child: active ? _activeView() : _completedView()),
        ]),
      ),
    );
  }

  Widget _activeView() {
    final clients = ref.watch(clientsProvider);
    final filter = ref.watch(clientFilterProvider);
    return ListView(padding: const EdgeInsets.fromLTRB(18, 12, 18, 90), children: [
      _search(searchCtl, 'Search by name or phone', (v) => ref.read(clientSearchProvider.notifier).state = v),
      const SizedBox(height: 12),
      _marginBanner(),
      const SizedBox(height: 10),
      SizedBox(height: 40, child: ListView(scrollDirection: Axis.horizontal, children: [
        for (final f in const ['all', 'due-today', 'due-tom', 'overdue'])
          _chip(_filterLabel(f), filter == f, () => ref.read(clientFilterProvider.notifier).state = f),
      ])),
      const SizedBox(height: 8),
      clients.when(
        loading: () => const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator())),
        error: (e, _) => ErrorBox(e),
        data: (list) => list.isEmpty
            ? const EmptyState(Icons.person_outline, 'No clients match. Tap + to add one.')
            : Column(children: list.map((c) => ClientCard(c: c, onTap: () => showClientDetail(context, ref, c.id), onPhone: () => showPhoneSheet(context, c.name, c.phone))).toList()),
      ),
    ]);
  }

  Widget _marginBanner() {
    final clients = ref.watch(clientsProvider).valueOrNull ?? const [];
    final totalMargin = clients.fold<num>(0, (s, c) => s + c.marginInterest);
    final totalCharge = clients.fold<num>(0, (s, c) => s + c.currentInterest);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(12)),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('MONTHLY MARGIN PROFIT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primaryInk)),
          Text(rs(totalMargin), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primaryInk)),
        ]),
        Text('of ${rs(totalCharge)} charged', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primaryInk)),
      ]),
    );
  }

  Widget _completedView() {
    final completed = ref.watch(completedClientsProvider);
    return ListView(padding: const EdgeInsets.fromLTRB(18, 12, 18, 90), children: [
      completed.when(
        loading: () => const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator())),
        error: (e, _) => ErrorBox(e),
        data: (list) => list.isEmpty
            ? const EmptyState(Icons.folder_open, 'No completed loans yet.')
            : Column(children: list.map((c) {
                final client = c['client'] as Map?;
                return Padding(padding: const EdgeInsets.only(bottom: 10), child: AppCard(child: Row(children: [
                  Avatar(client?['name'] ?? '?', AppColors.paid),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Flexible(child: Text(client?['name'] ?? '—', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700))),
                      const SizedBox(width: 6), const StatusPill('completed'),
                    ]),
                    Text('Completed ${shortDate(c['completion_date'])}', style: TextStyle(fontSize: 12.5, color: mutedColor(context))),
                  ])),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text(rs(client?['loan_amount']), style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text('+${rs(c['total_interest_collected'])}', style: const TextStyle(fontSize: 11, color: AppColors.paid, fontWeight: FontWeight.w700)),
                  ]),
                ])));
              }).toList()),
      ),
    ]);
  }

  String _filterLabel(String f) => f == 'all' ? 'All' : f == 'due-today' ? 'Due today' : f == 'due-tom' ? 'Due tomorrow' : 'Overdue';
}

// shared small widgets used by Lent + Borrowed
Widget _tabs(bool first, ValueChanged<bool> onChange) => Container(
      margin: const EdgeInsets.only(top: 2, bottom: 4),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(color: const Color(0x11000000), borderRadius: BorderRadius.circular(14)),
      child: Row(children: [
        _tab('Active', first, () => onChange(true)),
        _tab('Completed', !first, () => onChange(false)),
      ]),
    );

Widget _tab(String label, bool on, VoidCallback onTap) => Expanded(
      child: GestureDetector(onTap: onTap, child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        alignment: Alignment.center,
        decoration: BoxDecoration(color: on ? AppColors.inkLight : Colors.transparent, borderRadius: BorderRadius.circular(10)),
        child: Text(label, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: on ? Colors.white : AppColors.mutedLight)),
      )),
    );

Widget _search(TextEditingController ctl, String hint, ValueChanged<String> onChanged) => TextField(
      controller: ctl, onChanged: onChanged,
      decoration: InputDecoration(hintText: hint, prefixIcon: const Icon(Icons.search, size: 20)),
    );

Widget _chip(String label, bool on, VoidCallback onTap) => Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(onTap: onTap, child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: on ? AppColors.inkLight : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: on ? AppColors.inkLight : AppColors.lineLight),
        ),
        child: Text(label, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: on ? Colors.white : AppColors.mutedLight)),
      )),
    );

// expose for borrowed_screen
Widget buildTabs(bool first, ValueChanged<bool> onChange) => _tabs(first, onChange);
Widget buildSearch(TextEditingController ctl, String hint, ValueChanged<String> onChanged) => _search(ctl, hint, onChanged);
