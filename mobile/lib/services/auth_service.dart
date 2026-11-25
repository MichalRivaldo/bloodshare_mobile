import '../core/api_client.dart';
import '../models/user_model.dart';

class AuthService {
  final ApiClient _client = ApiClient.instance;

  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    final response = await _client.register(data);
    final body = response.data as Map<String, dynamic>;
    if (response.statusCode == 201 && body['success'] == true) {
      final user = UserModel.fromJson(body['data']['user'] as Map<String, dynamic>);
      final token = body['data']['token'] as String;
      return {'user': user, 'token': token};
    } else {
      final msg = body['message'] as String? ?? 'Registrasi gagal';
      throw Exception(msg);
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _client.login(email, password);
    final body = response.data as Map<String, dynamic>;
    if (response.statusCode == 200 && body['success'] == true) {
      final user = UserModel.fromJson(body['data']['user'] as Map<String, dynamic>);
      final token = body['data']['token'] as String;
      return {'user': user, 'token': token};
    } else {
      final msg = body['message'] as String? ?? 'Email atau password salah';
      throw Exception(msg);
    }
  }

  Future<UserModel> getMe() async {
    final response = await _client.getMe();
    final body = response.data as Map<String, dynamic>;
    if (response.statusCode == 200 && body['success'] == true) {
      return UserModel.fromJson(body['data']['user'] as Map<String, dynamic>);
    } else {
      throw Exception(body['message'] ?? 'Gagal mengambil data user');
    }
  }

  Future<bool> toggleAvailability() async {
    final response = await _client.toggleAvailability();
    final body = response.data as Map<String, dynamic>;
    if (response.statusCode == 200 && body['success'] == true) {
      return (body['data']['is_donor_aktif'] as int) == 1;
    }
    throw Exception(body['message'] ?? 'Gagal mengubah ketersediaan donor');
  }
}
