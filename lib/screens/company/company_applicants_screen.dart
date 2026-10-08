import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/formatters.dart';
import '../../models/application_model.dart';
import '../../services/application_service.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/empty_state.dart';

class CompanyApplicantsScreen extends ConsumerStatefulWidget {
  final String? internshipId;

  const CompanyApplicantsScreen({super.key, this.internshipId});

  @override
  ConsumerState<CompanyApplicantsScreen> createState() => _CompanyApplicantsScreenState();
}

class _CompanyApplicantsScreenState extends ConsumerState<CompanyApplicantsScreen> {
  final _applicationService = ApplicationService();
  List<ApplicationModel> _applicants = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchApplicants();
  }

  Future<void> _fetchApplicants() async {
    setState(() => _isLoading = true);
    try {
      final list = await _applicationService.getCompanyApplicants(
        internshipId: widget.internshipId,
      );
      if (mounted) setState(() => _applicants = list);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showUpdateStatusSheet(ApplicationModel app) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Perbarui Status Pelamar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            _statusOption(ctx, app, 'reviewing', 'Tandai Sedang Direview (Reviewing)', Icons.visibility),
            _statusOption(ctx, app, 'interview', 'Undang Wawancara (Interview)', Icons.event_available),
            _statusOption(ctx, app, 'accepted', 'Terima Magang (Accepted)', Icons.check_circle, Colors.green),
            _statusOption(ctx, app, 'rejected', 'Tolak Lamaran (Rejected)', Icons.cancel, Colors.redAccent),
          ],
        ),
      ),
    );
  }

  Widget _statusOption(
    BuildContext ctx,
    ApplicationModel app,
    String status,
    String title,
    IconData icon, [
    Color? color,
  ]) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppConstants.primaryColor),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: color ?? AppConstants.textColor,
        ),
      ),
      onTap: () async {
        Navigator.pop(ctx);
        await _applicationService.updateApplicationStatus(
          applicationId: app.id,
          status: status,
        );
        _fetchApplicants();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Daftar Pelamar Mahasiswa'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchApplicants,
              child: _applicants.isEmpty
                  ? const EmptyState(
                      icon: Icons.people_outline,
                      title: 'Belum Ada Pelamar',
                      message: 'Belum ada mahasiswa yang melamar lowongan ini.',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _applicants.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final app = _applicants[index];
                        final student = app.studentProfile;
                        final profile = app.profile;

                        final studentName = profile?.fullName ?? 'Mahasiswa';
                        final univ = student?.university ?? 'Universitas';
                        final major = student?.major ?? 'Jurusan';
                        final semester = student?.semester != null ? 'Semester ${student!.semester}' : '';

                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            studentName,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '$univ • $major $semester',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppConstants.secondaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    StatusBadge(status: app.status),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                if (app.coverLetter != null && app.coverLetter!.isNotEmpty) ...[
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '"${app.coverLetter!}"',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                        color: Color(0xFF475569),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                ],

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Melamar: ${Formatters.formatDate(app.appliedAt)}',
                                      style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                                    ),
                                    Row(
                                      children: [
                                        ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            minimumSize: const Size(90, 36),
                                            padding: const EdgeInsets.symmetric(horizontal: 12),
                                            backgroundColor: AppConstants.primaryLight,
                                            foregroundColor: AppConstants.primaryColor,
                                            elevation: 0,
                                          ),
                                          icon: const Icon(Icons.edit, size: 14),
                                          label: const Text('Status', style: TextStyle(fontSize: 12)),
                                          onPressed: () => _showUpdateStatusSheet(app),
                                        ),
                                      ],
                                    ),
                                  ],
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
