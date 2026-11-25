import 'package:flutter/material.dart';
import '../models/blood_request_model.dart';
import '../services/blood_request_service.dart';

class BloodRequestProvider extends ChangeNotifier {
  final BloodRequestService _service = BloodRequestService();

  List<BloodRequestModel> _requests = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;

  int _currentPage = 1;
  int _totalPages = 1;
  int _totalItems = 0;

  // Filter state
  String? _selectedGolongan;
  String? _selectedUrgensi;
  String? _selectedKota;

  List<BloodRequestModel> get requests => _requests;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalItems => _totalItems;
  bool get hasMore => _currentPage < _totalPages;

  String? get selectedGolongan => _selectedGolongan;
  String? get selectedUrgensi => _selectedUrgensi;
  String? get selectedKota => _selectedKota;

  void setFilter({String? golongan, String? urgensi, String? kota}) {
    _selectedGolongan = golongan;
    _selectedUrgensi = urgensi;
    _selectedKota = kota;
    fetchRequests(refresh: true);
  }

  void clearFilters() {
    _selectedGolongan = null;
    _selectedUrgensi = null;
    _selectedKota = null;
    fetchRequests(refresh: true);
  }

  Future<void> fetchRequests({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    } else {
      if (_isLoadingMore || !hasMore) return;
      _isLoadingMore = true;
      notifyListeners();
    }

    try {
      final res = await _service.getRequests(
        golonganDarah: _selectedGolongan,
        urgensi: _selectedUrgensi,
        kota: _selectedKota,
        status: 'aktif',
        page: _currentPage,
        limit: 10,
      );

      final newItems = res['requests'] as List<BloodRequestModel>;
      final pagination = res['pagination'] as Map<String, dynamic>;

      _totalPages = (pagination['total_pages'] as num?)?.toInt() ?? 1;
      _totalItems = (pagination['total'] as num?)?.toInt() ?? 0;

      if (refresh) {
        _requests = newItems;
      } else {
        _requests.addAll(newItems);
      }
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (hasMore && !_isLoadingMore && !_isLoading) {
      _currentPage++;
      await fetchRequests(refresh: false);
    }
  }

  Future<BloodRequestModel?> getDetail(int id) async {
    try {
      return await _service.getRequestById(id);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  Future<bool> respondToRequest(int id, {String? pesan}) async {
    try {
      await _service.respondToRequest(id, pesan: pesan);
      // Refresh current list after respond
      fetchRequests(refresh: true);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> createRequest(Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.createRequest(data);
      fetchRequests(refresh: true);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
