import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/client.dart';
import '../models/lender.dart';
import '../models/finance.dart';
import '../repositories/repositories.dart';
import '../core/format.dart';

// ---- repositories ----
final authRepoProvider = Provider((_) => AuthRepository());
final clientRepoProvider = Provider((_) => ClientRepository());
final lenderRepoProvider = Provider((_) => LenderRepository());
final financeRepoProvider = Provider((_) => FinanceRepository());
final reportRepoProvider = Provider((_) => ReportRepository());

// ---- ui state ----
final themeModeProvider = StateProvider<bool>((_) => false); // true = dark
final selectedMonthProvider = StateProvider<String>((_) => currentMonth());

// ---- clients ----
final clientSearchProvider = StateProvider<String>((_) => '');
final clientFilterProvider = StateProvider<String>((_) => 'all'); // all|due-today|due-tom|overdue

final clientsProvider = FutureProvider.autoDispose<List<Client>>((ref) async {
  final search = ref.watch(clientSearchProvider);
  final list = await ref.watch(clientRepoProvider).list(status: 'active', search: search);
  final f = ref.watch(clientFilterProvider);
  if (f == 'all') return list;
  return list.where((c) => dueState(c.interestDueDate) == f).toList();
});

final completedClientsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>(
    (ref) => ref.watch(clientRepoProvider).completed());

final clientDetailProvider = FutureProvider.autoDispose.family<Client, String>(
    (ref, id) => ref.watch(clientRepoProvider).getOne(id));

// ---- lenders ----
final lenderSearchProvider = StateProvider<String>((_) => '');
final lendersProvider = FutureProvider.autoDispose<List<Lender>>((ref) {
  final search = ref.watch(lenderSearchProvider);
  return ref.watch(lenderRepoProvider).list(status: 'active', search: search);
});
final settledLendersProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>(
    (ref) => ref.watch(lenderRepoProvider).settled());
final lenderDetailProvider = FutureProvider.autoDispose.family<Lender, String>(
    (ref, id) => ref.watch(lenderRepoProvider).getOne(id));

// ---- dashboard / due / reports ----
final dashboardProvider = FutureProvider.autoDispose((ref) => ref.watch(reportRepoProvider).dashboard());
final dueProvider = FutureProvider.autoDispose((ref) => ref.watch(reportRepoProvider).due());

final monthlyReportProvider = FutureProvider.autoDispose<MonthlyReport>((ref) {
  final month = ref.watch(selectedMonthProvider);
  return ref.watch(reportRepoProvider).monthly(month);
});
final trendProvider = FutureProvider.autoDispose((ref) => ref.watch(reportRepoProvider).trend(months: 6));

final monthExpensesProvider = FutureProvider.autoDispose<List<Expense>>((ref) {
  final month = ref.watch(selectedMonthProvider);
  return ref.watch(financeRepoProvider).expenses(month);
});
final monthRevenueProvider = FutureProvider.autoDispose<List<Revenue>>((ref) {
  final month = ref.watch(selectedMonthProvider);
  return ref.watch(financeRepoProvider).revenue(month);
});

final expenseCategoriesProvider = FutureProvider<List<String>>(
    (ref) => ref.watch(financeRepoProvider).categories('expense'));
final revenueCategoriesProvider = FutureProvider<List<String>>(
    (ref) => ref.watch(financeRepoProvider).categories('revenue'));

// Invalidate everything after a mutation. Accepts WidgetRef (from widgets).
void refreshAll(WidgetRef ref) {
  ref.invalidate(clientsProvider);
  ref.invalidate(completedClientsProvider);
  ref.invalidate(lendersProvider);
  ref.invalidate(settledLendersProvider);
  ref.invalidate(dashboardProvider);
  ref.invalidate(dueProvider);
  ref.invalidate(monthlyReportProvider);
  ref.invalidate(trendProvider);
  ref.invalidate(monthExpensesProvider);
  ref.invalidate(monthRevenueProvider);
}
