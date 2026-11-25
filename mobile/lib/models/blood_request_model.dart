class BloodRequestModel {
  final int id;
  final int requesterId;
  final String golonganDarah;
  final String rhesus;
  final int jumlahKantong;
  final String urgensi;
  final String namaPasien;
  final String namaRs;
  final String kota;
  final String? alamatRs;
  final String tanggalDibutuhkan;
  final String? keterangan;
  final String status;
  final String? requesterNama;
  final String? requesterTelepon;
  final int jumlahRespon;
  final String createdAt;

  const BloodRequestModel({
    required this.id,
    required this.requesterId,
    required this.golonganDarah,
    required this.rhesus,
    required this.jumlahKantong,
    required this.urgensi,
    required this.namaPasien,
    required this.namaRs,
    required this.kota,
    this.alamatRs,
    required this.tanggalDibutuhkan,
    this.keterangan,
    required this.status,
    this.requesterNama,
    this.requesterTelepon,
    required this.jumlahRespon,
    required this.createdAt,
  });

  factory BloodRequestModel.fromJson(Map<String, dynamic> json) => BloodRequestModel(
    id:                 json['id'] as int,
    requesterId:        json['requester_id'] as int,
    golonganDarah:      json['golongan_darah'] as String,
    rhesus:             json['rhesus'] as String,
    jumlahKantong:      json['jumlah_kantong'] as int? ?? 1,
    urgensi:            json['urgensi'] as String,
    namaPasien:         json['nama_pasien'] as String,
    namaRs:             json['nama_rs'] as String,
    kota:               json['kota'] as String,
    alamatRs:           json['alamat_rs'] as String?,
    tanggalDibutuhkan:  json['tanggal_dibutuhkan'] as String,
    keterangan:         json['keterangan'] as String?,
    status:             json['status'] as String,
    requesterNama:      json['requester_nama'] as String?,
    requesterTelepon:   json['requester_telepon'] as String?,
    jumlahRespon:       json['jumlah_respon'] as int? ?? 0,
    createdAt:          json['created_at'] as String,
  );

  String get golonganLabel => '$golonganDarah$rhesus';

  bool get isAktif => status == 'aktif';
}
