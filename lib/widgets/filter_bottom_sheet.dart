import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_constants.dart';
import '../providers/internship_provider.dart';
import 'custom_button.dart';

class FilterBottomSheet extends ConsumerStatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  ConsumerState<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet> {
  late String selectedCategory;
  late String selectedLocation;
  late String selectedWorkType;
  String? selectedDuration;

  @override
  void initState() {
    super.initState();
    final filter = ref.read(internshipFilterProvider);
    selectedCategory = filter.category;
    selectedLocation = filter.location;
    selectedWorkType = filter.workType;
    selectedDuration = filter.duration;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter Lowongan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppConstants.textColor,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedCategory = 'All';
                      selectedLocation = 'All';
                      selectedWorkType = 'All';
                      selectedDuration = null;
                    });
                  },
                  child: const Text('Reset'),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 12),

            // Kategori
            const Text(
              'Kategori',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppConstants.categories.map((cat) {
                final isSelected = selectedCategory == cat;
                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (val) {
                    setState(() => selectedCategory = cat);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Lokasi
            const Text(
              'Lokasi',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['All', ...AppConstants.locations].map((loc) {
                final isSelected = selectedLocation == loc;
                return ChoiceChip(
                  label: Text(loc),
                  selected: isSelected,
                  onSelected: (val) {
                    setState(() => selectedLocation = loc);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Work Type
            const Text(
              'Work Type',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['All', ...AppConstants.workTypes].map((wt) {
                final isSelected = selectedWorkType == wt;
                return ChoiceChip(
                  label: Text(wt),
                  selected: isSelected,
                  onSelected: (val) {
                    setState(() => selectedWorkType = wt);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Durasi
            const Text(
              'Durasi Magang',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppConstants.durations.map((dur) {
                final isSelected = selectedDuration == dur;
                return ChoiceChip(
                  label: Text(dur),
                  selected: isSelected,
                  onSelected: (val) {
                    setState(() => selectedDuration = isSelected ? null : dur);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Apply button
            CustomButton(
              text: 'Terapkan Filter',
              onPressed: () {
                final notifier = ref.read(internshipFilterProvider.notifier);
                notifier.setCategory(selectedCategory);
                notifier.setLocation(selectedLocation);
                notifier.setWorkType(selectedWorkType);
                notifier.setDuration(selectedDuration);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
