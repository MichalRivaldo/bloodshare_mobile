import 'package:flutter/material.dart';
import '../../core/api_client.dart';
import '../../core/theme.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  List<dynamic> _events = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final res = await ApiClient.instance.getEvents();
      final body = res.data as Map<String, dynamic>;
      if (res.statusCode == 200 && body['success'] == true) {
        setState(() {
          _events = body['data']['events'] as List<dynamic>;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = body['message'] ?? 'Gagal memuat event';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _joinEvent(int id) async {
    try {
      final res = await ApiClient.instance.joinEvent(id);
      final body = res.data as Map<String, dynamic>;
      if (!mounted) return;
      if (res.statusCode == 201 || res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Berhasil mendaftar ke acara donor darah!'), backgroundColor: Colors.green),
        );
        _fetchEvents();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(body['message'] ?? 'Gagal mendaftar'), backgroundColor: AppTheme.error),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppTheme.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acara Donor Darah'),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchEvents,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_error!),
                        const SizedBox(height: 12),
                        ElevatedButton(onPressed: _fetchEvents, child: const Text('Coba Lagi')),
                      ],
                    ),
                  )
                : _events.isEmpty
                    ? const Center(
                        child: Text('Belum ada acara donor darah dalam waktu dekat.'),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _events.length,
                        itemBuilder: (context, index) {
                          final ev = _events[index] as Map<String, dynamic>;
                          final judul = ev['judul'] as String? ?? 'Acara Donor Darah';
                          final lokasi = ev['nama_lokasi'] as String? ?? '-';
                          final kota = ev['kota'] as String? ?? '-';
                          final kuota = ev['kuota'] ?? 0;
                          final peserta = ev['jumlah_peserta'] ?? 0;
                          final tglMulai = ev['tanggal_mulai'] as String? ?? '';
                          final id = ev['id'] as int;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primary.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(Icons.event, color: AppTheme.primary, size: 28),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              judul,
                                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '$lokasi, $kota',
                                              style: const TextStyle(fontSize: 13, color: Colors.black54),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 24),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Jadwal: ${tglMulai.substring(0, tglMulai.length >= 10 ? 10 : tglMulai.length)}',
                                        style: const TextStyle(fontSize: 12, color: Colors.black87),
                                      ),
                                      Text(
                                        'Peserta: $peserta / $kuota',
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  ElevatedButton(
                                    onPressed: () => _joinEvent(id),
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: const Size(double.infinity, 40),
                                    ),
                                    child: const Text('Daftar Ikuti Acara'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}
