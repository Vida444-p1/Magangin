import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/internship_provider.dart';
import '../../widgets/internship_card.dart';
import '../../widgets/empty_state.dart';

class SavedInternshipsScreen extends ConsumerWidget {
  const SavedInternshipsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedAsync = ref.watch(savedInternshipsProvider);

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Lowongan Tersimpan'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(savedInternshipsProvider);
        },
        child: savedAsync.when(
          data: (list) {
            if (list.isEmpty) {
              return EmptyState(
                icon: Icons.bookmark_border_rounded,
                title: 'Belum Ada Favorit',
                message: 'Simpan lowongan magang yang menarik agar kamu dapat melihatnya kembali nanti.',
                buttonText: 'Cari Lowongan',
                onButtonPressed: () => context.push('/search'),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final item = list[index];
                return InternshipCard(
                  internship: item,
                  onTap: () => context.push('/internship/${item.id}'),
                  onBookmarkToggle: () async {
                    await ref
                        .read(internshipServiceProvider)
                        .toggleBookmark(item.id);
                    ref.invalidate(savedInternshipsProvider);
                    ref.invalidate(publishedInternshipsProvider);
                  },
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
