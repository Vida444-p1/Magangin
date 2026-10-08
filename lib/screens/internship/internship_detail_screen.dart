import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/formatters.dart';
import '../../models/internship_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/internship_provider.dart';
import '../../providers/application_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class InternshipDetailScreen extends ConsumerStatefulWidget {
  final String internshipId;

  const InternshipDetailScreen({super.key, required this.internshipId});

  @override
  ConsumerState<InternshipDetailScreen> createState() => _InternshipDetailScreenState();
}

class _InternshipDetailScreenState extends ConsumerState<InternshipDetailScreen> {
  InternshipModel? _internship;
  bool _isLoading = true;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    setState(() => _isLoading = true);
    final service = ref.read(internshipServiceProvider);
    final detail = await service.getInternshipById(widget.internshipId);
    if (mounted) {
      setState(() {
        _internship = detail;
        _isSaved = detail?.isSaved ?? false;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleBookmark() async {
    if (_internship == null) return;
    final newState = await ref
        .read(internshipServiceProvider)
        .toggleBookmark(_internship!.id);
    if (mounted) {
      setState(() => _isSaved = newState);
      ref.invalidate(savedInternshipsProvider);
      ref.invalidate(publishedInternshipsProvider);
    }
  }

  void _showApplyModal() {
    final studentAsync = ref.read(studentProfileProvider);
    final student = studentAsync.value;

    final coverLetterController = TextEditingController();
    bool isApplying = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(modalContext).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Kirim Lamaran Magang',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppConstants.textColor,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(modalContext),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 12),

              // CV info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppConstants.primaryLight.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppConstants.primaryLight),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.picture_as_pdf, color: AppConstants.primaryColor),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Curriculum Vitae (CV)',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppConstants.textColor,
                            ),
                          ),
                          Text(
                            student?.cvUrl != null && student!.cvUrl!.isNotEmpty
                                ? 'CV profil kamu siap dikirimkan'
                                : 'Belum mengunggah CV. Harap upload di Profil.',
                            style: TextStyle(
                              fontSize: 12,
                              color: student?.cvUrl != null
                                  ? const Color(0xFF166534)
                                  : Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Cover letter field
              CustomTextField(
                controller: coverLetterController,
                label: 'Cover Letter (Opsional)',
                hint: 'Ceritakan secara singkat alasan kamu tertarik melamar lowongan ini...',
                maxLines: 4,
              ),
              const SizedBox(height: 24),

              CustomButton(
                text: 'Kirim Lamaran Sekarang',
                isLoading: isApplying,
                onPressed: (student?.cvUrl == null || student!.cvUrl!.isEmpty)
                    ? null
                    : () async {
                        setModalState(() => isApplying = true);
                        try {
                          await ref.read(applicationServiceProvider).applyInternship(
                                internshipId: widget.internshipId,
                                cvUrl: student.cvUrl!,
                                coverLetter: coverLetterController.text.trim(),
                              );

                          if (modalContext.mounted) {
                            Navigator.pop(modalContext);
                            _showSuccessDialog();
                            ref.invalidate(studentApplicationsProvider);
                          }
                        } catch (e) {
                          setModalState(() => isApplying = false);
                          if (modalContext.mounted) {
                            ScaffoldMessenger.of(modalContext).showSnackBar(
                              SnackBar(
                                content: Text('Gagal mengirim lamaran: $e'),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                          }
                        }
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Colors.green,
                size: 54,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '🎉 Lamaran Berhasil Dikirim!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Lamaran kamu untuk posisi "${_internship?.title}" di ${_internship?.company?.companyName ?? "perusahaan"} telah berhasil dikirim.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppConstants.secondaryColor),
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: 'OK, Mengerti',
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_internship == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Lowongan tidak ditemukan')),
      );
    }

    final item = _internship!;
    final company = item.company;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Detail Lowongan'),
        actions: [
          IconButton(
            icon: Icon(
              _isSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
              color: _isSaved ? AppConstants.primaryColor : AppConstants.textColor,
            ),
            onPressed: _toggleBookmark,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Company Header
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppConstants.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: company?.logoUrl != null && company!.logoUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: company.logoUrl!,
                          fit: BoxFit.cover,
                          errorWidget: (_, _, _) => const Icon(
                            Icons.business,
                            color: AppConstants.primaryColor,
                            size: 28,
                          ),
                        )
                      : const Icon(
                          Icons.business,
                          color: AppConstants.primaryColor,
                          size: 28,
                        ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        company?.companyName ?? 'Perusahaan',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppConstants.secondaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppConstants.textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Key Highlights Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppConstants.backgroundColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppConstants.borderColor),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, color: AppConstants.primaryColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        item.location,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      const Icon(Icons.work_outline, color: AppConstants.primaryColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        item.workType,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    children: [
                      const Icon(Icons.payments_outlined, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        Formatters.formatSalaryRange(item.salaryMin, item.salaryMax),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF166534),
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.access_time, color: Colors.orange, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        item.duration,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Deskripsi Lowongan
            const Text(
              'Deskripsi Lowongan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppConstants.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.description,
              style: const TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 24),

            // Persyaratan
            if (item.requirements.isNotEmpty) ...[
              const Text(
                'Persyaratan & Kualifikasi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppConstants.textColor,
                ),
              ),
              const SizedBox(height: 10),
              ...item.requirements.map(
                (req) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle_outline, size: 18, color: AppConstants.primaryColor),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          req,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Informasi Tambahan (Kuota, Deadline)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text(
                        'Kuota',
                        style: TextStyle(fontSize: 12, color: AppConstants.secondaryColor),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${item.quota} Mahasiswa',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  Container(height: 30, width: 1, color: AppConstants.borderColor),
                  Column(
                    children: [
                      const Text(
                        'Batas Pendaftaran',
                        style: TextStyle(fontSize: 12, color: AppConstants.secondaryColor),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        Formatters.formatDate(item.deadline),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
          child: CustomButton(
            text: 'Lamar Sekarang',
            onPressed: item.isExpired ? null : _showApplyModal,
          ),
        ),
      ),
    );
  }
}
