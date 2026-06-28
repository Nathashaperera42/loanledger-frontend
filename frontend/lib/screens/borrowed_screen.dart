import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/colors.dart';
import '../core/format.dart';
import '../providers/providers.dart';
import '../widgets/common.dart';
import '../widgets/cards.dart';
import '../widgets/sheets.dart';
import 'app_header.dart';
import 'lent_screen.dart' show buildTabs, buildSearch;

class BorrowedScreen extends ConsumerStatefulWidget {
  const BorrowedScreen({super.key});
  @override
  ConsumerState<BorrowedScreen> createState() => _BorrowedScreenState();
}

class _BorrowedScreenState extends ConsumerState<BorrowedScreen> {
  bool active = true;
  final searchCtl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: active
          ? FloatingActionButton(
              backgroundColor: AppColors.borrow,
              onPressed: () => showAddLenderSheet(context, ref),
              child: const Icon(Icons.add, color: Colors.white))
          : null,
      body: SafeArea(
        child: Column(children: [
          const Padding(padding: EdgeInsets.symmetric(horizontal: 18), child: AppHeader(title: 'Borrowed')),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 18),
              child: _settledTabs(active, (v) => setState(() => active = v))),
          Expanded(child: active ? _activeView() : _settledView()),
        ]),
      ),
    );
  }

  Widget _settledTabs(bool first, ValueChanged<bool> onChange) => Container(
        margin: const EdgeInsets.only(top: 2, bottom: 4),
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(color: const Color(0x11000000), borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          _tab('Active', first, () => onChange(true)),
          _tab('Settled', !first, () => onChange(false)),
        ]),
      );

  Widget _tab(String label, bool on, VoidCallback onTap) => Expanded(
        child: GestureDetector(onTap: onTap, child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9), alignment: Alignment.center,
          decoration: BoxDecoration(color: on ? AppColors.inkLight : Colors.transparent, borderRadius: BorderRadius.circular(10)),
          child: Text(label, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: on ? Colors.white : AppColors.mutedLight)),
        )),
      );

  Widget _activeView() {
    final lenders = ref.watch(lendersProvider);
    return ListView(padding: const EdgeInsets.fromLTRB(18, 12, 18, 90), children: [
      buildSearch(searchCtl, 'Search lenders', (v) => ref.read(lenderSearchProvider.notifier).state = v),
      const SizedBox(height: 12),
      lenders.when(
        loading: () => const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator())),
        error: (e, _) => ErrorBox(e),
        data: (list) => list.isEmpty
            ? const EmptyState(Icons.account_balance, 'No lenders yet. Tap + to add one.')
            : Column(children: list.map((l) => LenderCard(l: l, onTap: () => showLenderDetail(context, ref, l.id), onPhone: () => showPhoneSheet(context, l.name, l.phone))).toList()),
      ),
    ]);
  }

  Widget _settledView() {
    final settled = ref.watch(settledLendersProvider);
    return ListView(padding: const EdgeInsets.fromLTRB(18, 12, 18, 90), children: [
      settled.when(
        loading: () => const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator())),
        error: (e, _) => ErrorBox(e),
        data: (list) => list.isEmpty
            ? const EmptyState(Icons.folder_open, 'No settled loans yet.')
            : Column(children: list.map((c) {
                final l = c['lender'] as Map?;
                return Padding(padding: const EdgeInsets.only(bottom: 10), child: AppCard(child: Row(children: [
                  Avatar(l?['lender_name'] ?? '?', AppColors.paid),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Flexible(child: Text(l?['lender_name'] ?? '—', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700))),
                      const SizedBox(width: 6), const StatusPill('settled'),
                    ]),
                    Text('Settled ${shortDate(c['settlement_date'])}', style: TextStyle(fontSize: 12.5, color: mutedColor(context))),
                  ])),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text(rs(l?['borrowed_amount']), style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text('−${rs(c['total_interest_paid'])}', style: const TextStyle(fontSize: 11, color: AppColors.borrowInk, fontWeight: FontWeight.w700)),
                  ]),
                ])));
              }).toList()),
      ),
    ]);
  }
}
