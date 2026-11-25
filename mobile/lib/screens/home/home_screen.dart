import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/blood_request_provider.dart';
import '../../providers/donation_provider.dart';
import '../../widgets/blood_badge.dart';
import '../../widgets/request_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DonationProvider>().fetchEligibility();
      context.read<BloodRequestProvider>().fetchRequests(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final donation = context.watch<DonationProvider>();
    final requestProv = context.watch<BloodRequestProvider>();

    final user = auth.user;
    final eligibility = donation.eligibility;

    return Scaffold(
      appBar: AppBar(
        title: const Text('BloodShare'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fitur notifikasi in-app siap di backend!')),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            context.read<DonationProvider>().fetchEligibility(),
            context.read<BloodRequestProvider>().fetchRequests(refresh: true),
          ]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header Sapaan ─────────────────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                decoration: const BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Halo, ${user?.namaLengkap ?? 'Sahabat'} 👋',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.kota != null
                                ? 'Wilayah: ${user!.kota}'
                                : 'Mari bantu sesama hari ini',
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    if (user?.golonganDarah != null)
                      BloodBadge(
                        golongan: user!.golonganDarahLabel,
                        size: 52,
                        isFilled: false,
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Kartu Status Kelayakan Donor ──────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: donation.isLoading
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(12.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: (eligibility?.isEligible ?? true)
                                      ? Colors.green.withOpacity(0.12)
                                      : Colors.orange.withOpacity(0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  (eligibility?.isEligible ?? true)
                                      ? Icons.check_circle_outline
                                      : Icons.schedule,
                                  color: (eligibility?.isEligible ?? true)
                                      ? Colors.green
                                      : Colors.orange,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      (eligibility?.isEligible ?? true)
                                          ? 'Anda Boleh Donor Darah! 🎉'
                                          : 'Masa Pemulihan Donor',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: (eligibility?.isEligible ?? true)
                                            ? Colors.green[800]
                                            : Colors.orange[800],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      (eligibility?.isEligible ?? true)
                                          ? 'Kondisi tubuh siap untuk membantu donor darah pasien darurat.'
                                          : 'Bisa donor lagi ${eligibility?.daysRemaining ?? 0} hari lagi (${eligibility?.nextEligibleAt ?? '-'}).',
                                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Tombol CTA Utama: Butuh Darah Darurat ──────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: InkWell(
                  onTap: () => context.push('/create-request'),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFD32F2F), Color(0xFFB71C1C)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Colors.white, size: 36),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'BUTUH DARAH DARURAT?',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Klik untuk buat permintaan ke komunitas pendonor',
                                style: TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── Section: Permintaan Terbaru ───────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Permintaan Darurat Terkini',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/requests-feed'),
                      child: const Text('Lihat Semua'),
                    ),
                  ],
                ),
              ),

              if (requestProv.isLoading && requestProv.requests.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (requestProv.requests.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(
                    child: Text(
                      'Belum ada permintaan darah aktif saat ini.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                ...requestProv.requests.take(4).map((req) {
                  return RequestCard(
                    request: req,
                    onTap: () => context.push('/requests/${req.id}'),
                  );
                }),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
