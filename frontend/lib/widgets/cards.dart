import 'package:flutter/material.dart';
import '../core/colors.dart';
import '../core/format.dart';
import '../models/client.dart';
import '../models/lender.dart';
import 'common.dart';

class ClientCard extends StatelessWidget {
  final Client c; final VoidCallback onTap; final VoidCallback onPhone;
  const ClientCard({required this.c, required this.onTap, required this.onPhone, super.key});
  @override
  Widget build(BuildContext context) {
    final st = dueState(c.interestDueDate);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        onTap: onTap,
        child: Row(children: [
          Avatar(c.name, avatarColor(c.id)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(c.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Row(children: [
              GestureDetector(onTap: onPhone, child: Text(c.phone ?? '—',
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 12.5))),
              if (c.marginRate > 0 && c.costRate > 0) ...[
                Text('  ·  ', style: TextStyle(color: mutedColor(context), fontSize: 12.5)),
                Text('▲ ${c.marginRate}% margin', style: const TextStyle(color: AppColors.paid, fontWeight: FontWeight.w800, fontSize: 12)),
              ],
            ]),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(rs(c.remainingBalance), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Row(children: [
              Text('${shortDate(c.interestDueDate)} · ', style: TextStyle(fontSize: 11, color: mutedColor(context), fontWeight: FontWeight.w600)),
              StatusPill(st),
            ]),
          ]),
        ]),
      ),
    );
  }
}

class LenderCard extends StatelessWidget {
  final Lender l; final VoidCallback onTap; final VoidCallback onPhone;
  const LenderCard({required this.l, required this.onTap, required this.onPhone, super.key});
  @override
  Widget build(BuildContext context) {
    final st = dueState(l.interestDueDate);
    final pill = st == 'upcoming' ? 'borrow' : st;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        onTap: onTap,
        child: Row(children: [
          Avatar(l.name, AppColors.borrow),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Flexible(child: Text(l.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700))),
              const SizedBox(width: 6),
              Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: AppColors.borrowSoft, borderRadius: BorderRadius.circular(6)),
                  child: const Text('YOU OWE', style: TextStyle(color: AppColors.borrowInk, fontSize: 9, fontWeight: FontWeight.w800))),
            ]),
            const SizedBox(height: 2),
            GestureDetector(onTap: onPhone, child: Text(l.phone ?? '—',
                style: const TextStyle(color: AppColors.borrowInk, fontWeight: FontWeight.w700, fontSize: 12.5))),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(rs(l.remainingBalance), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Row(children: [
              Text('${shortDate(l.interestDueDate)} · ', style: TextStyle(fontSize: 11, color: mutedColor(context), fontWeight: FontWeight.w600)),
              StatusPill(pill, label: st == 'upcoming' ? 'Active' : null),
            ]),
          ]),
        ]),
      ),
    );
  }
}

// shared detail bits used by sheets
Widget balBox(BuildContext c, String h, String big, String line, bool updated, {bool borrow = false}) {
  final soft = borrow ? AppColors.borrowSoft : AppColors.primarySoft;
  final ink = borrow ? AppColors.borrowInk : AppColors.primaryInk;
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: updated ? soft : cardColor(c),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: updated ? Colors.transparent : lineColor(c)),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(h.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: updated ? ink : mutedColor(c), letterSpacing: .4)),
      const SizedBox(height: 8),
      Text(big, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
      const SizedBox(height: 4),
      Text(line, style: TextStyle(fontSize: 12.5, color: mutedColor(c), fontWeight: FontWeight.w600)),
    ]),
  );
}

Widget historyRow(BuildContext c, String title, String sub, String amount, Color color) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 11),
    child: Row(children: [
      Container(width: 36, height: 36,
          decoration: BoxDecoration(color: color.withValues(alpha: .14), borderRadius: BorderRadius.circular(11)),
          child: Icon(Icons.percent, color: color, size: 16)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
        Text(sub, style: TextStyle(fontSize: 11.5, color: mutedColor(c), fontWeight: FontWeight.w600)),
      ])),
      Text(amount, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color)),
    ]),
  );
}

Widget reminderBanner(BuildContext c, String text) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(color: AppColors.dueSoft, borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        const Icon(Icons.notifications_active, color: AppColors.due, size: 17),
        const SizedBox(width: 9),
        Expanded(child: Text(text, style: const TextStyle(color: AppColors.due, fontSize: 12, fontWeight: FontWeight.w700))),
      ]),
    );
