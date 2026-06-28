import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/colors.dart';
import '../core/format.dart';
import '../models/client.dart';
import '../models/lender.dart';
import '../providers/providers.dart';
import '../widgets/common.dart';
import '../widgets/cards.dart';
import '../widgets/sheets.dart';
import 'app_header.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dash = ref.watch(dashboardProvider);
    final due = ref.watch(dueProvider);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async { ref.invalidate(dashboardProvider); ref.invalidate(dueProvider); },
        child: ListView(padding: const EdgeInsets.fromLTRB(18, 6, 18, 24), children: [
          const AppHeader(title: 'LoanLedger', subtitle: 'Welcome back', showBrand: true),
          dash.when(
            loading: () => const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator())),
            error: (e, _) => ErrorBox(e),
            data: (d) => Column(children: [
              _hero(d.netProfit, d.totalRevenue, d.totalExpenses),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(child: _miniDue(context, 'You collect today', rs(d.collectToday), AppColors.primary)),
                const SizedBox(width: 10),
                Expanded(child: _miniDue(context, 'You pay today', rs(d.payToday), AppColors.borrowInk)),
              ]),
              const SizedBox(height: 12),
              GridView.count(crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 11, crossAxisSpacing: 11, childAspectRatio: 1.55, children: [
                _stat(context, '↗', AppColors.primary, AppColors.primarySoft, rs(d.totalLent), 'Money lent out'),
                _stat(context, '↘', AppColors.borrow, AppColors.borrowSoft, rs(d.totalBorrowed), 'Money borrowed'),
                _stat(context, '+', AppColors.paid, AppColors.paidSoft, rs(d.interestEarned), 'Interest earned'),
                _stat(context, '−', AppColors.due, AppColors.dueSoft, rs(d.interestPaid), 'Interest paid'),
              ]),
            ]),
          ),
          const SectionHeader('You collect — customers'),
          due.when(
            loading: () => const SizedBox(height: 60, child: Center(child: CircularProgressIndicator())),
            error: (e, _) => ErrorBox(e),
            data: (d) {
              final list = ((d['collect'] as List?) ?? []).take(3).map((e) => Client.fromJson(e)).toList();
              if (list.isEmpty) return const EmptyState(Icons.check, 'All collected');
              return Column(children: list.map((c) => ClientCard(c: c, onTap: () => showClientDetail(context, ref, c.id), onPhone: () => showPhoneSheet(context, c.name, c.phone))).toList());
            },
          ),
          const SectionHeader('You pay — lenders'),
          due.when(
            loading: () => const SizedBox(),
            error: (e, _) => const SizedBox(),
            data: (d) {
              final list = ((d['pay'] as List?) ?? []).take(3).map((e) => Lender.fromJson(e)).toList();
              if (list.isEmpty) return const EmptyState(Icons.check, 'Nothing to pay');
              return Column(children: list.map((l) => LenderCard(l: l, onTap: () => showLenderDetail(context, ref, l.id), onPhone: () => showPhoneSheet(context, l.name, l.phone))).toList());
            },
          ),
        ]),
      ),
    );
  }

  Widget _hero(num net, num rev, num exp) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AppColors.primary, AppColors.borrow], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('NET PROFIT · THIS MONTH', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: .8)),
          const SizedBox(height: 6),
          Text('${net < 0 ? '-' : ''}${rs(net.abs())}', style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _heroChip('↓ Total revenue', rs(rev))),
            const SizedBox(width: 10),
            Expanded(child: _heroChip('↑ Total expenses', rs(exp))),
          ]),
        ]),
      );

  Widget _heroChip(String k, String v) => Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: .16), borderRadius: BorderRadius.circular(12)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(k, style: const TextStyle(color: Colors.white70, fontSize: 10.5, fontWeight: FontWeight.w600)),
          const SizedBox(height: 3),
          Text(v, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
        ]),
      );

  Widget _miniDue(BuildContext c, String k, String v, Color color) => AppCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Flexible(child: Text(k, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700))),
          ]),
          const SizedBox(height: 4),
          Text(v, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        ]),
      );

  Widget _stat(BuildContext c, String icon, Color fg, Color bg, String value, String label) => AppCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(width: 30, height: 30, decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(9)),
              alignment: Alignment.center, child: Text(icon, style: TextStyle(color: fg, fontWeight: FontWeight.w800))),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          Text(label, style: TextStyle(fontSize: 11.5, color: mutedColor(c), fontWeight: FontWeight.w600)),
        ]),
      );
}
