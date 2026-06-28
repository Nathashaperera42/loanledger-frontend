num _n(dynamic v) => v == null ? 0 : (v is num ? v : num.tryParse(v.toString()) ?? 0);
String? _s(dynamic v) => v?.toString();

class Margin {
  final num chargeRate, costRate, marginRate, chargeInterest, costInterest, marginInterest;
  Margin(this.chargeRate, this.costRate, this.marginRate, this.chargeInterest, this.costInterest, this.marginInterest);
}

class Payment {
  final String id, paymentType;
  final String paymentDate;
  final num amount, balanceAfter, interestAfter, interestPortion;
  Payment.fromJson(Map<String, dynamic> j)
      : id = j['id'].toString(),
        paymentType = j['payment_type'] ?? '',
        paymentDate = (j['payment_date'] ?? '').toString(),
        amount = _n(j['amount']),
        balanceAfter = _n(j['balance_after_payment']),
        interestAfter = _n(j['interest_after_payment']),
        interestPortion = _n(j['interest_portion']);
}

class Client {
  final String id, name;
  final String? address, phone, job, notes, fundingName, fundingLenderId;
  final num loanAmount, interestRate, costRate, remainingBalance, currentInterest;
  final num marginRate, marginInterest, costInterest;
  final String loanStartDate, interestDueDate, status;
  final List<Payment> payments;

  Client.fromJson(Map<String, dynamic> j)
      : id = j['id'].toString(),
        name = j['name'] ?? '',
        address = _s(j['address']),
        phone = _s(j['phone']),
        job = _s(j['job']),
        notes = _s(j['notes']),
        fundingName = _s(j['funding_name']),
        fundingLenderId = _s(j['funding_lender_id']),
        loanAmount = _n(j['loan_amount']),
        interestRate = _n(j['interest_rate']),
        costRate = _n(j['cost_rate']),
        remainingBalance = _n(j['remaining_balance']),
        currentInterest = _n(j['current_interest']),
        marginRate = _n(j['margin_rate']),
        marginInterest = _n(j['margin_interest']),
        costInterest = _n(j['cost_interest']),
        loanStartDate = (j['loan_start_date'] ?? '').toString(),
        interestDueDate = (j['interest_due_date'] ?? '').toString(),
        status = j['status'] ?? 'active',
        payments = ((j['payments'] as List?) ?? [])
            .map((e) => Payment.fromJson(e)).toList();

  Margin? get margin => costRate > 0
      ? Margin(interestRate, costRate, marginRate, currentInterest, costInterest, marginInterest)
      : null;
}
