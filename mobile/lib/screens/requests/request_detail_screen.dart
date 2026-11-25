import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../models/blood_request_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/blood_request_provider.dart';
import '../../widgets/blood_badge.dart';
import '../../widgets/urgency_badge.dart';

class RequestDetailScreen extends StatefulWidget {
  final int requestId;

  const RequestDetailScreen({super.key, required this.requestId});

  @override
  State<RequestDetailScreen> createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends State<RequestDetailScreen> {
  BloodRequestModel? _request;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final req = await context.read<BloodRequestProvider>().getDetail(widget.requestId);
    if (!mounted) return;

    setState(() {
      _request = req;
      _isLoading = false;
      if (req == null) _error = 'Gagal memuat detail permintaan';
    });
  }

  void _showRespondDialog() {
    final pesanController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Bantu Permintaan Darah'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tuliskan pesan atau konfirmasi ketersediaan Anda untuk pemohon:',
              style: TextStyle(fontSize: 13, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: pesanController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'contoh: Saya bersedia donor, bisa datang besok jam 10 pagi.',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await context.read<BloodRequestProvider>().respondToRequest(
                    widget.requestId,
                    pesan: pesanController.text.trim(),
                  );
              if (!mounted) return;
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Respon Anda berhasil dikirim! Pemohon akan menghubungi Anda.'),
                    backgroundColor: Colors.green,
                  ),
                );
                _loadDetail();
              } else {
                final err = context.read<BloodRequestProvider>().errorMessage;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(err ?? 'Gagal mengirim respon'),
                    backgroundColor: AppTheme.error,
                  ),
                );
              }
            },
            child: const Text('Kirim Bantuan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.watch<AuthProvider>().user?.id;
    final isOwner = _request != null && _request!.requesterId == currentUserId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Permintaan'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!),
                      const SizedBox(height: 12),
                      ElevatedButton(onPressed: _loadDetail, child: const Text('Coba Lagi')),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Card Utama: Golongan + Pasien + Urgensi
                      Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  BloodBadge(golongan: _request!.golonganLabel, size: 64),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _request!.namaPasien,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        UrgencyBadge(urgensi: _request!.urgensi),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 32),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _infoColumn('Jumlah Kantong', '${_request!.jumlahKantong} Kantong'),
                                  _infoColumn('Dibutuhkan Pada', _request!.tanggalDibutuhkan),
                                  _infoColumn('Status', _request!.status.toUpperCase()),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Card Info Lokasi RS
                      Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.local_hospital, color: AppTheme.primary, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Lokasi Rumah Sakit / Klinik',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _request!.namaRs,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                              ),
                              if (_request!.alamatRs != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  _request!.alamatRs!,
                                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                                ),
                              ],
                              const SizedBox(height: 4),
                              Text(
                                'Kota: ${_request!.kota}',
                                style: const TextStyle(color: Colors.black54, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Card Info Kontak Pemohon
                      Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.contact_phone, color: AppTheme.primary, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Informasi Pemohon',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text('Nama: ${_request!.requesterNama ?? '-'}'),
                              const SizedBox(height: 4),
                              Text('No. HP / WA: ${_request!.requesterTelepon ?? '-'}'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Keterangan / Catatan Tambahan
                      if (_request!.keterangan != null && _request!.keterangan!.isNotEmpty) ...[
                        Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Catatan Tambahan',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _request!.keterangan!,
                                  style: const TextStyle(color: Colors.black87, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Tombol "Saya Bisa Bantu"
                      if (!isOwner && _request!.isAktif)
                        ElevatedButton.icon(
                          onPressed: _showRespondDialog,
                          icon: const Icon(Icons.volunteer_activism),
                          label: const Text(
                            'SAYA BISA BANTU',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: AppTheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        )
                      else if (isOwner)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text(
                              'Ini adalah permintaan darah yang Anda buat.',
                              style: TextStyle(color: Colors.black54),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }

  Widget _infoColumn(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
