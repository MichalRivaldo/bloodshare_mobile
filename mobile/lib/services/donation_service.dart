import '../core/api_client.dart';
import '../models/eligibility_model.dart';

class DonationService {
  final ApiClient _client = ApiClient.instance;

  Future<EligibilityModel> getEligibility() async {
    final response = await _client.getEligibility();
    final body = response.data as Map<String, dynamic>;
    if (response.statusCode == 200 && body['success'] == true) {
      return EligibilityModel.fromJson(body['data'] as Map<String, dynamic>);
    } else {
      throw Exception(body['message'] ?? 'Gagal memeriksa kelayakan donor');
    }
  }

  Future<List<Map<String, dynamic>>> getHistory({int page = 1, int limit = 20}) async {
    final response = await _client.getDonationHistory(page: page, limit: limit);
    final body = response.data as Map<String, dynamic>;
    if (response.statusCode == 200 && body['success'] == true) {
      return List<Map<String, dynamic>>.from(body['data']['history'] as List);
    } else {
      throw Exception(body['message'] ?? 'Gagal memuat riwayat');
    }
  }
}
