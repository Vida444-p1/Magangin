import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/internship_model.dart';
import '../services/internship_service.dart';

final internshipServiceProvider = Provider<InternshipService>((ref) => InternshipService());

// Filter state
class InternshipFilterState {
  final String searchQuery;
  final String category;
  final String location;
  final String workType;
  final String? duration;

  const InternshipFilterState({
    this.searchQuery = '',
    this.category = 'All',
    this.location = 'All',
    this.workType = 'All',
    this.duration,
  });

  InternshipFilterState copyWith({
    String? searchQuery,
    String? category,
    String? location,
    String? workType,
    String? duration,
  }) {
    return InternshipFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      category: category ?? this.category,
      location: location ?? this.location,
      workType: workType ?? this.workType,
      duration: duration ?? this.duration,
    );
  }
}

class FilterNotifier extends Notifier<InternshipFilterState> {
  @override
  InternshipFilterState build() => const InternshipFilterState();

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setCategory(String category) {
    state = state.copyWith(category: category);
  }

  void setLocation(String location) {
    state = state.copyWith(location: location);
  }

  void setWorkType(String workType) {
    state = state.copyWith(workType: workType);
  }

  void setDuration(String? duration) {
    state = state.copyWith(duration: duration);
  }

  void resetFilters() {
    state = const InternshipFilterState();
  }
}

final internshipFilterProvider =
    NotifierProvider<FilterNotifier, InternshipFilterState>(() => FilterNotifier());

// Published internships list (reactive to filters)
final publishedInternshipsProvider = FutureProvider<List<InternshipModel>>((ref) async {
  final service = ref.watch(internshipServiceProvider);
  final filter = ref.watch(internshipFilterProvider);

  return await service.getPublishedInternships(
    category: filter.category,
    location: filter.location,
    workType: filter.workType,
    duration: filter.duration,
    searchQuery: filter.searchQuery,
  );
});

// Recommended internships list
final recommendedInternshipsProvider = FutureProvider<List<InternshipModel>>((ref) async {
  final service = ref.watch(internshipServiceProvider);
  return await service.getRecommendedInternships();
});

// Saved / Bookmarked internships
final savedInternshipsProvider = FutureProvider<List<InternshipModel>>((ref) async {
  final service = ref.watch(internshipServiceProvider);
  return await service.getSavedInternships();
});
