import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/colors.dart';
import '../models/client.dart';
import '../models/lender.dart';
import '../providers/providers.dart';
import '../widgets/common.dart';
import '../widgets/cards.dart';
import '../widgets/sheets.dart';
import 'app_header.dart';

class DueScreen extends ConsumerWidget {
  const DueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final due = ref.watch(dueProvider);
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async => ref.invalidate(dueProvider),
        child: ListView(padding: const EdgeInsets.fromLTRB(18, 6, 18, 24), children: [
          const AppHeader(title: 'Due payments'),
          due.when(
            loading: () => const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator())),
            error: (e, _) => ErrorBox(e),
            data: (d) {
              final collect = ((d['collect'] as List?) ?? []).map((e) => Client.fromJson(e)).toList();
              final pay = ((d['pay'] as List?) ?? []).map((e) => Lender.fromJson(e)).toList();
              return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _groupHeader('You collect — customers', AppColors.primary),
                if (collect.isEmpty) const EmptyState(Icons.check, 'Nothing to collect')
                else ...collect.map((c) => ClientCard(c: c, onTap: () => showClientDetail(context, ref, c.id), onPhone: () => showPhoneSheet(context, c.name, c.phone))),
                const SizedBox(height: 12),
                _groupHeader('You pay — lenders', AppColors.borrowInk),
                if (pay.isEmpty) const EmptyState(Icons.check, 'Nothing to pay')
                else ...pay.map((l) => LenderCard(l: l, onTap: () => showLenderDetail(context, ref, l.id), onPhone: () => showPhoneSheet(context, l.name, l.phone))),
              ]);
            },
          ),
        ]),
      ),
    );
  }

  Widget _groupHeader(String text, Color color) => Padding(
        padding: const EdgeInsets.fromLTRB(2, 16, 2, 9),
        child: Text(text.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: color, letterSpacing: .6)),
      );
}
