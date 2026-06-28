num _n(dynamic v) => v == null ? 0 : (v is num ? v : num.tryParse(v.toString()) ?? 0);
String? _s(dynamic v) => v?.toString();

class Expense {
  final String id, category;
  final String? subcategory, notes;
  final num amount;
  final String expenseDate, month;
  Expense.fromJson(Map<String, dynamic> j)
      : id = j['id'].toString(),
        category = j['category'] ?? '',
        subcategory = _s(j['subcategory']),
        notes = _s(j['notes']),
        amount = _n(j['amount']),
        expenseDate = (j['expense_date'] ?? '').toString(),
        month = (j['month'] ?? '').toString();
}

class Revenue {
  final String id, category;
  final String? description;
  final num amount;
  final String revenueDate, month;
  Revenue.fromJson(Map<String, dynamic> j)
      : id = j['id'].toString(),
        category = j['category'] ?? '',
        description = _s(j['description']),
        amount = _n(j['amount']),
        revenueDate = (j['revenue_date'] ?? '').toString(),
        month = (j['month'] ?? '').toString();
}

class Dashboard {
  final num netProfit, totalRevenue, totalExpenses, totalLent, totalBorrowed;
  final num interestEarned, interestPaid, collectToday, payToday;
  final int activeLoans, activeBorrowed, completedLoans, settledLoans;
  Dashboard.fromJson(Map<String, dynamic> j)
      : netProfit = _n(j['net_profit']),
        totalRevenue = _n(j['total_revenue']),
        totalExpenses = _n(j['total_expenses']),
        totalLent = _n(j['total_lent']),
        totalBorrowed = _n(j['total_borrowed']),
        interestEarned = _n(j['monthly_interest_earned']),
        interestPaid = _n(j['monthly_interest_paid']),
        collectToday = _n(j['collect_today']),
        payToday = _n(j['pay_today']),
        activeLoans = (j['active_loans'] ?? 0) as int,
        activeBorrowed = (j['active_borrowed'] ?? 0) as int,
        completedLoans = (j['completed_loans'] ?? 0) as int,
        settledLoans = (j['settled_loans'] ?? 0) as int;
}

class MonthlyReport {
  final String month;
  final num interestIncome, interestPaid, totalRevenue, totalExpenses, netProfit;
  final Map<String, num> revenueByCategory, expenseByCategory;
  MonthlyReport.fromJson(Map<String, dynamic> j)
      : month = j['month'] ?? '',
        interestIncome = _n(j['interest_income']),
        interestPaid = _n(j['interest_paid']),
        totalRevenue = _n(j['total_revenue']),
        totalExpenses = _n(j['total_expenses']),
        netProfit = _n(j['net_profit']),
        revenueByCategory = ((j['revenue_by_category'] as Map?) ?? {})
            .map((k, v) => MapEntry(k.toString(), _n(v))),
        expenseByCategory = ((j['expense_by_category'] as Map?) ?? {})
            .map((k, v) => MapEntry(k.toString(), _n(v)));
}

class TrendPoint {
  final String month;
  final num netProfit, totalRevenue, totalExpenses;
  TrendPoint.fromJson(Map<String, dynamic> j)
      : month = j['month'] ?? '',
        netProfit = _n(j['net_profit']),
        totalRevenue = _n(j['total_revenue']),
        totalExpenses = _n(j['total_expenses']);
}
