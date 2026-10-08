import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/formatters.dart';
import '../../providers/auth_provider.dart';
import '../../providers/internship_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class CreateInternshipScreen extends ConsumerStatefulWidget {
  const CreateInternshipScreen({super.key});

  @override
  ConsumerState<CreateInternshipScreen> createState() => _CreateInternshipScreenState();
}

class _CreateInternshipScreenState extends ConsumerState<CreateInternshipScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _salaryMinController = TextEditingController();
  final _salaryMaxController = TextEditingController();
  final _quotaController = TextEditingController(text: '1');
  final _reqInputController = TextEditingController();

  String _selectedCategory = 'IT';
  String _selectedLocation = 'Yogyakarta';
  String _selectedWorkType = 'Hybrid';
  String _selectedDuration = '3 bulan';
  DateTime _deadline = DateTime.now().add(const Duration(days: 30));

  final List<String> _requirements = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _salaryMinController.dispose();
    _salaryMaxController.dispose();
    _quotaController.dispose();
    _reqInputController.dispose();
    super.dispose();
  }

  void _addRequirement() {
    final text = _reqInputController.text.trim();
    if (text.isNotEmpty && !_requirements.contains(text)) {
      setState(() {
        _requirements.add(text);
        _reqInputController.clear();
      });
    }
  }

  Future<void> _handleSave({required String status}) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final company = await ref.read(authServiceProvider).getCompanyProfile();
      if (company == null) throw Exception('Profil perusahaan belum dibuat');

      final service = ref.read(internshipServiceProvider);
      await service.createInternship({
        'company_id': company.id,
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'requirements': _requirements,
        'category': _selectedCategory,
        'location': _selectedLocation,
        'work_type': _selectedWorkType,
        'duration': _selectedDuration,
        'salary_min': num.tryParse(_salaryMinController.text.trim()) ?? 0,
        'salary_max': num.tryParse(_salaryMaxController.text.trim()) ?? 0,
        'quota': int.tryParse(_quotaController.text.trim()) ?? 1,
        'deadline': _deadline.toIso8601String(),
        'status': status,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              status == 'published'
                  ? 'Lowongan berhasil dipublikasikan!'
                  : 'Lowongan berhasil disimpan sebagai draft.',
            ),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Buat Lowongan Magang'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                controller: _titleController,
                label: 'Judul Posisi Magang',
                hint: 'contoh: Flutter Developer Intern',
                validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              // Kategori Dropdown
              const Text('Kategori', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                items: AppConstants.categories
                    .where((c) => c != 'All')
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
                decoration: const InputDecoration(),
              ),
              const SizedBox(height: 16),

              // Lokasi
              const Text('Lokasi', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _selectedLocation,
                items: AppConstants.locations
                    .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedLocation = val);
                },
                decoration: const InputDecoration(),
              ),
              const SizedBox(height: 16),

              // Work Type & Durasi
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Work Type', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedWorkType,
                          items: AppConstants.workTypes
                              .map((w) => DropdownMenuItem(value: w, child: Text(w)))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedWorkType = val);
                          },
                          decoration: const InputDecoration(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Durasi', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedDuration,
                          items: AppConstants.durations
                              .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedDuration = val);
                          },
                          decoration: const InputDecoration(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Gaji Min & Max
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _salaryMinController,
                      label: 'Gaji Min (Rp)',
                      hint: '1500000',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _salaryMaxController,
                      label: 'Gaji Max (Rp)',
                      hint: '2500000',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Kuota & Deadline
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _quotaController,
                      label: 'Kuota Mahasiswa',
                      hint: '2',
                      keyboardType: TextInputType.number,
                      validator: (v) => v == null || v.isEmpty ? 'Wajib' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Batas Akhir', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _deadline,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (picked != null) setState(() => _deadline = picked);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppConstants.borderColor),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 16, color: AppConstants.secondaryColor),
                                const SizedBox(width: 8),
                                Text(
                                  Formatters.formatDate(_deadline),
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Deskripsi
              CustomTextField(
                controller: _descriptionController,
                label: 'Deskripsi Pekerjaan',
                hint: 'Jelaskan tugas dan peran mahasiswa selama masa magang...',
                maxLines: 4,
                validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              // Requirements input
              const Text(
                'Persyaratan & Kualifikasi',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _reqInputController,
                      decoration: const InputDecoration(
                        hintText: 'Tambah poin kualifikasi...',
                      ),
                      onSubmitted: (_) => _addRequirement(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _addRequirement,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_requirements.isNotEmpty)
                Column(
                  children: _requirements.map((req) {
                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.check, size: 18, color: Colors.green),
                      title: Text(req, style: const TextStyle(fontSize: 13)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                        onPressed: () => setState(() => _requirements.remove(req)),
                      ),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 28),

              // Action buttons
              CustomButton(
                text: 'Publikasikan Lowongan',
                isLoading: _isLoading,
                onPressed: () => _handleSave(status: 'published'),
              ),
              const SizedBox(height: 12),

              CustomButton(
                text: 'Simpan Sebagai Draft',
                isOutlined: true,
                onPressed: () => _handleSave(status: 'draft'),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
