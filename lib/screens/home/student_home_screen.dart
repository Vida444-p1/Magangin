import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/internship_provider.dart';
import '../../widgets/internship_card.dart';
import '../../widgets/empty_state.dart';

class StudentHomeScreen extends ConsumerWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);
    final internshipsAsync = ref.watch(publishedInternshipsProvider);
    final recommendedAsync = ref.watch(recommendedInternshipsProvider);
    final filter = ref.watch(internshipFilterProvider);

    final userName = profileAsync.value?.fullName ?? 'Mahasiswa';

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(publishedInternshipsProvider);
            ref.invalidate(recommendedInternshipsProvider);
          },
          child: CustomScrollView(
            slivers: [
              // Top Header: Greeting & Applications shortcut
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Halo, $userName 👋',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppConstants.textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Temukan magang terbaikmu',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppConstants.secondaryColor,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => context.push('/my-applications'),
                        icon: const Badge(
                          child: Icon(Icons.description_outlined, size: 26),
                        ),
                        tooltip: 'Lamaran Saya',
                      ),
                    ],
                  ),
                ),
              ),

              // Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: InkWell(
                    onTap: () => context.push('/search'),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppConstants.borderColor),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.search, color: Color(0xFF94A3B8)),
                          SizedBox(width: 12),
                          Text(
                            'Cari posisi, skill, atau perusahaan...',
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Categories Chips
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 16, 20, 10),
                      child: Text(
                        'Kategori',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppConstants.textColor,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 42,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        scrollDirection: Axis.horizontal,
                        itemCount: AppConstants.categories.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final category = AppConstants.categories[index];
                          final isSelected = filter.category == category;
                          return ChoiceChip(
                            label: Text(category),
                            selected: isSelected,
                            onSelected: (val) {
                              ref
                                  .read(internshipFilterProvider.notifier)
                                  .setCategory(category);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Rekomendasi Untukmu
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Rekomendasi Untukmu 🔥',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppConstants.textColor,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.push('/search'),
                        child: const Text('Lihat Semua'),
                      ),
                    ],
                  ),
                ),
              ),

              // Recommended List
              recommendedAsync.when(
                data: (list) {
                  if (list.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text('Belum ada rekomendasi saat ini.'),
                      ),
                    );
                  }
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final item = list[index];
                          return InternshipCard(
                            internship: item,
                            onTap: () => context.push('/internship/${item.id}'),
                            onBookmarkToggle: () async {
                              await ref
                                  .read(internshipServiceProvider)
                                  .toggleBookmark(item.id);
                              ref.invalidate(recommendedInternshipsProvider);
                              ref.invalidate(publishedInternshipsProvider);
                            },
                          );
                        },
                        childCount: list.length > 3 ? 3 : list.length,
                      ),
                    ),
                  );
                },
                loading: () => const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
                error: (e, _) => SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text('Gagal memuat rekomendasi: $e'),
                  ),
                ),
              ),

              // Lowongan Terbaru
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Text(
                    'Lowongan Terbaru 💼',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppConstants.textColor,
                    ),
                  ),
                ),
              ),

              // Latest List
              internshipsAsync.when(
                data: (list) {
                  if (list.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: EmptyState(
                        icon: Icons.work_off_outlined,
                        title: 'Belum Ada Lowongan',
                        message: 'Belum ada lowongan magang yang cocok dengan filter ini.',
                      ),
                    );
                  }
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final item = list[index];
                          return InternshipCard(
                            internship: item,
                            onTap: () => context.push('/internship/${item.id}'),
                            onBookmarkToggle: () async {
                              await ref
                                  .read(internshipServiceProvider)
                                  .toggleBookmark(item.id);
                              ref.invalidate(publishedInternshipsProvider);
                              ref.invalidate(savedInternshipsProvider);
                            },
                          );
                        },
                        childCount: list.length,
                      ),
                    ),
                  );
                },
                loading: () => const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
                error: (e, _) => SliverToBoxAdapter(
                  child: Center(
                    child: Text('Terjadi kesalahan: $e'),
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 80),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
