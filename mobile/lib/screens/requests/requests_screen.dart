import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../providers/blood_request_provider.dart';
import '../../widgets/request_card.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  final ScrollController _scrollController = ScrollController();

  String? _selectedUrgensi;
  String? _selectedGolongan;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BloodRequestProvider>().fetchRequests(refresh: true);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<BloodRequestProvider>().loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _applyFilter() {
    context.read<BloodRequestProvider>().setFilter(
      urgensi: _selectedUrgensi,
      golongan: _selectedGolongan,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BloodRequestProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Permintaan Donor Darah'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Buat Permintaan'),
        onPressed: () => context.push('/create-request'),
      ),
      body: Column(
        children: [
          // ── Horizontal Filter Bar ─────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Filter Urgensi: Semua
                  FilterChip(
                    label: const Text('Semua'),
                    selected: _selectedUrgensi == null && _selectedGolongan == null,
                    onSelected: (selected) {
                      setState(() {
                        _selectedUrgensi = null;
                        _selectedGolongan = null;
                      });
                      _applyFilter();
                    },
                  ),
                  const SizedBox(width: 8),

                  // Filter Urgensi Darurat
                  FilterChip(
                    avatar: const Icon(Icons.warning, size: 16, color: Colors.red),
                    label: const Text('Darurat'),
                    selected: _selectedUrgensi == 'darurat',
                    onSelected: (selected) {
                      setState(() {
                        _selectedUrgensi = selected ? 'darurat' : null;
                      });
                      _applyFilter();
                    },
                  ),
                  const SizedBox(width: 8),

                  // Golongan Darah Chips
                  ...kGolonganDarah.map((gol) {
                    final isSel = _selectedGolongan == gol;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: Text('Gol $gol'),
                        selected: isSel,
                        onSelected: (selected) {
                          setState(() {
                            _selectedGolongan = selected ? gol : null;
                          });
                          _applyFilter();
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          const Divider(height: 1),

          // ── Request List Feed ─────────────────────────────
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await context.read<BloodRequestProvider>().fetchRequests(refresh: true);
              },
              child: provider.isLoading && provider.requests.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : provider.requests.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Text(
                              'Tidak ada permintaan darah yang cocok dengan filter.',
                              style: TextStyle(color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: provider.requests.length + (provider.hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == provider.requests.length) {
                              return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(child: CircularProgressIndicator()),
                              );
                            }
                            final req = provider.requests[index];
                            return RequestCard(
                              request: req,
                              onTap: () => context.push('/requests/${req.id}'),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
