import 'package:intl/intl.dart';

final _money = NumberFormat('#,##0', 'en_US');

/// Rs 100,000
String rs(num? n) => 'Rs ${_money.format((n ?? 0).round())}';

String initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  final letters = parts.take(2).map((p) => p.isNotEmpty ? p[0] : '').join();
  return letters.toUpperCase();
}

DateTime _parse(dynamic d) => d is DateTime ? d : DateTime.parse(d.toString());

String shortDate(dynamic d) => DateFormat('d MMM').format(_parse(d));
String longDate(dynamic d) => DateFormat('d MMM yyyy').format(_parse(d));

String currentMonth() => DateFormat('yyyy-MM').format(DateTime.now());

String monthLabel(String ym) {
  final p = ym.split('-');
  final dt = DateTime(int.parse(p[0]), int.parse(p[1]));
  return DateFormat('MMMM yyyy').format(dt);
}

String monthShort(String ym) {
  final p = ym.split('-');
  final dt = DateTime(int.parse(p[0]), int.parse(p[1]));
  return DateFormat('MMM').format(dt);
}

/// "overdue" | "due-today" | "due-tom" | "upcoming"
String dueState(dynamic dueDate) {
  final today = DateTime.now();
  final t0 = DateTime(today.year, today.month, today.day);
  final d = _parse(dueDate);
  final d0 = DateTime(d.year, d.month, d.day);
  final diff = d0.difference(t0).inDays;
  if (diff < 0) return 'overdue';
  if (diff == 0) return 'due-today';
  if (diff == 1) return 'due-tom';
  return 'upcoming';
}

String dueLabel(String state) {
  switch (state) {
    case 'overdue': return 'Overdue';
    case 'due-today': return 'Due today';
    case 'due-tom': return 'Due tomorrow';
    default: return 'Active';
  }
}
