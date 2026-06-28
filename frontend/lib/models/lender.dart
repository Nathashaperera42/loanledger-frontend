num _n(dynamic v) => v == null ? 0 : (v is num ? v : num.tryParse(v.toString()) ?? 0);
String? _s(dynamic v) => v?.toString();

class LenderPayment {
  final String id, paymentType;
  final String paymentDate;
  final num amount, remainingBalance, interestPortion;
  final String? notes;
  LenderPayment.fromJson(Map<String, dynamic> j)
      : id = j['id'].toString(),
        paymentType = j['payment_type'] ?? '',
        paymentDate = (j['payment_date'] ?? '').toString(),
        amount = _n(j['amount']),
        remainingBalance = _n(j['remaining_balance']),
        interestPortion = _n(j['interest_portion']),
        notes = _s(j['notes']);
}

class Lender {
  final String id, name;
  final String? address, phone, notes;
  final num borrowedAmount, interestRate, remainingBalance, currentInterest;
  final String borrowDate, interestDueDate, status;
  final List<LenderPayment> payments;

  Lender.fromJson(Map<String, dynamic> j)
      : id = j['id'].toString(),
        name = j['lender_name'] ?? j['name'] ?? '',
        address = _s(j['address']),
        phone = _s(j['phone']),
        notes = _s(j['notes']),
        borrowedAmount = _n(j['borrowed_amount']),
        interestRate = _n(j['interest_rate']),
        remainingBalance = _n(j['remaining_balance']),
        currentInterest = _n(j['current_interest']),
        borrowDate = (j['borrow_date'] ?? '').toString(),
        interestDueDate = (j['interest_due_date'] ?? '').toString(),
        status = j['status'] ?? 'active',
        payments = ((j['payments'] as List?) ?? [])
            .map((e) => LenderPayment.fromJson(e)).toList();
}
