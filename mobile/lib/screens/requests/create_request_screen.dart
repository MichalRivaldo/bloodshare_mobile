import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/blood_request_provider.dart';

class CreateRequestScreen extends StatefulWidget {
  const CreateRequestScreen({super.key});

  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  final _formKey = GlobalKey<FormState>();

  final _namaPasienController = TextEditingController();
  final _namaRsController = TextEditingController();
  final _alamatRsController = TextEditingController();
  final _kotaController = TextEditingController();
  final _jumlahKantongController = TextEditingController(text: '1');
  final _keteranganController = TextEditingController();

  String _golonganDarah = 'A';
  String _rhesus = '+';
  String _urgensi = 'darurat';
  DateTime _tanggalDibutuhkan = DateTime.now();

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    if (user?.kota != null) {
      _kotaController.text = user!.kota!;
    }
  }

  @override
  void dispose() {
    _namaPasienController.dispose();
    _namaRsController.dispose();
    _alamatRsController.dispose();
    _kotaController.dispose();
    _jumlahKantongController.dispose();
    _keteranganController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggalDibutuhkan,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) {
      setState(() => _tanggalDibutuhkan = picked);
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final dateStr = DateFormat('yyyy-MM-dd').format(_tanggalDibutuhkan);
    final data = {
      'nama_pasien': _namaPasienController.text.trim(),
      'golongan_darah': _golonganDarah,
      'rhesus': _rhesus,
      'jumlah_kantong': int.tryParse(_jumlahKantongController.text) ?? 1,
      'urgensi': _urgensi,
      'nama_rs': _namaRsController.text.trim(),
      'alamat_rs': _alamatRsController.text.trim().isEmpty ? null : _alamatRsController.text.trim(),
      'kota': _kotaController.text.trim(),
      'tanggal_dibutuhkan': dateStr,
      'keterangan': _keteranganController.text.trim().isEmpty ? null : _keteranganController.text.trim(),
    };

    final provider = context.read<BloodRequestProvider>();
    final success = await provider.createRequest(data);

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permintaan darah berhasil dipublikasikan!'),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Gagal membuat permintaan'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BloodRequestProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Permintaan Darah'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Form Permintaan Darah Komunitas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryDark,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Lengkapi data pasien dan lokasi rumah sakit dengan jelas.',
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 20),

              // Nama Pasien
              TextFormField(
                controller: _namaPasienController,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap Pasien *',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Nama pasien wajib diisi' : null,
              ),
              const SizedBox(height: 14),

              // Golongan Darah & Rhesus
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<String>(
                      value: _golonganDarah,
                      decoration: const InputDecoration(labelText: 'Golongan Darah *'),
                      items: kGolonganDarah
                          .map((g) => DropdownMenuItem(value: g, child: Text('Golongan $g')))
                          .toList(),
                      onChanged: (v) => setState(() => _golonganDarah = v!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: _rhesus,
                      decoration: const InputDecoration(labelText: 'Rhesus *'),
                      items: kRhesus
                          .map((r) => DropdownMenuItem(value: r, child: Text('Rh $r')))
                          .toList(),
                      onChanged: (v) => setState(() => _rhesus = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Jumlah Kantong & Urgensi
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _jumlahKantongController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Kantong *',
                        suffixText: 'Ktg',
                      ),
                      validator: (v) {
                        final n = int.tryParse(v ?? '');
                        if (n == null || n < 1) return 'Min 1';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<String>(
                      value: _urgensi,
                      decoration: const InputDecoration(labelText: 'Tingkat Urgensi *'),
                      items: const [
                        DropdownMenuItem(value: 'darurat', child: Text('🚨 Darurat')),
                        DropdownMenuItem(value: 'segera', child: Text('⚠️ Segera')),
                        DropdownMenuItem(value: 'terjadwal', child: Text('📅 Terjadwal')),
                      ],
                      onChanged: (v) => setState(() => _urgensi = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Nama Rumah Sakit
              TextFormField(
                controller: _namaRsController,
                decoration: const InputDecoration(
                  labelText: 'Nama Rumah Sakit / Klinik *',
                  hintText: 'contoh: RSUD Dr. Soetomo',
                  prefixIcon: Icon(Icons.local_hospital),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Nama RS wajib diisi' : null,
              ),
              const SizedBox(height: 14),

              // Kota & Tanggal Dibutuhkan
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _kotaController,
                      decoration: const InputDecoration(
                        labelText: 'Kota *',
                        prefixIcon: Icon(Icons.location_city),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Kota wajib diisi' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: InkWell(
                      onTap: _selectDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Dibutuhkan *',
                          prefixIcon: Icon(Icons.calendar_today, size: 20),
                        ),
                        child: Text(
                          DateFormat('dd/MM/yyyy').format(_tanggalDibutuhkan),
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Alamat RS Lengkap
              TextFormField(
                controller: _alamatRsController,
                decoration: const InputDecoration(
                  labelText: 'Alamat RS (Opsional)',
                  hintText: 'Jl. Mayjen Prof. Dr. Moestopo No. 6-8',
                  prefixIcon: Icon(Icons.place),
                ),
              ),
              const SizedBox(height: 14),

              // Keterangan
              TextFormField(
                controller: _keteranganController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Keterangan Tambahan (Opsional)',
                  hintText: 'Kondisi pasien, ruang rawat inap, atau kontak darurat pendamping',
                ),
              ),
              const SizedBox(height: 28),

              // Tombol Submit
              ElevatedButton(
                onPressed: provider.isLoading ? null : _handleSubmit,
                child: provider.isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Publikasikan Permintaan',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
