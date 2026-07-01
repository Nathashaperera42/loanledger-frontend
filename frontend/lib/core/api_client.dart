import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Change this to your deployed backend URL.
/// Android emulator -> http://10.0.2.2:4000/api
/// Real device on same wifi -> http://<your-pc-ip>:4000/api
const String kApiBaseUrl = 'https://backend-psi-peach-87.vercel.app/api';

class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  final _storage = const FlutterSecureStorage();
  late final Dio dio = _build();

  static const _kAccess = 'access_token';
  static const _kRefresh = 'refresh_token';

  Future<String?> get accessToken => _storage.read(key: _kAccess);
  Future<String?> get refreshToken => _storage.read(key: _kRefresh);

  Future<void> saveTokens(String access, String refresh) async {
    await _storage.write(key: _kAccess, value: access);
    await _storage.write(key: _kRefresh, value: refresh);
  }

  Future<void> clear() async {
    await _storage.delete(key: _kAccess);
    await _storage.delete(key: _kRefresh);
  }

  Future<bool> get isLoggedIn async => (await accessToken) != null;

  Dio _build() {
    final d = Dio(BaseOptions(
      baseUrl: kApiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      headers: {'Content-Type': 'application/json'},
    ));

    d.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await accessToken;
        if (token != null) options.headers['Authorization'] = 'Bearer $token';
        handler.next(options);
      },
      onError: (e, handler) async {
        // Try a single refresh on 401, then replay the request.
        if (e.response?.statusCode == 401 && e.requestOptions.path != '/auth/refresh') {
          final rt = await refreshToken;
          if (rt != null) {
            try {
              final res = await Dio(BaseOptions(baseUrl: kApiBaseUrl))
                  .post('/auth/refresh', data: {'refreshToken': rt});
              await saveTokens(res.data['accessToken'], res.data['refreshToken']);
              final opts = e.requestOptions;
              opts.headers['Authorization'] = 'Bearer ${res.data['accessToken']}';
              final clone = await d.fetch(opts);
              return handler.resolve(clone);
            } catch (_) {
              await clear();
            }
          }
        }
        handler.next(e);
      },
    ));
    return d;
  }
}
