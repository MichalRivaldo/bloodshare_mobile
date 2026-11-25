class UserModel {
  final int id;
  final String namaLengkap;
  final String email;
  final String noTelepon;
  final String? golonganDarah;
  final String? rhesus;
  final String? kota;
  final String? alamat;
  final String? tanggalLahir;
  final String? jenisKelamin;
  final int isDonorAktif;
  final String? lastDonorAt;
  final int totalDonasi;
  final String role;

  const UserModel({
    required this.id,
    required this.namaLengkap,
    required this.email,
    required this.noTelepon,
    this.golonganDarah,
    this.rhesus,
    this.kota,
    this.alamat,
    this.tanggalLahir,
    this.jenisKelamin,
    required this.isDonorAktif,
    this.lastDonorAt,
    required this.totalDonasi,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id:            json['id'] as int,
    namaLengkap:   json['nama_lengkap'] as String,
    email:         json['email'] as String,
    noTelepon:     json['no_telepon'] as String,
    golonganDarah: json['golongan_darah'] as String?,
    rhesus:        json['rhesus'] as String?,
    kota:          json['kota'] as String?,
    alamat:        json['alamat'] as String?,
    tanggalLahir:  json['tanggal_lahir'] as String?,
    jenisKelamin:  json['jenis_kelamin'] as String?,
    isDonorAktif:  json['is_donor_aktif'] as int? ?? 0,
    lastDonorAt:   json['last_donor_at'] as String?,
    totalDonasi:   json['total_donasi'] as int? ?? 0,
    role:          json['role'] as String? ?? 'user',
  );

  Map<String, dynamic> toJson() => {
    'id':             id,
    'nama_lengkap':   namaLengkap,
    'email':          email,
    'no_telepon':     noTelepon,
    'golongan_darah': golonganDarah,
    'rhesus':         rhesus,
    'kota':           kota,
    'alamat':         alamat,
    'tanggal_lahir':  tanggalLahir,
    'jenis_kelamin':  jenisKelamin,
    'is_donor_aktif': isDonorAktif,
    'last_donor_at':  lastDonorAt,
    'total_donasi':   totalDonasi,
    'role':           role,
  };

  String get golonganDarahLabel =>
      golonganDarah != null && rhesus != null ? '$golonganDarah$rhesus' : '-';
}
