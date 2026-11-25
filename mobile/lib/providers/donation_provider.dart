import 'package:flutter/material.dart';
import '../models/eligibility_model.dart';
import '../services/donation_service.dart';

class DonationProvider extends ChangeNotifier {
  final DonationService _service = DonationService();

  EligibilityModel? _eligibility;
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = false;
  String? _errorMessage;

  EligibilityModel? get eligibility => _eligibility;
  List<Map<String, dynamic>> get history => _history;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchEligibility() async {
    _isLoading = true;
    notifyListeners();

    try {
      _eligibility = await _service.getEligibility();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchHistory() async {
    _isLoading = true;
    notifyListeners();

    try {
      _history = await _service.getHistory();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
