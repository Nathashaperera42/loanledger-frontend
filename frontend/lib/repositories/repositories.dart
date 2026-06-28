import '../core/api_client.dart';
import '../models/client.dart';
import '../models/lender.dart';
import '../models/finance.dart';

final _dio = ApiClient.instance.dio;

class AuthRepository {
  Future<void> login(String email, String password) async {
    final res = await _dio.post('/auth/login', data: {'email': email, 'password': password});
    await ApiClient.instance.saveTokens(res.data['accessToken'], res.data['refreshToken']);
  }

  Future<void> logout() => ApiClient.instance.clear();
  Future<bool> isLoggedIn() => ApiClient.instance.isLoggedIn;

  Future<Map<String, dynamic>> me() async {
    final res = await _dio.get('/auth/me');
    return Map<String, dynamic>.from(res.data['user']);
  }
}

class ClientRepository {
  Future<List<Client>> list({String status = 'active', String search = ''}) async {
    final res = await _dio.get('/clients', queryParameters: {'status': status, 'search': search, 'pageSize': 100});
    return (res.data['data'] as List).map((e) => Client.fromJson(e)).toList();
  }

  Future<Client> getOne(String id) async {
    final res = await _dio.get('/clients/$id');
    return Client.fromJson(res.data['data']);
  }

  Future<Client> create(Map<String, dynamic> body) async {
    final res = await _dio.post('/clients', data: body);
    return Client.fromJson(res.data['data']);
  }

  Future<Client> addPayment(String id, Map<String, dynamic> body) async {
    final res = await _dio.post('/clients/$id/payments', data: body);
    return Client.fromJson(res.data['data']);
  }

  Future<Client> update(String id, Map<String, dynamic> body) async {
    final res = await _dio.put('/clients/$id', data: body);
    return Client.fromJson(res.data['data']);
  }

  Future<void> complete(String id) => _dio.post('/clients/$id/complete');
  Future<void> delete(String id) => _dio.delete('/clients/$id');

  Future<List<Map<String, dynamic>>> completed({String search = ''}) async {
    final res = await _dio.get('/clients/completed/list', queryParameters: {'search': search});
    return List<Map<String, dynamic>>.from(res.data['data']);
  }
}

class LenderRepository {
  Future<List<Lender>> list({String status = 'active', String search = ''}) async {
    final res = await _dio.get('/lenders', queryParameters: {'status': status, 'search': search});
    return (res.data['data'] as List).map((e) => Lender.fromJson(e)).toList();
  }

  Future<Lender> getOne(String id) async {
    final res = await _dio.get('/lenders/$id');
    return Lender.fromJson(res.data['data']);
  }

  Future<Lender> create(Map<String, dynamic> body) async {
    final res = await _dio.post('/lenders', data: body);
    return Lender.fromJson(res.data['data']);
  }

  Future<Lender> addPayment(String id, Map<String, dynamic> body) async {
    final res = await _dio.post('/lenders/$id/payments', data: body);
    return Lender.fromJson(res.data['data']);
  }

  Future<Lender> update(String id, Map<String, dynamic> body) async {
    final res = await _dio.put('/lenders/$id', data: body);
    return Lender.fromJson(res.data['data']);
  }

  Future<void> settle(String id) => _dio.post('/lenders/$id/settle');
  Future<void> delete(String id) => _dio.delete('/lenders/$id');

  Future<List<Map<String, dynamic>>> settled({String search = ''}) async {
    final res = await _dio.get('/lenders/settled/list', queryParameters: {'search': search});
    return List<Map<String, dynamic>>.from(res.data['data']);
  }
}

class FinanceRepository {
  Future<List<Expense>> expenses(String month) async {
    final res = await _dio.get('/finance/expenses', queryParameters: {'month': month});
    return (res.data['data'] as List).map((e) => Expense.fromJson(e)).toList();
  }

  Future<void> addExpense(Map<String, dynamic> body) => _dio.post('/finance/expenses', data: body);
  Future<void> updateExpense(String id, Map<String, dynamic> body) => _dio.put('/finance/expenses/$id', data: body);
  Future<void> deleteExpense(String id) => _dio.delete('/finance/expenses/$id');

  Future<List<Revenue>> revenue(String month) async {
    final res = await _dio.get('/finance/revenue', queryParameters: {'month': month});
    return (res.data['data'] as List).map((e) => Revenue.fromJson(e)).toList();
  }

  Future<void> addRevenue(Map<String, dynamic> body) => _dio.post('/finance/revenue', data: body);
  Future<void> updateRevenue(String id, Map<String, dynamic> body) => _dio.put('/finance/revenue/$id', data: body);
  Future<void> deleteRevenue(String id) => _dio.delete('/finance/revenue/$id');

  Future<List<String>> categories(String kind) async {
    final res = await _dio.get('/finance/categories', queryParameters: {'kind': kind});
    return (res.data['data'] as List).map((e) => e['name'].toString()).toList();
  }

  Future<void> addExpenseCategory(String name) => _dio.post('/finance/categories', data: {'name': name, 'kind': 'expense'});
  Future<void> addRevenueCategory(String name) => _dio.post('/finance/categories', data: {'name': name, 'kind': 'revenue'});
}

class ReportRepository {
  Future<Dashboard> dashboard() async {
    final res = await _dio.get('/dashboard');
    return Dashboard.fromJson(res.data['data']);
  }

  Future<Map<String, dynamic>> due() async {
    final res = await _dio.get('/due');
    return Map<String, dynamic>.from(res.data['data']);
  }

  Future<MonthlyReport> monthly(String month) async {
    final res = await _dio.get('/reports/monthly', queryParameters: {'month': month});
    return MonthlyReport.fromJson(res.data['data']);
  }

  Future<List<TrendPoint>> trend({int months = 6}) async {
    final res = await _dio.get('/reports/trend', queryParameters: {'months': months});
    return (res.data['data'] as List).map((e) => TrendPoint.fromJson(e)).toList();
  }
}
