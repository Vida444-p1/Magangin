import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/formatters.dart';
import '../../providers/application_provider.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/empty_state.dart';

class MyApplicationsScreen extends ConsumerWidget {
  const MyApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicationsAsync = ref.watch(studentApplicationsProvider);

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Lamaran Saya'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(studentApplicationsProvider);
        },
        child: applicationsAsync.when(
          data: (list) {
            if (list.isEmpty) {
              return EmptyState(
                icon: Icons.assignment_outlined,
                title: 'Belum Ada Lamaran',
                message: 'Kamu belum mengajukan lamaran magang apapun. Mulai cari lowongan yang sesuai!',
                buttonText: 'Cari Lowongan',
                onButtonPressed: () => context.push('/search'),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final app = list[index];
                final internship = app.internship;
                final company = internship?.company;

                return Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    internship?.title ?? 'Lowongan Magang',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppConstants.textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    company?.companyName ?? 'Perusahaan',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppConstants.secondaryColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            StatusBadge(status: app.status),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const Divider(),
                        const SizedBox(height: 10),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Diajukan: ${Formatters.formatDate(app.appliedAt)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            if (app.status == 'submitted')
                              TextButton(
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Batalkan Lamaran?'),
                                      content: const Text(
                                        'Apakah kamu yakin ingin membatalkan lamaran untuk posisi ini?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx, false),
                                          child: const Text('Tidak'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () => Navigator.pop(ctx, true),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.redAccent,
                                          ),
                                          child: const Text('Ya, Batalkan'),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm == true) {
                                    await ref
                                        .read(applicationServiceProvider)
                                        .updateApplicationStatus(
                                          applicationId: app.id,
                                          status: 'withdrawn',
                                        );
                                    ref.invalidate(studentApplicationsProvider);
                                  }
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.redAccent,
                                  visualDensity: VisualDensity.compact,
                                ),
                                child: const Text('Batalkan'),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Terjadi kesalahan: $e')),
        ),
      ),
    );
  }
}
