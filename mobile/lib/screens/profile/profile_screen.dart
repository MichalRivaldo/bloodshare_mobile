import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/blood_badge.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Pengguna'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Avatar & Info Utama
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 46,
                    backgroundColor: AppTheme.primary.withOpacity(0.12),
                    child: Text(
                      user?.namaLengkap.isNotEmpty == true
                          ? user!.namaLengkap[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.namaLengkap ?? 'Pengguna BloodShare',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '',
                    style: const TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  if (user?.golonganDarah != null)
                    BloodBadge(golongan: user!.golonganDarahLabel, size: 52),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Card Statistik Donasi
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _statItem('Total Donasi', '${user?.totalDonasi ?? 0} Kali'),
                    Container(height: 36, width: 1, color: Colors.grey[300]),
                    _statItem('Status Donor', (user?.isDonorAktif == 1) ? 'Aktif' : 'Nonaktif'),
                    Container(height: 36, width: 1, color: Colors.grey[300]),
                    _statItem('Kota', user?.kota ?? '-'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Switch Toggle Ketersediaan Donor
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: SwitchListTile(
                title: const Text(
                  'Bersedia Donor Darah',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                subtitle: const Text(
                  'Aktifkan agar nama Anda dapat direkomendasikan saat ada pasien darurat yang cocok.',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
                value: user?.isDonorAktif == 1,
                activeColor: AppTheme.primary,
                onChanged: (val) {
                  authProvider.toggleAvailability();
                },
              ),
            ),
            const SizedBox(height: 16),

            // Info Detail Kontak
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.phone_outlined, color: AppTheme.primary),
                    title: const Text('Nomor Telepon / WA', style: TextStyle(fontSize: 13, color: Colors.grey)),
                    subtitle: Text(user?.noTelepon ?? '-', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.location_on_outlined, color: AppTheme.primary),
                    title: const Text('Domisili / Kota', style: TextStyle(fontSize: 13, color: Colors.grey)),
                    subtitle: Text(user?.kota ?? '-', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                  if (user?.lastDonorAt != null) ...[
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.calendar_today_outlined, color: AppTheme.primary),
                      title: const Text('Terakhir Donor', style: TextStyle(fontSize: 13, color: Colors.grey)),
                      subtitle: Text(user!.lastDonorAt!, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Tombol Logout
            OutlinedButton.icon(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Keluar dari Akun?'),
                    content: const Text('Anda harus masuk kembali untuk mengakses fitur BloodShare.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
                        child: const Text('Keluar'),
                      ),
                    ],
                  ),
                );

                if (confirm == true && context.mounted) {
                  await context.read<AuthProvider>().logout();
                  if (context.mounted) context.go('/login');
                }
              },
              icon: const Icon(Icons.logout, color: AppTheme.error),
              label: const Text('Keluar dari Akun', style: TextStyle(color: AppTheme.error)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.error),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}
