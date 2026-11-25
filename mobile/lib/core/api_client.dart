import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';

class ApiClient {
  static ApiClient? _instance;
  late Dio _dio;

  ApiClient._() {
    _initDio(apiBaseUrl);
  }

  void _initDio(String baseUrl) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString(kTokenKey);
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  static ApiClient get instance {
    _instance ??= ApiClient._();
    return _instance!;
  }

  Dio get dio => _dio;

  void updateBaseUrl(String newUrl) {
    _dio.options.baseUrl = newUrl;
  }

  // ── Auth ─────────────────────────────────────────────────
  Future<Response> register(Map<String, dynamic> data) =>
      _dio.post('/api/auth/register', data: data);

  Future<Response> login(String email, String password) =>
      _dio.post('/api/auth/login', data: {'email': email, 'password': password});

  Future<Response> getMe() => _dio.get('/api/auth/me');

  Future<Response> updateProfile(Map<String, dynamic> data) =>
      _dio.put('/api/users/profile', data: data);

  Future<Response> toggleAvailability() =>
      _dio.patch('/api/users/availability');

  // ── Blood Requests ────────────────────────────────────────
  Future<Response> getRequests({Map<String, dynamic>? params}) =>
      _dio.get('/api/requests', queryParameters: params);

  Future<Response> getRequestById(int id) =>
      _dio.get('/api/requests/$id');

  Future<Response> createRequest(Map<String, dynamic> data) =>
      _dio.post('/api/requests', data: data);

  Future<Response> updateRequestStatus(int id, String status) =>
      _dio.patch('/api/requests/$id/status', data: {'status': status});

  Future<Response> respondToRequest(int id, {String? pesan}) =>
      _dio.post('/api/requests/$id/respond', data: {'pesan': pesan});

  // ── Events ────────────────────────────────────────────────
  Future<Response> getEvents({Map<String, dynamic>? params}) =>
      _dio.get('/api/events', queryParameters: params);

  Future<Response> getEventById(int id) =>
      _dio.get('/api/events/$id');

  Future<Response> joinEvent(int id) =>
      _dio.post('/api/events/$id/join');

  Future<Response> leaveEvent(int id) =>
      _dio.delete('/api/events/$id/join');

  // ── Donations & Eligibility ───────────────────────────────
  Future<Response> getEligibility() =>
      _dio.get('/api/donations/eligibility');

  Future<Response> getDonationHistory({int page = 1, int limit = 20}) =>
      _dio.get('/api/donations/history', queryParameters: {'page': page, 'limit': limit});

  // ── Matching & Stats ──────────────────────────────────────
  Future<Response> getMatches(int requestId) =>
      _dio.get('/api/requests/$requestId/matches');

  Future<Response> getStats() =>
      _dio.get('/api/stats');

  // ── Notifications ─────────────────────────────────────────
  Future<Response> getNotifications({int page = 1}) =>
      _dio.get('/api/notifications', queryParameters: {'page': page});

  Future<Response> markNotificationRead(int id) =>
      _dio.patch('/api/notifications/$id/read');
}
