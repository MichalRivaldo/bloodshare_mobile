// Core constants for BloodShare app
const String appName = 'BloodShare';

// API base URL — ubah sesuai environment:
// Emulator Android : http://10.0.2.2:3000
// Physical device  : http://192.168.x.x:3000 (IP lokal PC)
// iOS Simulator    : http://localhost:3000
const String apiBaseUrl = 'http://10.0.2.2:3000';

// Storage keys
const String kTokenKey = 'auth_token';
const String kUserKey  = 'auth_user';

// Eligibility
const int kDonorMinGapDays = 56;

// Golongan darah & rhesus
const List<String> kGolonganDarah = ['A', 'B', 'AB', 'O'];
const List<String> kRhesus        = ['+', '-'];

// Urgensi label
const Map<String, String> kUrgensiLabel = {
  'darurat'  : '🚨 Darurat',
  'segera'   : '⚠️ Segera',
  'terjadwal': '📅 Terjadwal',
};

// Urgensi badge color
const Map<String, int> kUrgensiColor = {
  'darurat'  : 0xFFD32F2F,
  'segera'   : 0xFFF57F17,
  'terjadwal': 0xFF1565C0,
};
