import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class CompanyProfileScreen extends ConsumerStatefulWidget {
  const CompanyProfileScreen({super.key});

  @override
  ConsumerState<CompanyProfileScreen> createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends ConsumerState<CompanyProfileScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _industryController = TextEditingController();
  final _locationController = TextEditingController();
  final _websiteController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final company = ref.read(companyProfileProvider).value;
    if (company != null) {
      _nameController.text = company.companyName;
      _descController.text = company.description ?? '';
      _industryController.text = company.industry ?? '';
      _locationController.text = company.location ?? '';
      _websiteController.text = company.website ?? '';
      _phoneController.text = company.phone ?? '';
      setState(() {});
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _industryController.dispose();
    _locationController.dispose();
    _websiteController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);
    try {
      final authService = ref.read(authServiceProvider);
      await authService.updateCompanyProfile(
        companyName: _nameController.text.trim(),
        description: _descController.text.trim(),
        industry: _industryController.text.trim(),
        location: _locationController.text.trim(),
        website: _websiteController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      ref.invalidate(companyProfileProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil perusahaan berhasil diperbarui!'),
            backgroundColor: Colors.green,
          ),
        );
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
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Profil Perusahaan'),
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
                    'Informasi Perusahaan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _nameController,
                    label: 'Nama Perusahaan',
                    hint: 'PT Teknologi Indonesia',
                    prefixIcon: Icons.business,
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: _industryController,
                    label: 'Bidang Industri',
                    hint: 'Information Technology / Digital Agency',
                    prefixIcon: Icons.category_outlined,
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: _locationController,
                    label: 'Kota / Lokasi Kantor',
                    hint: 'Yogyakarta',
                    prefixIcon: Icons.location_on_outlined,
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: _websiteController,
                    label: 'Website Perusahaan',
                    hint: 'https://perusahaan.com',
                    prefixIcon: Icons.language,
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: _phoneController,
                    label: 'Nomor Telepon Kantor',
                    hint: '0274-123456',
                    prefixIcon: Icons.phone_outlined,
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: _descController,
                    label: 'Tentang Perusahaan',
                    hint: 'Deskripsi profil, visi, dan budaya perusahaan...',
                    maxLines: 4,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            CustomButton(
              text: 'Simpan Profil Perusahaan',
              isLoading: _isSaving,
              onPressed: _handleSave,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
