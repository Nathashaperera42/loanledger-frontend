import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../core/colors.dart';
import '../core/format.dart';
import '../models/finance.dart';
import '../providers/providers.dart';
import '../widgets/common.dart';
import '../widgets/sheets.dart';
import 'app_header.dart';

class ProfitScreen extends ConsumerStatefulWidget {
  const ProfitScreen({super.key});
  @override
  ConsumerState<ProfitScreen> createState() => _ProfitScreenState();
}

class _ProfitScreenState extends ConsumerState<ProfitScreen> {
  int sub = 0; // 0 summary, 1 revenue, 2 expenses

  void _stepMonth(int delta) {
    final cur = ref.read(selectedMonthProvider);
    final p = cur.split('-');
    final dt = DateTime(int.parse(p[0]), int.parse(p[1]) + delta);
    ref.read(selectedMonthProvider.notifier).state = DateFormat('yyyy-MM').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final month = ref.watch(selectedMonthProvider);
    return SafeArea(
      child: ListView(padding: const EdgeInsets.fromLTRB(18, 6, 18, 24), children: [
        const AppHeader(title: 'Profit'),
        _monthSwitcher(month),
        const SizedBox(height: 12),
        _subTabs(),
        const SizedBox(height: 12),
        if (sub == 0) _summary() else if (sub == 1) _revenue() else _expenses(),
      ]),
    );
  }

  Widget _monthSwitcher(String month) => AppCard(
        padding: const EdgeInsets.all(6),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          IconButton(onPressed: () => _stepMonth(-1), icon: const Icon(Icons.chevron_left)),
          Text(monthLabel(month), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
          IconButton(onPressed: () => _stepMonth(1), icon: const Icon(Icons.chevron_right)),
        ]),
      );

  Widget _subTabs() => Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(color: const Color(0x11000000), borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          for (final t in const [(0, 'Summary'), (1, 'Revenue'), (2, 'Expenses')])
            Expanded(child: GestureDetector(onTap: () => setState(() => sub = t.$1), child: Container(
              padding: const EdgeInsets.symmetric(vertical: 9), alignment: Alignment.center,
              decoration: BoxDecoration(color: sub == t.$1 ? AppColors.inkLight : Colors.transparent, borderRadius: BorderRadius.circular(10)),
              child: Text(t.$2, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: sub == t.$1 ? Colors.white : AppColors.mutedLight)),
            ))),
        ]),
      );

  // ----- SUMMARY -----
  Widget _summary() {
    final report = ref.watch(monthlyReportProvider);
    final trend = ref.watch(trendProvider);
    return report.when(
      loading: () => const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator())),
      error: (e, _) => ErrorBox(e),
      data: (r) {
        final maxRE = [r.totalRevenue, r.totalExpenses, 1].reduce((a, b) => a > b ? a : b);
        final expEntries = r.expenseByCategory.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
        final maxExp = expEntries.isEmpty ? 1 : expEntries.first.value;
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _netCard(r),
          const SizedBox(height: 14),
          GridView.count(crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 11, crossAxisSpacing: 11, childAspectRatio: 2.0, children: [
            _kv('Total revenue', rs(r.totalRevenue), AppColors.paid),
            _kv('Total expenses', rs(r.totalExpenses), AppColors.borrowInk),
            _kv('Interest earned', rs(r.interestIncome), AppColors.paid),
            _kv('Interest paid', rs(r.interestPaid), AppColors.borrowInk),
          ]),
          const SectionHeader('Revenue vs expenses'),
          AppCard(child: Column(children: [
            _bar('Revenue', r.totalRevenue, maxRE.toDouble(), AppColors.paid),
            const SizedBox(height: 8),
            _bar('Expenses', r.totalExpenses, maxRE.toDouble(), AppColors.borrow),
          ])),
          const SectionHeader('Expense breakdown'),
          AppCard(child: Column(children: expEntries.map((e) => Padding(padding: const EdgeInsets.symmetric(vertical: 4),
              child: _bar(e.key, e.value, maxExp.toDouble(), AppColors.borrow))).toList())),
          const SectionHeader('Monthly profit trend'),
          trend.when(
            loading: () => const SizedBox(height: 80, child: Center(child: CircularProgressIndicator())),
            error: (e, _) => const SizedBox(),
            data: (points) => AppCard(child: _trendChart(points)),
          ),
          const SectionHeader('Revenue table'),
          _table(r.revenueByCategory, r.totalRevenue, AppColors.paid),
          const SectionHeader('Expense table'),
          _table(r.expenseByCategory, r.totalExpenses, AppColors.borrowInk),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: OutlinedButton.icon(onPressed: () => toast(context, 'PDF export runs in the full app'), icon: const Icon(Icons.picture_as_pdf, size: 18), label: const Text('PDF'))),
            const SizedBox(width: 8),
            Expanded(child: OutlinedButton.icon(onPressed: () => toast(context, 'Excel export runs in the full app'), icon: const Icon(Icons.table_chart, size: 18), label: const Text('Excel'))),
          ]),
        ]);
      },
    );
  }

  Widget _netCard(MonthlyReport r) {
    final loss = r.netProfit < 0;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: loss ? [AppColors.over, const Color(0xFFB5362B)] : [AppColors.paid, const Color(0xFF0A8F5C)]),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('${loss ? 'NET LOSS' : 'NET PROFIT'} · ${monthLabel(r.month)}', style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: .6)),
        const SizedBox(height: 6),
        Text('${loss ? '-' : ''}${rs(r.netProfit.abs())}', style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text('Revenue ${rs(r.totalRevenue)} − Expenses ${rs(r.totalExpenses)}', style: const TextStyle(color: Colors.white70, fontSize: 12.5, fontWeight: FontWeight.w500)),
      ]),
    );
  }

  Widget _kv(String k, String v, Color color) => AppCard(child: Column(
        mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(v, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
        Text(k, style: TextStyle(fontSize: 11.5, color: mutedColor(context), fontWeight: FontWeight.w600)),
      ]));

  Widget _bar(String label, num value, double max, Color color) => Row(children: [
        SizedBox(width: 92, child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis)),
        Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(
          value: max == 0 ? 0 : (value / max).clamp(0, 1).toDouble(),
          minHeight: 10, backgroundColor: lineColor(context), color: color,
        ))),
        const SizedBox(width: 10),
        Text(rs(value), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
      ]);

  Widget _trendChart(List<TrendPoint> points) {
    final maxAbs = points.fold<num>(1, (m, p) => p.netProfit.abs() > m ? p.netProfit.abs() : m);
    return SizedBox(height: 110, child: Row(crossAxisAlignment: CrossAxisAlignment.end,
      children: points.map((p) {
        final h = (p.netProfit.abs() / maxAbs * 70).clamp(4, 70).toDouble();
        return Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
          Text('${p.netProfit < 0 ? '-' : ''}${(p.netProfit.abs() / 1000).round()}k', style: TextStyle(fontSize: 10, color: mutedColor(context), fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Container(width: 22, height: h, decoration: BoxDecoration(
            color: p.netProfit < 0 ? AppColors.over : AppColors.paid,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)))),
          const SizedBox(height: 5),
          Text(monthShort(p.month), style: TextStyle(fontSize: 11, color: mutedColor(context), fontWeight: FontWeight.w700)),
        ]));
      }).toList()),
    );
  }

  Widget _table(Map<String, num> data, num total, Color totalColor) {
    final entries = data.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return AppCard(child: Column(children: [
      ...entries.map((e) => Padding(padding: const EdgeInsets.symmetric(vertical: 7), child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Flexible(child: Text(e.key, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
          Text(rs(e.value), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        ]))),
      const Divider(),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('Total', style: TextStyle(fontWeight: FontWeight.w800)),
        Text(rs(total), style: TextStyle(fontWeight: FontWeight.w800, color: totalColor)),
      ]),
    ]));
  }

  // ----- REVENUE -----
  Widget _revenue() {
    final month = ref.watch(selectedMonthProvider);
    final isCurrent = month == currentMonth();
    final revenue = ref.watch(monthRevenueProvider);
    final report = ref.watch(monthlyReportProvider);
    return Column(children: [
      if (isCurrent)
        _addButton('＋ Add revenue', AppColors.primary, () => showRevenueSheet(context, ref)),
      report.when(loading: () => const SizedBox(), error: (e, _) => const SizedBox(),
          data: (r) => _autoRow('Loan interest income', 'Auto from active loans', r.interestIncome, AppColors.paid)),
      revenue.when(
        loading: () => const Padding(padding: EdgeInsets.all(30), child: Center(child: CircularProgressIndicator())),
        error: (e, _) => ErrorBox(e),
        data: (list) {
          if (!isCurrent) return EmptyState(Icons.lock_outline, '${monthLabel(month)} is closed.\nSwitch to ${monthLabel(currentMonth())} to add entries.');
          if (list.isEmpty) return const EmptyState(Icons.note_add, 'No revenue added yet.');
          return Column(children: list.map((rv) => _entryRow(rv.category, rv.description ?? '—', rv.amount, AppColors.paid, () => showRevenueSheet(context, ref, edit: rv))).toList());
        },
      ),
    ]);
  }

  // ----- EXPENSES -----
  Widget _expenses() {
    final month = ref.watch(selectedMonthProvider);
    final isCurrent = month == currentMonth();
    final expenses = ref.watch(monthExpensesProvider);
    final report = ref.watch(monthlyReportProvider);
    return Column(children: [
      if (isCurrent)
        _addButton('＋ Add expense', AppColors.primary, () => showExpenseSheet(context, ref)),
      report.when(loading: () => const SizedBox(), error: (e, _) => const SizedBox(),
          data: (r) => _autoRow('Borrowing interest', 'Interest owed to lenders', r.interestPaid, AppColors.borrow)),
      expenses.when(
        loading: () => const Padding(padding: EdgeInsets.all(30), child: Center(child: CircularProgressIndicator())),
        error: (e, _) => ErrorBox(e),
        data: (list) {
          if (!isCurrent) return EmptyState(Icons.lock_outline, '${monthLabel(month)} is closed.\nSwitch to ${monthLabel(currentMonth())} to add entries.');
          if (list.isEmpty) return const EmptyState(Icons.note_add, 'No expenses added yet.');
          final cats = <String>{for (final e in list) e.category};
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            for (final cat in cats) ...[
              Padding(padding: const EdgeInsets.fromLTRB(2, 12, 2, 8),
                  child: Text(cat.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: mutedColor(context), letterSpacing: .5))),
              ...list.where((e) => e.category == cat).map((e) => _entryRow(e.subcategory ?? e.category, e.category, e.amount, AppColors.borrowInk, () => showExpenseSheet(context, ref, edit: e))),
            ],
          ]);
        },
      ),
    ]);
  }

  Widget _addButton(String label, Color color, VoidCallback onTap) => Padding(
        padding: const EdgeInsets.only(bottom: 13),
        child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(14), child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14), alignment: Alignment.center,
          decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primary, width: 1.5, style: BorderStyle.solid)),
          child: Text(label, style: const TextStyle(color: AppColors.primaryInk, fontWeight: FontWeight.w800, fontSize: 14)),
        )),
      );

  Widget _autoRow(String title, String sub, num amount, Color color) => Padding(
        padding: const EdgeInsets.only(bottom: 9),
        child: Container(padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            Container(width: 38, height: 38, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(11)),
                child: const Icon(Icons.percent, color: Colors.white, size: 16)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(width: 6),
                Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(6)),
                    child: const Text('AUTO', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800)))]),
              Text(sub, style: TextStyle(fontSize: 11.5, color: mutedColor(context), fontWeight: FontWeight.w600)),
            ])),
            Text(rs(amount), style: TextStyle(fontWeight: FontWeight.w800, color: color)),
          ]),
        ),
      );

  Widget _entryRow(String title, String sub, num amount, Color color, VoidCallback onTap) => Padding(
        padding: const EdgeInsets.only(bottom: 9),
        child: AppCard(onTap: onTap, padding: const EdgeInsets.all(12), child: Row(children: [
          Container(width: 38, height: 38, decoration: BoxDecoration(color: color.withValues(alpha: .14), borderRadius: BorderRadius.circular(11)),
              child: Icon(color == AppColors.paid ? Icons.add : Icons.remove, color: color, size: 18)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            Text(sub, style: TextStyle(fontSize: 12, color: mutedColor(context), fontWeight: FontWeight.w600)),
          ])),
          Text(rs(amount), style: TextStyle(fontWeight: FontWeight.w800, color: color)),
        ])),
      );
}
