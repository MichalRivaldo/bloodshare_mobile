import '../core/api_client.dart';
import '../models/blood_request_model.dart';

class BloodRequestService {
  final ApiClient _client = ApiClient.instance;

  Future<Map<String, dynamic>> getRequests({
    String? golonganDarah,
    String? rhesus,
    String? kota,
    String? urgensi,
    String? status,
    int page = 1,
    int limit = 10,
  }) async {
    final params = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (golonganDarah != null && golonganDarah.isNotEmpty) params['golongan_darah'] = golonganDarah;
    if (rhesus != null && rhesus.isNotEmpty) params['rhesus'] = rhesus;
    if (kota != null && kota.isNotEmpty) params['kota'] = kota;
    if (urgensi != null && urgensi.isNotEmpty) params['urgensi'] = urgensi;
    if (status != null && status.isNotEmpty) params['status'] = status;

    final response = await _client.getRequests(params: params);
    final body = response.data as Map<String, dynamic>;
    if (response.statusCode == 200 && body['success'] == true) {
      final list = (body['data']['requests'] as List)
          .map((e) => BloodRequestModel.fromJson(e as Map<String, dynamic>))
          .toList();
      final pagination = body['data']['pagination'] as Map<String, dynamic>;
      return {'requests': list, 'pagination': pagination};
    } else {
      throw Exception(body['message'] ?? 'Gagal memuat permintaan');
    }
  }

  Future<BloodRequestModel> getRequestById(int id) async {
    final response = await _client.getRequestById(id);
    final body = response.data as Map<String, dynamic>;
    if (response.statusCode == 200 && body['success'] == true) {
      return BloodRequestModel.fromJson(body['data']['request'] as Map<String, dynamic>);
    } else {
      throw Exception(body['message'] ?? 'Permintaan tidak ditemukan');
    }
  }

  Future<BloodRequestModel> createRequest(Map<String, dynamic> data) async {
    final response = await _client.createRequest(data);
    final body = response.data as Map<String, dynamic>;
    if (response.statusCode == 201 && body['success'] == true) {
      return BloodRequestModel.fromJson(body['data']['request'] as Map<String, dynamic>);
    } else {
      throw Exception(body['message'] ?? 'Gagal membuat permintaan');
    }
  }

  Future<void> respondToRequest(int id, {String? pesan}) async {
    final response = await _client.respondToRequest(id, pesan: pesan);
    final body = response.data as Map<String, dynamic>;
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception(body['message'] ?? 'Gagal merespon permintaan');
    }
  }
}
