import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

enum AuthStatus { initial, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final StorageService _storage = StorageService.instance;

  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  Future<void> checkAutoLogin() async {
    _isLoading = true;
    notifyListeners();

    try {
      final savedToken = await _storage.getToken();
      if (savedToken != null && savedToken.isNotEmpty) {
        _token = savedToken;
        final savedUser = await _storage.getUser();
        if (savedUser != null) {
          _user = savedUser;
          _status = AuthStatus.authenticated;
          notifyListeners();
        }

        // Fetch fresh profile from API
        try {
          final freshUser = await _authService.getMe();
          _user = freshUser;
          await _storage.saveUser(freshUser);
          _status = AuthStatus.authenticated;
        } catch (_) {
          if (_user == null) {
            _status = AuthStatus.unauthenticated;
          }
        }
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (_) {
      _status = AuthStatus.unauthenticated;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _authService.login(email, password);
      _user = res['user'] as UserModel;
      _token = res['token'] as String;
      await _storage.saveToken(_token!);
      await _storage.saveUser(_user!);
      _status = AuthStatus.authenticated;
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

  Future<bool> register(Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _authService.register(data);
      _user = res['user'] as UserModel;
      _token = res['token'] as String;
      await _storage.saveToken(_token!);
      await _storage.saveUser(_user!);
      _status = AuthStatus.authenticated;
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

  Future<void> toggleAvailability() async {
    if (_user == null) return;
    try {
      final newState = await _authService.toggleAvailability();
      _user = UserModel(
        id: _user!.id,
        namaLengkap: _user!.namaLengkap,
        email: _user!.email,
        noTelepon: _user!.noTelepon,
        golonganDarah: _user!.golonganDarah,
        rhesus: _user!.rhesus,
        kota: _user!.kota,
        alamat: _user!.alamat,
        tanggalLahir: _user!.tanggalLahir,
        jenisKelamin: _user!.jenisKelamin,
        isDonorAktif: newState ? 1 : 0,
        lastDonorAt: _user!.lastDonorAt,
        totalDonasi: _user!.totalDonasi,
        role: _user!.role,
      );
      await _storage.saveUser(_user!);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _storage.clearAuth();
    _user = null;
    _token = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
