import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/internship_provider.dart';
import '../../widgets/internship_card.dart';
import '../../widgets/filter_bottom_sheet.dart';
import '../../widgets/empty_state.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.text = ref.read(internshipFilterProvider).searchQuery;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openFilter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FilterBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(internshipFilterProvider);
    final internshipsAsync = ref.watch(publishedInternshipsProvider);

    final hasActiveFilter = filter.category != 'All' ||
        filter.location != 'All' ||
        filter.workType != 'All' ||
        filter.duration != null;

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Cari Lowongan Magang'),
        actions: [
          IconButton(
            onPressed: _openFilter,
            icon: Badge(
              isLabelVisible: hasActiveFilter,
              child: const Icon(Icons.tune_rounded),
            ),
            tooltip: 'Filter',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search input bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              onSubmitted: (query) {
                ref.read(internshipFilterProvider.notifier).setSearchQuery(query);
              },
              decoration: InputDecoration(
                hintText: 'Cari posisi, skill (Flutter, IT, UI/UX)...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(internshipFilterProvider.notifier).setSearchQuery('');
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Active filter tags bar
          if (hasActiveFilter)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  if (filter.category != 'All')
                    _ActiveChip(
                      label: filter.category,
                      onDelete: () => ref
                          .read(internshipFilterProvider.notifier)
                          .setCategory('All'),
                    ),
                  if (filter.location != 'All')
                    _ActiveChip(
                      label: filter.location,
                      onDelete: () => ref
                          .read(internshipFilterProvider.notifier)
                          .setLocation('All'),
                    ),
                  if (filter.workType != 'All')
                    _ActiveChip(
                      label: filter.workType,
                      onDelete: () => ref
                          .read(internshipFilterProvider.notifier)
                          .setWorkType('All'),
                    ),
                  if (filter.duration != null)
                    _ActiveChip(
                      label: filter.duration!,
                      onDelete: () => ref
                          .read(internshipFilterProvider.notifier)
                          .setDuration(null),
                    ),
                  TextButton(
                    onPressed: () =>
                        ref.read(internshipFilterProvider.notifier).resetFilters(),
                    child: const Text('Hapus Semua', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 8),

          // Results list
          Expanded(
            child: internshipsAsync.when(
              data: (list) {
                if (list.isEmpty) {
                  return EmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'Tidak Ditemukan',
                    message:
                        'Tidak ada lowongan yang sesuai kriteria pencarianmu. Coba ubah kata kunci atau filter.',
                    buttonText: 'Reset Filter',
                    onButtonPressed: () {
                      _searchController.clear();
                      ref.read(internshipFilterProvider.notifier).resetFilters();
                    },
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                        ref.invalidate(publishedInternshipsProvider);
                        ref.invalidate(savedInternshipsProvider);
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Terjadi kesalahan: $e')),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveChip extends StatelessWidget {
  final String label;
  final VoidCallback onDelete;

  const _ActiveChip({required this.label, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Chip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        deleteIcon: const Icon(Icons.close, size: 14),
        onDeleted: onDelete,
        visualDensity: VisualDensity.compact,
        backgroundColor: AppConstants.primaryLight,
      ),
    );
  }
}
