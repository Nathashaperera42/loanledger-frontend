import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/colors.dart';
import '../core/format.dart';
import '../models/client.dart';
import '../models/lender.dart';
import '../models/finance.dart';
import '../providers/providers.dart';
import 'common.dart';
import 'cards.dart';

Future<T?> _sheet<T>(BuildContext context, Widget child) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Padding(padding: const EdgeInsets.fromLTRB(20, 12, 20, 26), child: child),
      ),
    ),
  );
}

Widget _grab() => Center(
      child: Container(width: 38, height: 4, margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(color: Colors.grey.withValues(alpha: .4), borderRadius: BorderRadius.circular(4))),
    );

Widget _head(BuildContext c, String title, String sub) => Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
          if (sub.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 2),
              child: Text(sub, style: TextStyle(color: mutedColor(c), fontSize: 13))),
        ])),
        IconButton(onPressed: () => Navigator.pop(c), icon: const Icon(Icons.close, size: 20)),
      ]),
    );

Widget _field(String label, TextEditingController ctl, {TextInputType? type, int maxLines = 1}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.only(left: 3, bottom: 6),
          child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.mutedLight))),
      TextField(controller: ctl, keyboardType: type, maxLines: maxLines),
    ]),
  );
}

Widget _segmented(List<String> opts, String value, ValueChanged<String> onChange, {Color accent = AppColors.primary}) {
  return Row(children: [
    for (final o in opts) Expanded(child: Padding(
      padding: EdgeInsets.only(right: o == opts.last ? 0 : 7),
      child: GestureDetector(
        onTap: () => onChange(o),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: value == o ? accent : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: value == o ? accent : AppColors.lineLight),
          ),
          child: Text(o, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: value == o ? Colors.white : AppColors.mutedLight)),
        ),
      ),
    )),
  ]);
}

Widget _dropdown(String label, String? value, List<String> items, ValueChanged<String> onChange) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.only(left: 3, bottom: 6),
          child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.mutedLight))),
      DropdownButtonFormField<String>(
        initialValue: items.contains(value) ? value : null,
        isExpanded: true,
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis))).toList(),
        onChanged: (v) { if (v != null) onChange(v); },
      ),
    ]),
  );
}

Future<String?> _promptNewCategory(BuildContext context, String title) {
  final ctl = TextEditingController();
  return showDialog<String>(context: context, builder: (_) => AlertDialog(
    title: Text(title),
    content: TextField(controller: ctl, autofocus: true, decoration: const InputDecoration(hintText: 'Category name')),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
      FilledButton(onPressed: () => Navigator.pop(context, ctl.text.trim()), child: const Text('Add')),
    ],
  ));
}

Future<bool> _confirmDelete(BuildContext context, String name) async {
  final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
    title: const Text('Delete?'),
    content: Text('This will permanently delete $name and all of their history. This cannot be undone.'),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
      FilledButton(style: FilledButton.styleFrom(backgroundColor: AppColors.over),
          onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
    ],
  ));
  return ok ?? false;
}

String _today() => DateTime.now().toIso8601String().substring(0, 10);
String _plus30() => DateTime.now().add(const Duration(days: 30)).toIso8601String().substring(0, 10);

// ============================== PHONE ==============================
void showPhoneSheet(BuildContext context, String name, String? phone) {
  final tel = (phone ?? '').replaceAll(' ', '');
  _sheet(context, Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _grab(),
    _head(context, name, phone ?? ''),
    _action(context, Icons.call, AppColors.paid, 'Call', () => launchUrl(Uri.parse('tel:$tel'))),
    _action(context, Icons.sms, AppColors.indigo, 'Send SMS', () => launchUrl(Uri.parse('sms:$tel'))),
    _action(context, Icons.chat, const Color(0xFF25D366), 'WhatsApp',
        () => launchUrl(Uri.parse('https://wa.me/${tel.replaceAll('+', '')}'), mode: LaunchMode.externalApplication)),
  ]));
}

Widget _action(BuildContext c, IconData ic, Color color, String label, VoidCallback onTap) {
  return InkWell(
    onTap: () { Navigator.pop(c); onTap(); },
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(children: [
        Container(width: 42, height: 42, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(13)),
            child: Icon(ic, color: Colors.white, size: 20)),
        const SizedBox(width: 14),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
      ]),
    ),
  );
}

// ============================== ADD CLIENT ==============================
void showAddClientSheet(BuildContext context, WidgetRef ref) {
  _sheet(context, _AddClientForm(ref));
}

class _AddClientForm extends ConsumerStatefulWidget {
  final WidgetRef ref;
  const _AddClientForm(this.ref);
  @override
  ConsumerState<_AddClientForm> createState() => _AddClientFormState();
}

class _AddClientFormState extends ConsumerState<_AddClientForm> {
  final name = TextEditingController(), addr = TextEditingController(), phone = TextEditingController();
  final job = TextEditingController(), loan = TextEditingController(), rate = TextEditingController();
  final notes = TextEditingController();
  String fundingName = 'Own capital';
  num costRate = 0;
  String? fundingLenderId;

  @override
  Widget build(BuildContext context) {
    final lenders = ref.watch(lendersProvider).valueOrNull ?? const [];
    final options = ['Own capital', ...lenders.map((l) => '${l.name} · ${l.interestRate}%')];
    final marginText = costRate > 0
        ? 'Charge ${rate.text.isEmpty ? '?' : rate.text}% − funding $costRate% margin'
        : 'Own capital — full ${rate.text.isEmpty ? '?' : rate.text}% is profit';
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _grab(),
      _head(context, 'Add client', 'Money you lend out'),
      _field('Full name', name),
      _field('Address', addr),
      Row(children: [Expanded(child: _field('Phone', phone, type: TextInputType.phone)), const SizedBox(width: 10), Expanded(child: _field('Job', job))]),
      Row(children: [Expanded(child: _field('Loan amount (Rs)', loan, type: TextInputType.number)),
        const SizedBox(width: 10),
        Expanded(child: Padding(padding: const EdgeInsets.only(bottom: 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Padding(padding: EdgeInsets.only(left: 3, bottom: 6), child: Text('You charge %', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.mutedLight))),
          TextField(controller: rate, keyboardType: TextInputType.number, onChanged: (_) => setState(() {})),
        ])))]),
      _dropdown('Funded by (capital source)', fundingName, options, (v) {
        setState(() {
          fundingName = v == 'Own capital' ? 'Own capital' : v.split(' · ').first;
          if (v == 'Own capital') { costRate = 0; fundingLenderId = null; }
          else {
            final l = lenders.firstWhere((x) => x.name == fundingName);
            costRate = l.interestRate; fundingLenderId = l.id;
          }
        });
      }),
      Padding(padding: const EdgeInsets.only(left: 3, bottom: 12),
          child: Text(marginText, style: const TextStyle(color: AppColors.paid, fontSize: 12.5, fontWeight: FontWeight.w700))),
      _field('Notes', notes, maxLines: 2),
      FilledButton(onPressed: () async {
        if (name.text.trim().isEmpty || loan.text.trim().isEmpty || rate.text.trim().isEmpty) {
          toast(context, 'Name, amount and rate are required'); return;
        }
        try {
          await ref.read(clientRepoProvider).create({
            'name': name.text.trim(), 'address': addr.text.trim(), 'phone': phone.text.trim(), 'job': job.text.trim(),
            'loan_amount': num.tryParse(loan.text) ?? 0, 'interest_rate': num.tryParse(rate.text) ?? 0,
            'cost_rate': costRate, 'funding_name': fundingName, 'funding_lender_id': fundingLenderId,
            'interest_due_date': _plus30(), 'notes': notes.text.trim(),
          });
          if (context.mounted) { Navigator.pop(context); refreshAll(ref); toast(context, 'Client added'); }
        } catch (_) { if (context.mounted) toast(context, 'Failed to add client'); }
      }, child: const Text('Save client')),
    ]);
  }
}

// ============================== ADD CUSTOMER PAYMENT ==============================
void showAddPaymentSheet(BuildContext context, WidgetRef ref, Client c) {
  _sheet(context, _PaymentForm(ref: ref, c: c));
}

class _PaymentForm extends StatefulWidget {
  final WidgetRef ref; final Client c;
  const _PaymentForm({required this.ref, required this.c});
  @override
  State<_PaymentForm> createState() => _PaymentFormState();
}

class _PaymentFormState extends State<_PaymentForm> {
  String type = 'Interest Only';
  final amt = TextEditingController();
  static const types = ['Interest Only', 'Loan Only', 'Loan + Interest'];
  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _grab(),
      _head(context, 'Add payment', '${c.name} · balance ${rs(c.remainingBalance)}'),
      _segmented(const ['Interest', 'Loan', 'Loan+Int'], _short(), (v) => setState(() => type = _full(v))),
      const SizedBox(height: 12),
      _field('Amount paid (Rs)', amt, type: TextInputType.number),
      Padding(padding: const EdgeInsets.only(left: 3, bottom: 12),
          child: Text(_hint(c), style: TextStyle(color: mutedColor(context), fontSize: 12.5, fontWeight: FontWeight.w600))),
      FilledButton(onPressed: () async {
        final a = num.tryParse(amt.text) ?? 0;
        if (a <= 0) { toast(context, 'Enter a valid amount'); return; }
        try {
          await widget.ref.read(clientRepoProvider).addPayment(c.id, {'amount': a, 'payment_type': type, 'payment_date': _today()});
          if (context.mounted) { Navigator.pop(context); refreshAll(widget.ref); toast(context, 'Payment recorded'); }
        } catch (_) { if (context.mounted) toast(context, 'Failed'); }
      }, child: const Text('Save payment')),
    ]);
  }
  String _short() => type == 'Loan Only' ? 'Loan' : type == 'Loan + Interest' ? 'Loan+Int' : 'Interest';
  String _full(String s) => s == 'Loan' ? 'Loan Only' : s == 'Loan+Int' ? 'Loan + Interest' : 'Interest Only';
  String _hint(Client c) {
    if (type == 'Interest Only') return 'Interest due ${rs(c.currentInterest)}. Balance unchanged, due +1 month.';
    if (type == 'Loan Only') return 'Reduces principal. Interest recalculated on remaining balance.';
    return 'Interest portion ${rs(c.currentInterest)} paid first, rest cuts the loan.';
  }
}

// ============================== ADD LENDER ==============================
void showAddLenderSheet(BuildContext context, WidgetRef ref) {
  final name = TextEditingController(), addr = TextEditingController(), phone = TextEditingController();
  final amt = TextEditingController(), rate = TextEditingController(), notes = TextEditingController();
  _sheet(context, Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _grab(),
    _head(context, 'Add lender', 'Money you borrowed'),
    _field('Lender name', name),
    _field('Address', addr),
    _field('Phone', phone, type: TextInputType.phone),
    Row(children: [Expanded(child: _field('Borrowed (Rs)', amt, type: TextInputType.number)), const SizedBox(width: 10), Expanded(child: _field('Interest %', rate, type: TextInputType.number))]),
    _field('Notes', notes, maxLines: 2),
    FilledButton(
      style: FilledButton.styleFrom(backgroundColor: AppColors.borrow),
      onPressed: () async {
        if (name.text.trim().isEmpty || amt.text.trim().isEmpty || rate.text.trim().isEmpty) {
          toast(context, 'Name, amount and rate are required'); return;
        }
        try {
          await ref.read(lenderRepoProvider).create({
            'lender_name': name.text.trim(), 'address': addr.text.trim(), 'phone': phone.text.trim(),
            'borrowed_amount': num.tryParse(amt.text) ?? 0, 'interest_rate': num.tryParse(rate.text) ?? 0,
            'interest_due_date': _plus30(), 'notes': notes.text.trim(),
          });
          if (context.mounted) { Navigator.pop(context); refreshAll(ref); toast(context, 'Lender added'); }
        } catch (_) { if (context.mounted) toast(context, 'Failed to add lender'); }
      },
      child: const Text('Save lender'),
    ),
  ]));
}

// ============================== PAY LENDER ==============================
void showPayLenderSheet(BuildContext context, WidgetRef ref, Lender l) {
  _sheet(context, _PayLenderForm(ref: ref, l: l));
}

class _PayLenderForm extends StatefulWidget {
  final WidgetRef ref; final Lender l;
  const _PayLenderForm({required this.ref, required this.l});
  @override
  State<_PayLenderForm> createState() => _PayLenderFormState();
}

class _PayLenderFormState extends State<_PayLenderForm> {
  String type = 'Interest Payment';
  final amt = TextEditingController(); final notes = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final l = widget.l;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _grab(),
      _head(context, 'Pay lender', '${l.name} · balance ${rs(l.remainingBalance)}'),
      _segmented(const ['Interest', 'Principal', 'Both'], _short(), (v) => setState(() => type = _full(v)), accent: AppColors.borrow),
      const SizedBox(height: 12),
      _field('Amount paid (Rs)', amt, type: TextInputType.number),
      _field('Notes (optional)', notes),
      FilledButton(
        style: FilledButton.styleFrom(backgroundColor: AppColors.borrow),
        onPressed: () async {
          final a = num.tryParse(amt.text) ?? 0;
          if (a <= 0) { toast(context, 'Enter a valid amount'); return; }
          try {
            await widget.ref.read(lenderRepoProvider).addPayment(l.id, {'amount': a, 'payment_type': type, 'notes': notes.text.trim(), 'payment_date': _today()});
            if (context.mounted) { Navigator.pop(context); refreshAll(widget.ref); toast(context, 'Payment recorded'); }
          } catch (_) { if (context.mounted) toast(context, 'Failed'); }
        },
        child: const Text('Save payment'),
      ),
    ]);
  }
  String _short() => type == 'Principal Payment' ? 'Principal' : type == 'Interest + Principal' ? 'Both' : 'Interest';
  String _full(String s) => s == 'Principal' ? 'Principal Payment' : s == 'Both' ? 'Interest + Principal' : 'Interest Payment';
}

// ============================== ADD / EDIT EXPENSE ==============================
void showExpenseSheet(BuildContext context, WidgetRef ref, {Expense? edit}) {
  _sheet(context, _ExpenseForm(edit: edit));
}

class _ExpenseForm extends ConsumerStatefulWidget {
  final Expense? edit;
  const _ExpenseForm({this.edit});
  @override
  ConsumerState<_ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends ConsumerState<_ExpenseForm> {
  late final sub = TextEditingController(text: widget.edit?.subcategory ?? '');
  late final amt = TextEditingController(text: widget.edit?.amount.toString() ?? '');
  late final notes = TextEditingController(text: widget.edit?.notes ?? '');
  String? category;
  @override
  void initState() { super.initState(); category = widget.edit?.category; }
  @override
  Widget build(BuildContext context) {
    final cats = ref.watch(expenseCategoriesProvider).valueOrNull ?? const [];
    category ??= cats.isNotEmpty ? cats.first : 'Other';
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _grab(),
      _head(context, widget.edit == null ? 'Add expense' : 'Edit expense', monthLabel(currentMonth())),
      _dropdown('Category', category, [...cats, '＋ New category…'], (v) async {
        if (v == '＋ New category…') {
          final n = await _promptNewCategory(context, 'New expense category');
          if (n != null && n.isNotEmpty) { await ref.read(financeRepoProvider).addExpenseCategory(n); ref.invalidate(expenseCategoriesProvider); setState(() => category = n); }
        } else { setState(() => category = v); }
      }),
      _field('Subcategory / detail', sub),
      _field('Amount (Rs)', amt, type: TextInputType.number),
      _field('Notes (optional)', notes),
      FilledButton(onPressed: () async {
        final a = num.tryParse(amt.text) ?? 0;
        if (a <= 0) { toast(context, 'Enter a valid amount'); return; }
        final body = {'category': category, 'subcategory': sub.text.trim(), 'amount': a, 'notes': notes.text.trim(), 'expense_date': _today()};
        final repo = ref.read(financeRepoProvider);
        if (widget.edit == null) { await repo.addExpense(body); } else { await repo.updateExpense(widget.edit!.id, body); }
        if (context.mounted) { Navigator.pop(context); refreshAll(ref); }
      }, child: Text(widget.edit == null ? 'Add expense' : 'Save changes')),
      if (widget.edit != null) ...[
        const SizedBox(height: 10),
        OutlinedButton(onPressed: () async { await ref.read(financeRepoProvider).deleteExpense(widget.edit!.id); if (context.mounted) { Navigator.pop(context); refreshAll(ref); } },
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.over), child: const Text('Delete')),
      ],
    ]);
  }
}

// ============================== ADD / EDIT REVENUE ==============================
void showRevenueSheet(BuildContext context, WidgetRef ref, {Revenue? edit}) {
  _sheet(context, _RevenueForm(edit: edit));
}

class _RevenueForm extends ConsumerStatefulWidget {
  final Revenue? edit;
  const _RevenueForm({this.edit});
  @override
  ConsumerState<_RevenueForm> createState() => _RevenueFormState();
}

class _RevenueFormState extends ConsumerState<_RevenueForm> {
  late final desc = TextEditingController(text: widget.edit?.description ?? '');
  late final amt = TextEditingController(text: widget.edit?.amount.toString() ?? '');
  String? category;
  @override
  void initState() { super.initState(); category = widget.edit?.category; }
  @override
  Widget build(BuildContext context) {
    final cats = ref.watch(revenueCategoriesProvider).valueOrNull ?? const [];
    category ??= cats.isNotEmpty ? cats.first : 'Other Income';
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _grab(),
      _head(context, widget.edit == null ? 'Add revenue' : 'Edit revenue', monthLabel(currentMonth())),
      _dropdown('Category', category, [...cats, '＋ New category…'], (v) async {
        if (v == '＋ New category…') {
          final n = await _promptNewCategory(context, 'New revenue category');
          if (n != null && n.isNotEmpty) { await ref.read(financeRepoProvider).addRevenueCategory(n); ref.invalidate(revenueCategoriesProvider); setState(() => category = n); }
        } else { setState(() => category = v); }
      }),
      _field('Description', desc),
      _field('Amount (Rs)', amt, type: TextInputType.number),
      FilledButton(onPressed: () async {
        final a = num.tryParse(amt.text) ?? 0;
        if (a <= 0) { toast(context, 'Enter a valid amount'); return; }
        final body = {'category': category, 'description': desc.text.trim(), 'amount': a, 'revenue_date': _today()};
        final repo = ref.read(financeRepoProvider);
        if (widget.edit == null) { await repo.addRevenue(body); } else { await repo.updateRevenue(widget.edit!.id, body); }
        if (context.mounted) { Navigator.pop(context); refreshAll(ref); }
      }, child: Text(widget.edit == null ? 'Add revenue' : 'Save changes')),
      if (widget.edit != null) ...[
        const SizedBox(height: 10),
        OutlinedButton(onPressed: () async { await ref.read(financeRepoProvider).deleteRevenue(widget.edit!.id); if (context.mounted) { Navigator.pop(context); refreshAll(ref); } },
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.over), child: const Text('Delete')),
      ],
    ]);
  }
}

// ============================== CLIENT DETAIL ==============================
void showClientDetail(BuildContext context, WidgetRef ref, String id) {
  _sheet(context, Consumer(builder: (context, r, _) {
    final async = r.watch(clientDetailProvider(id));
    return async.when(
      loading: () => const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator())),
      error: (e, _) => ErrorBox(e),
      data: (c) => _ClientDetail(c: c, ref: ref),
    );
  }));
}

class _ClientDetail extends StatelessWidget {
  final Client c; final WidgetRef ref;
  const _ClientDetail({required this.c, required this.ref});
  @override
  Widget build(BuildContext context) {
    final m = c.margin;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _grab(),
      Row(children: [
        Avatar(c.name, avatarColor(c.id)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(c.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          Text('${c.job ?? ''} · you collect', style: TextStyle(color: mutedColor(context), fontSize: 13)),
        ])),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (v) async {
            if (v != 'delete') return;
            if (!await _confirmDelete(context, c.name)) return;
            await ref.read(clientRepoProvider).delete(c.id);
            if (context.mounted) { Navigator.pop(context); refreshAll(ref); }
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'delete', child: Text('Delete client', style: TextStyle(color: AppColors.over))),
          ],
        ),
        IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
      ]),
      const SizedBox(height: 14),
      Row(children: [
        Expanded(child: balBox(context, 'Original loan', rs(c.loanAmount), 'Interest ${c.interestRate}%', false)),
        const SizedBox(width: 11),
        Expanded(child: balBox(context, 'Current balance', rs(c.remainingBalance), 'Interest ${rs(c.currentInterest)}', true)),
      ]),
      if (m != null) ...[ const SizedBox(height: 12), _marginBox(context, m) ],
      const SizedBox(height: 12),
      reminderBanner(context, 'Reminder: 1 day before & on ${shortDate(c.interestDueDate)}'),
      const SizedBox(height: 14),
      Row(children: [
        Expanded(child: FilledButton(onPressed: () { Navigator.pop(context); showAddPaymentSheet(context, ref, c); }, child: const Text('＋ Add payment'))),
        const SizedBox(width: 10),
        SizedBox(width: 54, height: 52, child: OutlinedButton(onPressed: () => showPhoneSheet(context, c.name, c.phone), child: const Icon(Icons.phone))),
      ]),
      if (c.remainingBalance <= 0) ...[
        const SizedBox(height: 10),
        FilledButton(style: FilledButton.styleFrom(backgroundColor: AppColors.paid),
            onPressed: () async { await ref.read(clientRepoProvider).complete(c.id); if (context.mounted) { Navigator.pop(context); refreshAll(ref); } },
            child: const Text('✓ Mark as completed')),
      ],
      const SectionHeader('Payment history'),
      if (c.payments.isEmpty) Text('No payments yet.', style: TextStyle(color: mutedColor(context)))
      else ...c.payments.map((p) => historyRow(context, p.paymentType, '${longDate(p.paymentDate)} · bal ${rs(p.balanceAfter)}', rs(p.amount), AppColors.paid)),
    ]);
  }
}

Widget _marginBox(BuildContext c, Margin m) {
  Widget line(String k, String v, Color color, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(k, style: TextStyle(fontSize: 12.5, fontWeight: bold ? FontWeight.w800 : FontWeight.w500)),
          Text(v, style: TextStyle(fontSize: bold ? 15 : 13, fontWeight: FontWeight.w800, color: color)),
        ]),
      );
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(14)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('YOUR PROFIT MARGIN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primaryInk, letterSpacing: .4)),
      const SizedBox(height: 8),
      line('You charge (${m.chargeRate}%)', '+${rs(m.chargeInterest)}', AppColors.paid),
      line('Funding cost (${m.costRate}%)', '−${rs(m.costInterest)}', AppColors.borrowInk),
      const Divider(height: 16),
      line('Net margin (${m.marginRate}%)', rs(m.marginInterest), AppColors.paid, bold: true),
    ]),
  );
}

// ============================== LENDER DETAIL ==============================
void showLenderDetail(BuildContext context, WidgetRef ref, String id) {
  _sheet(context, Consumer(builder: (context, r, _) {
    final async = r.watch(lenderDetailProvider(id));
    return async.when(
      loading: () => const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator())),
      error: (e, _) => ErrorBox(e),
      data: (l) => _LenderDetail(l: l, ref: ref),
    );
  }));
}

class _LenderDetail extends StatelessWidget {
  final Lender l; final WidgetRef ref;
  const _LenderDetail({required this.l, required this.ref});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _grab(),
      Row(children: [
        Avatar(l.name, AppColors.borrow),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          Text('Lender · you pay', style: TextStyle(color: mutedColor(context), fontSize: 13)),
        ])),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (v) async {
            if (v != 'delete') return;
            if (!await _confirmDelete(context, l.name)) return;
            await ref.read(lenderRepoProvider).delete(l.id);
            if (context.mounted) { Navigator.pop(context); refreshAll(ref); }
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'delete', child: Text('Delete lender', style: TextStyle(color: AppColors.over))),
          ],
        ),
        IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
      ]),
      const SizedBox(height: 14),
      Row(children: [
        Expanded(child: balBox(context, 'Original borrowed', rs(l.borrowedAmount), 'Interest ${l.interestRate}%', false)),
        const SizedBox(width: 11),
        Expanded(child: balBox(context, 'Current balance', rs(l.remainingBalance), 'Interest ${rs(l.currentInterest)}', true, borrow: true)),
      ]),
      const SizedBox(height: 12),
      reminderBanner(context, 'Reminder: pay ${l.name} 1 day before & on ${shortDate(l.interestDueDate)}'),
      const SizedBox(height: 14),
      Row(children: [
        Expanded(child: FilledButton(style: FilledButton.styleFrom(backgroundColor: AppColors.borrow),
            onPressed: () { Navigator.pop(context); showPayLenderSheet(context, ref, l); }, child: const Text('＋ Add interest payment'))),
        const SizedBox(width: 10),
        SizedBox(width: 54, height: 52, child: OutlinedButton(onPressed: () => showPhoneSheet(context, l.name, l.phone), child: const Icon(Icons.phone))),
      ]),
      if (l.remainingBalance <= 0) ...[
        const SizedBox(height: 10),
        FilledButton(style: FilledButton.styleFrom(backgroundColor: AppColors.paid),
            onPressed: () async { await ref.read(lenderRepoProvider).settle(l.id); if (context.mounted) { Navigator.pop(context); refreshAll(ref); } },
            child: const Text('✓ Mark as settled')),
      ],
      const SectionHeader('Payment history'),
      if (l.payments.isEmpty) Text('No payments yet.', style: TextStyle(color: mutedColor(context)))
      else ...l.payments.map((p) => historyRow(context, p.paymentType, '${longDate(p.paymentDate)} · bal ${rs(p.remainingBalance)}', rs(p.amount), AppColors.borrowInk)),
    ]);
  }
}
