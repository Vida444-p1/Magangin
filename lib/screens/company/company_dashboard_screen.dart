import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../models/internship_model.dart';
import '../../models/application_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/internship_service.dart';
import '../../services/application_service.dart';

class CompanyDashboardScreen extends ConsumerStatefulWidget {
  const CompanyDashboardScreen({super.key});

  @override
  ConsumerState<CompanyDashboardScreen> createState() => _CompanyDashboardScreenState();
}

class _CompanyDashboardScreenState extends ConsumerState<CompanyDashboardScreen> {
  final _internshipService = InternshipService();
  final _applicationService = ApplicationService();

  List<InternshipModel> _internships = [];
  List<ApplicationModel> _applications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final company = await ref.read(authServiceProvider).getCompanyProfile();
      if (company != null) {
        final list = await _internshipService.getCompanyInternships(company.id);
        final apps = await _applicationService.getCompanyApplicants();
        if (mounted) {
          setState(() {
            _internships = list;
            _applications = apps;
          });
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final companyAsync = ref.watch(companyProfileProvider);
    final companyName = companyAsync.value?.companyName ?? 'Perusahaan';

    final totalInternships = _internships.length;
    final totalApplicants = _applications.length;
    final newApplicants = _applications
        .where((a) => a.status == 'submitted' || a.status == 'reviewing')
        .length;

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Dashboard Perusahaan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppConstants.primaryColor),
            onPressed: () => context.push('/create-internship'),
            tooltip: 'Buat Lowongan',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchDashboardData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1E3A8A), AppConstants.primaryColor],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Selamat Datang,',
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            companyName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Kelola lowongan magang dan review berkas pelamar mahasiswa dengan mudah.',
                            style: TextStyle(color: Colors.white, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Metrics Row (PRD Section 24)
                    const Text(
                      'Statistik Magang',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppConstants.textColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _MetricCard(
                            title: 'Total Lowongan',
                            count: totalInternships.toString(),
                            icon: Icons.work_outline,
                            color: AppConstants.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _MetricCard(
                            title: 'Total Pelamar',
                            count: totalApplicants.toString(),
                            icon: Icons.people_outline,
                            color: Colors.teal,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _MetricCard(
                            title: 'Lamaran Baru',
                            count: newApplicants.toString(),
                            icon: Icons.mark_email_unread_outlined,
                            color: Colors.amber.shade800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Lowongan Aktif List
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Daftar Lowongan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppConstants.textColor,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.push('/create-internship'),
                          child: const Text('+ Buat Baru'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    if (_internships.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppConstants.borderColor),
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              const Icon(Icons.note_add_outlined, size: 40, color: Color(0xFF94A3B8)),
                              const SizedBox(height: 8),
                              const Text(
                                'Belum Ada Lowongan Dibuat',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Buat lowongan magang pertama Anda untuk mulai menerima pelamar.',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12, color: AppConstants.secondaryColor),
                              ),
                              const SizedBox(height: 14),
                              ElevatedButton(
                                onPressed: () => context.push('/create-internship'),
                                child: const Text('Buat Lowongan Sekarang'),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ..._internships.map((internship) {
                        final count = _applications
                            .where((a) => a.internshipId == internship.id)
                            .length;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            title: Text(
                              internship.title,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                            ),
                            subtitle: Text(
                              '${internship.location} • ${internship.workType} • Status: ${internship.status}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppConstants.primaryLight,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$count Pelamar',
                                style: const TextStyle(
                                  color: AppConstants.primaryColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            onTap: () {
                              context.push('/company-applicants?internshipId=${internship.id}');
                            },
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppConstants.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(height: 10),
          Text(
            count,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: AppConstants.secondaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
