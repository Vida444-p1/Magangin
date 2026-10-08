import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../services/storage_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class StudentProfileScreen extends ConsumerStatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  ConsumerState<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends ConsumerState<StudentProfileScreen> {
  final _storageService = StorageService();

  final _univController = TextEditingController();
  final _majorController = TextEditingController();
  final _semesterController = TextEditingController();
  final _locationController = TextEditingController();
  final _bioController = TextEditingController();
  final _skillInputController = TextEditingController();

  List<String> _skills = [];
  String? _cvUrl;
  bool _isSaving = false;
  bool _isUploadingCv = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final student = ref.read(studentProfileProvider).value;
    if (student != null) {
      _univController.text = student.university ?? '';
      _majorController.text = student.major ?? '';
      _semesterController.text = student.semester?.toString() ?? '1';
      _locationController.text = student.location ?? '';
      _bioController.text = student.bio ?? '';
      _skills = List.from(student.skills);
      _cvUrl = student.cvUrl;
      setState(() {});
    }
  }

  @override
  void dispose() {
    _univController.dispose();
    _majorController.dispose();
    _semesterController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    _skillInputController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveProfile() async {
    setState(() => _isSaving = true);
    try {
      final authService = ref.read(authServiceProvider);
      await authService.updateStudentProfile(
        university: _univController.text.trim(),
        major: _majorController.text.trim(),
        semester: int.tryParse(_semesterController.text.trim()) ?? 1,
        location: _locationController.text.trim(),
        bio: _bioController.text.trim(),
        skills: _skills,
      );

      ref.invalidate(studentProfileProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil berhasil diperbarui!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan profil: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _uploadCv() async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (files.isNotEmpty) {
      final file = files.first;
      final bytes = await file.xFile.readAsBytes();

      setState(() => _isUploadingCv = true);
      try {
        final url = await _storageService.uploadCv(
          bytes: bytes,
          fileName: file.name,
        );

        setState(() => _cvUrl = url);
        ref.invalidate(studentProfileProvider);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('CV berhasil diunggah!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal mengunggah CV: $e'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isUploadingCv = false);
      }
    }
  }

  void _addSkill() {
    final text = _skillInputController.text.trim();
    if (text.isNotEmpty && !_skills.contains(text)) {
      setState(() {
        _skills.add(text);
        _skillInputController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentProfileProvider);
    final profile = profileAsync.value;

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Profil Saya'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            onPressed: () async {
              await ref.read(authServiceProvider).signOut();
              if (context.mounted) context.go('/login');
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User Header Info Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppConstants.borderColor),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppConstants.primaryLight,
                    child: Text(
                      (profile?.fullName.isNotEmpty == true)
                          ? profile!.fullName[0].toUpperCase()
                          : 'M',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: AppConstants.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile?.fullName ?? 'Mahasiswa',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppConstants.textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          profile?.email ?? '',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppConstants.secondaryColor,
                          ),
                        ),
                        if (profile?.phone != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            profile!.phone!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppConstants.secondaryColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // CV Upload Card (PRD Section 16)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppConstants.borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Curriculum Vitae (CV)',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppConstants.textColor,
                        ),
                      ),
                      Icon(
                        _cvUrl != null ? Icons.check_circle : Icons.warning_amber_rounded,
                        color: _cvUrl != null ? Colors.green : Colors.orange,
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _cvUrl != null
                        ? 'CV Anda sudah tersimpan dan dapat digunakan untuk melamar lowongan magang.'
                        : 'Upload CV dalam format PDF agar perusahaan dapat mereview profilmu.',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppConstants.secondaryColor,
                    ),
                  ),
                  const SizedBox(height: 14),
                  CustomButton(
                    text: _cvUrl != null ? 'Ganti CV (PDF)' : 'Upload CV (PDF)',
                    isOutlined: true,
                    icon: Icons.upload_file_rounded,
                    isLoading: _isUploadingCv,
                    onPressed: _uploadCv,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Akademik Details
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppConstants.borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informasi Akademik & Profil',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppConstants.textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _univController,
                    label: 'Universitas',
                    hint: 'Universitas Gadjah Mada',
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: CustomTextField(
                          controller: _majorController,
                          label: 'Jurusan',
                          hint: 'Informatika',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: CustomTextField(
                          controller: _semesterController,
                          label: 'Semester',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: _locationController,
                    label: 'Domisili / Lokasi',
                    hint: 'Yogyakarta',
                    prefixIcon: Icons.location_on_outlined,
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: _bioController,
                    label: 'Bio Singkat',
                    hint: 'Tertarik di bidang Mobile Development dan UI Design...',
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Skills Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppConstants.borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Keahlian (Skills)',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppConstants.textColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _skillInputController,
                          decoration: const InputDecoration(
                            hintText: 'Tambah skill (e.g. Flutter, Git)',
                            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          ),
                          onSubmitted: (_) => _addSkill(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        onPressed: _addSkill,
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _skills.map((skill) {
                      return Chip(
                        label: Text(skill),
                        deleteIcon: const Icon(Icons.close, size: 14),
                        onDeleted: () {
                          setState(() => _skills.remove(skill));
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            CustomButton(
              text: 'Simpan Perubahan Profil',
              isLoading: _isSaving,
              onPressed: _handleSaveProfile,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
